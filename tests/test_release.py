"""Deployment boundaries verified offline: no live providers or credentials are used."""
import base64
import json
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import release
from release_config import target_from_env, SOURCE_REF, SOURCE_KEY, SOURCE_ORIGIN

ENV = {'MBN_SUPABASE_PROJECT_REF': 'abcdefghijklmnopqrst', 'MBN_SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_synthetic_public_key',
       'MBN_PUBLIC_ORIGIN': 'https://mbn-staging.netlify.app'}
TARGET = target_from_env(ENV)
PROVIDERS = {**ENV, 'SUPABASE_ACCESS_TOKEN': 'synthetic-management', 'NETLIFY_AUTH_TOKEN': 'synthetic-netlify',
             'NETLIFY_SITE_ID': '12345678-1234-1234-1234-123456789abc'}


class Configuration(unittest.TestCase):
    def test_public_target_is_complete_and_rejects_privileged_keys(self):
        self.assertIsNone(target_from_env({}))
        for update in ({'MBN_SUPABASE_PROJECT_REF': ''}, {'MBN_PUBLIC_ORIGIN': 'https://example.invalid/path'},
                       {'MBN_PUBLIC_ORIGIN': 'https://example.invalid/"'}, {'MBN_SUPABASE_PUBLISHABLE_KEY': 'sb_secret_do_not_publish'}):
            with self.subTest(update=list(update)), self.assertRaises(ValueError):
                target_from_env({**ENV, **update})
        for role, ref, allowed in [('service_role', TARGET.ref, False), ('anon', 'wrong', False), ('anon', TARGET.ref, True)]:
            payload = base64.urlsafe_b64encode(json.dumps({'role': role, 'ref': ref}).encode()).decode().rstrip('=')
            env = {**ENV, 'MBN_SUPABASE_PUBLISHABLE_KEY': 'header.' + payload + '.signature'}
            if allowed:
                self.assertEqual(target_from_env(env).ref, TARGET.ref)
            else:
                with self.assertRaises(ValueError):
                    target_from_env(env)

    def test_history_requires_an_exact_prefix_and_never_adopts_an_existing_schema(self):
        versions = ['20261018162317', '20261018163159', '20261018163634']
        self.assertEqual(release.history_plan(versions, [], False), versions)
        self.assertEqual(release.history_plan(versions, versions[:1], True), versions[1:])
        for remote, exists in [([], True), ([versions[1]], True), (versions + ['20261020000000'], True), ([versions[0], versions[0]], True), (['garbage'], False)]:
            with self.subTest(remote=remote), self.assertRaises(ValueError):
                release.history_plan(versions, remote, exists)

    def test_apply_refuses_before_preparing_or_connecting_if_not_explicitly_enabled(self):
        for extra in ({}, {'MBN_DEPLOY_ENABLED': 'true'}):
            with patch.dict(os.environ, {**ENV, **extra}, clear=True), patch.object(sys, 'argv', ['release.py', '--apply']), patch.object(release, 'prepare') as prepare, patch.object(release, 'Providers') as providers:
                with self.assertRaises(ValueError):
                    release.main()
                prepare.assert_not_called()
                providers.assert_not_called()

    def test_feature_preparation_is_offline_and_rewrites_both_site_and_function_packages(self):
        commit = 'a' * 40
        with patch.object(release, 'http', side_effect=AssertionError('No provider requests during preparation')):
            manifest = release.prepare(TARGET, commit)
        self.assertEqual(manifest['commit'], commit)
        with zipfile.ZipFile(release.GENERATED / 'site.zip') as archive:
            self.assertEqual(len([p for p in archive.namelist() if p.startswith('forms/') and p.endswith('.html')]), 19)
            self.assertFalse(any(p.startswith(('source/', 'supabase/')) for p in archive.namelist()))
            health = json.loads(archive.read('health.json'))
            self.assertEqual(health['commit'], commit)
            for name in archive.namelist():
                if name.endswith(('.js', '.html')):
                    text = archive.read(name).decode()
                    for stale in (SOURCE_REF, SOURCE_KEY, SOURCE_ORIGIN):
                        self.assertNotIn(stale, text, name)
        for path in (release.GENERATED / 'supabase/functions').rglob('*'):
            if path.suffix in ('.ts', '.js'):
                text = path.read_text()
                self.assertNotIn('../../../assets/', text)
                self.assertNotIn(SOURCE_REF, text)
                self.assertNotIn(SOURCE_ORIGIN, text)
        for path in (ROOT / 'supabase/migrations').glob('*.sql'):
            self.assertEqual(path.read_bytes(), (release.GENERATED / 'supabase/migrations' / path.name).read_bytes())


