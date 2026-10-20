"""Prepare a target-specific delivery; remote writes require --apply and an explicit target."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
from urllib import request, error
from release_config import target_from_env

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / '.release'
FUNCTIONS = ('mbn-auth', 'mbn-form-ingest', 'mbn-workspace', 'mbn-admissions', 'mbn-letters', 'mbn-brevo-events', 'mbn-mail-events', 'mbn-meta', 'mbn-antivirus')
CLI_VERSION = '2.121.0'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def history_plan(local, remote, app_exists):
    if not isinstance(remote, list) or any(not isinstance(v, str) or not re.fullmatch(r'\d{14}', v) for v in remote):
        raise ValueError('Invalid remote migration history')
    if remote != local[:len(remote)] or (not remote and app_exists):
        raise ValueError('Migration history differs: reconcile the existing database before deploying; no automatic repair')
    return local[len(remote):]


class NoRedirect(request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def http(url, method='GET', token=None, payload=None, headers=None):
    """No redirects or automatic retries: a timed-out write may already have succeeded."""
    h = {'Accept': 'application/json', **(headers or {})}
    if token:
        h['Authorization'] = 'Bearer ' + token
    if payload is not None and not isinstance(payload, bytes):
        payload = json.dumps(payload).encode()
        h['Content-Type'] = 'application/json'
    try:
        req = request.Request(url, data=payload, method=method, headers=h)
        with request.build_opener(NoRedirect()).open(req, timeout=60) as response:
            raw = response.read(4 * 1024 * 1024 + 1)
            if len(raw) > 4 * 1024 * 1024:
                raise ValueError('API response exceeds limit')
            return json.loads(raw)
    except error.HTTPError as exc:
        # Error bodies/headers can contain tickets, queries or credentials.
        raise ValueError(f'Remote request refused (HTTP {exc.code}); inspect the provider dashboard') from None
    except (error.URLError, TimeoutError):
        raise ValueError('Remote request failed; inspect the provider dashboard before retrying a write') from None


class Providers:
    def __init__(self, target, env=None):
        self.target = target
        self.env = os.environ if env is None else env
        for key in ('SUPABASE_ACCESS_TOKEN', 'NETLIFY_AUTH_TOKEN', 'NETLIFY_SITE_ID'):
            if not self.env.get(key):
                raise ValueError(f'Missing {key}')
        self.site = self.env['NETLIFY_SITE_ID']
        if not re.fullmatch(r'[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}', self.site):
            raise ValueError('NETLIFY_SITE_ID must be the exact site UUID')

    def sql(self, query, parameters=None, read_only=True):
        result = http(f'https://api.supabase.com/v1/projects/{self.target.ref}/database/query', 'POST',
                      self.env['SUPABASE_ACCESS_TOKEN'], {'query': query, 'parameters': parameters or [], 'read_only': read_only})
        if not isinstance(result, list):
            raise ValueError('Unexpected Supabase query response; no fallback or migration repair')
        return result

    def netlify(self, path='', method='GET', payload=None, headers=None):
        return http('https://api.netlify.com/api/v1/sites/' + self.site + path, method,
                    self.env['NETLIFY_AUTH_TOKEN'], payload, headers)

    def preflight(self, versions):
        site = self.netlify()
        if site.get('id') != self.site or site.get('ssl_url') != self.target.origin:
            raise ValueError('Netlify site UUID and primary HTTPS origin do not match the target')
        settings = http(self.target.url + '/auth/v1/settings', headers={'apikey': self.target.key})
        if settings.get('disable_signup') is not True or settings.get('external', {}).get('anonymous') is True:
            raise ValueError('Disable public signup and anonymous Auth accounts in the target Supabase project first')
        state = self.sql("select to_regclass('supabase_migrations.schema_migrations') is not null as history, exists(select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in ('r','p') and c.relname<>'spatial_ref_sys') as app_exists, to_regclass('private.mbn_installation_settings') is not null as configured")[0]
        remote = [r['version'] for r in self.sql('select version::text from supabase_migrations.schema_migrations order by version')] if state['history'] else []
        pending = history_plan(versions, remote, state['app_exists'])
        if state['configured']:
            installed = self.sql('select project_url,public_origin from private.mbn_installation_settings where id')
            if installed and (installed[0]['project_url'] != self.target.url or installed[0]['public_origin'] != self.target.origin):
                raise ValueError('This database is already attached to another site; use a separate project for each environment')
        return {'pending_migrations': pending, 'fresh': not remote and not state['app_exists']}


def prepare(target, commit):
    if GENERATED.is_symlink() or GENERATED.exists() and not (GENERATED / 'mbn-generated.json').is_file():
        raise ValueError('Refusing to replace an unrecognized .release directory')
    if GENERATED.exists():
        shutil.rmtree(GENERATED)
    GENERATED.mkdir()
    (GENERATED / 'mbn-generated.json').write_text('{"generated_by":"scripts/release.py"}\n')
    staged = GENERATED / 'supabase'
    staged.mkdir()
    for name in ('config.toml', 'seed.sql'):
        shutil.copyfile(ROOT / 'supabase' / name, staged / name)
    for name in ('migrations', 'functions'):
        shutil.copytree(ROOT / 'supabase' / name, staged / name)
    shared = staged / 'functions/_shared'
    shared.mkdir()
    (shared / 'branding.js').write_text(target.rewrite((ROOT / 'assets/branding.js').read_text()))
    for path in (staged / 'functions').rglob('*'):
        if path.is_file() and path.suffix in ('.ts', '.js'):
            path.write_text(target.rewrite(path.read_text()).replace('../../../assets/branding.js', '../_shared/branding.js'))
    env = dict(os.environ, MBN_RELEASE_COMMIT=commit, MBN_SUPABASE_PROJECT_REF=target.ref,
               MBN_SUPABASE_PUBLISHABLE_KEY=target.key, MBN_PUBLIC_ORIGIN=target.origin)
    subprocess.run([sys.executable, str(ROOT / 'scripts/build_netlify.py'), '--release'], cwd=ROOT, env=env, check=True, stdout=subprocess.DEVNULL)
    migrations = [{'version': p.name.split('_')[0], 'file': p.name, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                  for p in sorted((staged / 'migrations').glob('*.sql'))]
    versions = [m['version'] for m in migrations]
    if len(versions) != len(set(versions)) or any(not re.fullmatch(r'\d{14}', v) for v in versions):
        raise ValueError('Invalid or duplicate migration versions')
    manifest = {'commit': commit, 'project_ref': target.ref, 'public_origin': target.origin, 'functions': list(FUNCTIONS),
                'migrations': migrations, 'site_sha256': hashlib.sha256((GENERATED / 'site.zip').read_bytes()).hexdigest()}
    (GENERATED / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest


def cli(*args):
    # Capture rather than echo provider output, which can disclose a connection string.
    result = subprocess.run(['supabase', *args], cwd=GENERATED, capture_output=True, text=True, timeout=600)
    if result.returncode:
        raise ValueError(f'Supabase command failed ({args[0]}); inspect the dashboard; no automatic retry')


def install_public_assets(providers):
    assets = providers.sql("select key,filename,sha256,byte_size,mime_type from private.mbn_original_assets where starts_with(key,'logo_') or key in ('font_regular','font_bold') order by key")
    if len(assets) != 22:
        raise ValueError('Unexpected public logo/font inventory')
    for a in assets:
        if a['key'] in ('font_regular', 'font_bold'):
            if a['filename'] != a['key'][5:] + '.ttf':
                raise ValueError('Unexpected font path')
            path = ROOT / 'source/fonts' / a['filename']
        elif re.fullmatch(r'logo_[a-z0-9-]+', a['key']) and a['filename'] == a['key'][5:] + '.png':
            path = ROOT / 'assets/brands' / a['filename']
        else:
            raise ValueError('Unexpected asset path')
        if not path.is_relative_to(ROOT) or path.is_symlink():
            raise ValueError('Invalid asset input')
        data = path.read_bytes()
        if len(data) != a['byte_size'] or hashlib.sha256(data).hexdigest() != a['sha256']:
            raise ValueError('Logo/font differs from its pinned database checksum')
        ticket = providers.sql('select public.mbn_asset_install_ticket($1) as ticket', [a['key']], read_only=False)[0]['ticket']['token']
        result = http(providers.target.url + '/functions/v1/mbn-letters?asset=' + a['key'], 'POST', payload=data,
                      headers={'x-mbn-asset': ticket, 'Content-Type': a['mime_type'], 'apikey': providers.target.key})
        if result.get('installed') is not True:
            raise ValueError('Asset installation did not complete')


def apply(providers, manifest, plan):
    if not os.environ.get('SUPABASE_DB_PASSWORD'):
        raise ValueError('Missing SUPABASE_DB_PASSWORD')
    version = subprocess.check_output(['supabase', '--version'], text=True).strip()
    if version != CLI_VERSION:
        raise ValueError('Use the pinned Supabase CLI ' + CLI_VERSION)
    cli('link', '--project-ref', providers.target.ref)
    cli('db', 'push', '--dry-run')
    cli('db', 'push')
    # Never include-seed in db push; only a fresh install or explicit initialization uses this idempotent catalog.
    if plan['fresh'] or os.environ.get('MBN_INITIALIZE_CATALOG') == 'true':
        providers.sql((GENERATED / 'supabase/seed.sql').read_text(), read_only=False)
    count = providers.sql('select count(*)::int as count from public.school_programs')[0]['count']
    if count == 0:
        raise ValueError('Catalog is empty: review the installation and explicitly initialize it before retrying')
    keys = providers.sql('select count(*)::int as count from private.mbn_runtime_secrets r join vault.decrypted_secrets d on d.id=r.vault_id')[0]['count']
    if keys != 3:
        raise ValueError('Vault runtime keys are incomplete; stop before deploying the functions')
    providers.sql('select public.mbn_installation_configure($1,$2,$3)', [providers.target.url, providers.target.origin, manifest['commit']], read_only=False)
    for function in FUNCTIONS:
        cli('functions', 'deploy', function, '--project-ref', providers.target.ref, '--use-api', '--no-verify-jwt')
    install_public_assets(providers)
    for service in ('mbn-form-ingest', 'mbn-letters', 'mbn-antivirus'):
        health = http(providers.target.url + '/functions/v1/' + service + '?health=1', headers={'apikey': providers.target.key})
        if health.get('service') != service:
            raise ValueError('Backend health check failed before the site publication')
    deployment = providers.netlify('/deploys', 'POST', (GENERATED / 'site.zip').read_bytes(), {'Content-Type': 'application/zip'})
    deploy_id = deployment.get('id', '')
    if not re.fullmatch(r'[a-f0-9]{24}', deploy_id):
        raise ValueError('Unexpected Netlify deploy identifier; inspect the dashboard')
    for _ in range(60):
        state = providers.netlify('/deploys/' + deploy_id).get('state')
        if state == 'ready':
            break
        if state == 'error':
            raise ValueError('Netlify deployment failed; no database rollback was attempted')
        time.sleep(5)
    else:
        raise ValueError('Netlify deployment still processing; inspect its state before retrying')
    health = http(providers.target.origin + '/health.json?commit=' + manifest['commit'])
    if any(health.get(k) != manifest[k] for k in ('commit', 'project_ref', 'public_origin')):
        raise ValueError('Published site does not match the candidate commit and target')
    print(json.dumps({'deployed': True, 'commit': manifest['commit'], 'project_ref': providers.target.ref, 'public_origin': providers.target.origin, 'deploy_id': deploy_id}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--preflight', action='store_true', help='Read target state without remote writes')
    parser.add_argument('--apply', action='store_true', help='Apply after checks; requires MBN_DEPLOY_ENABLED=true')
    parser.add_argument('--confirm-project')
    args = parser.parse_args()
    target = target_from_env(required=True)
    commit = git('rev-parse', 'HEAD')
    if args.apply:
        if os.environ.get('MBN_DEPLOY_ENABLED') != 'true' or args.confirm_project != target.ref:
            raise ValueError('Deployment disabled or exact project confirmation missing')
        if git('status', '--porcelain'):
            raise ValueError('Deploy only a clean committed checkout')
        if os.environ.get('GITHUB_SHA', commit) != commit:
            raise ValueError('Checkout does not match the selected workflow commit')
    manifest = prepare(target, commit)
    print(json.dumps({'prepared': True, 'commit': commit, 'project_ref': target.ref, 'public_origin': target.origin, 'remote_writes': False}))
    if args.preflight or args.apply:
        providers = Providers(target)
        plan = providers.preflight([m['version'] for m in manifest['migrations']])
        print(json.dumps(plan))
        if args.apply:
            apply(providers, manifest, plan)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        # Do not serialize subprocess stdout/stderr or an environment value.
        if isinstance(exc, ValueError):
            print('Release stopped: ' + str(exc), file=sys.stderr)
        else:
            print('Release stopped: local command or file operation failed', file=sys.stderr)
        sys.exit(1)