class ProviderBoundaries(unittest.TestCase):
    def setUp(self):
        self.provider = release.Providers(TARGET, PROVIDERS)
        self.versions = ['20261018162317']

    def test_site_mismatch_stops_before_querying_or_writing_the_database(self):
        with patch.object(self.provider, 'netlify', return_value={'id': self.provider.site, 'ssl_url': SOURCE_ORIGIN}), patch.object(self.provider, 'sql') as sql:
            with self.assertRaises(ValueError):
                self.provider.preflight(self.versions)
            sql.assert_not_called()

    def test_a_preflight_only_uses_read_queries_and_rejects_cross_environment_reuse(self):
        responses = [[{'history': True, 'app_exists': True, 'configured': True}], [{'version': self.versions[0]}],
                     [{'project_url': TARGET.url, 'public_origin': SOURCE_ORIGIN}]]
        with patch.object(self.provider, 'netlify', return_value={'id': self.provider.site, 'ssl_url': TARGET.origin}), patch.object(release, 'http', return_value={'disable_signup': True, 'external': {'anonymous': False}}), patch.object(self.provider, 'sql', side_effect=responses) as sql:
            with self.assertRaises(ValueError):
                self.provider.preflight(self.versions)
            self.assertTrue(all(call.kwargs.get('read_only', True) for call in sql.call_args_list))

    def test_backend_failure_cannot_publish_the_frontend(self):
        with patch.dict(os.environ, {'SUPABASE_DB_PASSWORD': 'synthetic'}), patch.object(release.subprocess, 'check_output', return_value=release.CLI_VERSION), patch.object(release, 'cli', side_effect=ValueError('synthetic backend failure')), patch.object(self.provider, 'netlify') as netlify:
            with self.assertRaises(ValueError):
                release.apply(self.provider, {'commit': 'a' * 40}, {'fresh': False})
            netlify.assert_not_called()

    def test_http_never_redirects_credentials_and_does_not_retry_an_ambiguous_write(self):
        self.assertIsNone(release.NoRedirect().redirect_request(None, None, None, None, None, None))
        with patch.object(release.request, 'build_opener') as opener:
            opener.return_value.open.side_effect = TimeoutError()
            with self.assertRaises(ValueError):
                release.http('https://api.supabase.com/example', 'POST', 'synthetic', {'query': 'synthetic'})
            self.assertEqual(opener.return_value.open.call_count, 1)

    def test_backend_health_failure_stops_before_frontend_publication(self):
        with patch.dict(os.environ, {'SUPABASE_DB_PASSWORD': 'synthetic'}), patch.object(release.subprocess, 'check_output', return_value=release.CLI_VERSION), patch.object(release, 'cli'), patch.object(self.provider, 'sql', side_effect=[[{'count': 1}], [{'count': 3}], []]), patch.object(release, 'install_public_assets'), patch.object(release, 'http', return_value={'service': 'wrong'}), patch.object(self.provider, 'netlify') as netlify:
            with self.assertRaises(ValueError):
                release.apply(self.provider, {'commit': 'a' * 40}, {'fresh': False})
            netlify.assert_not_called()

    def test_a_complete_delivery_checks_backend_before_publishing_and_verifies_the_target_commit(self):
        manifest = {'commit': 'a' * 40, 'project_ref': TARGET.ref, 'public_origin': TARGET.origin}
        trace = []
        def remote(url, *args, **kwargs):
            trace.append(url)
            if '/health.json' in url:
                return manifest
            return {'service': url.split('/functions/v1/')[1].split('?')[0]}
        def netlify(path, *args):
            trace.append(path)
            return {'id': 'b' * 24} if path == '/deploys' else {'state': 'ready'}
        with patch.dict(os.environ, {'SUPABASE_DB_PASSWORD': 'synthetic'}), patch.object(release.subprocess, 'check_output', return_value=release.CLI_VERSION), patch.object(release, 'cli') as cli, patch.object(self.provider, 'sql', side_effect=[[{'count': 1}], [{'count': 3}], []]), patch.object(release, 'install_public_assets'), patch.object(release, 'http', side_effect=remote), patch.object(self.provider, 'netlify', side_effect=netlify), patch.object(Path, 'read_bytes', return_value=b'synthetic zip'), patch('builtins.print'):
            release.apply(self.provider, manifest, {'fresh': False})
        self.assertEqual(cli.call_args_list[1].args, ('db', 'push', '--dry-run'))
        self.assertEqual(cli.call_args_list[2].args, ('db', 'push'))
        self.assertEqual(trace[:2], [TARGET.url + '/functions/v1/mbn-form-ingest?health=1', TARGET.url + '/functions/v1/mbn-letters?health=1'])
        self.assertEqual(trace[2], '/deploys')
        self.assertTrue(trace[-1].startswith(TARGET.origin + '/health.json?commit=' + manifest['commit']))


if __name__ == '__main__':
    unittest.main()
