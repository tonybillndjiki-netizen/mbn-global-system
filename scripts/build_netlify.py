"""Build only the browser files needed by the MBN validation site."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import hashlib
import json
import shutil
import zipfile
import argparse
from datetime import datetime, timezone
from release_config import target_from_env

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--release', action='store_true', help='Build inside the generated .release directory')
args = parser.parse_args()
config = target_from_env(required=args.release)
publish = root / ('.release/dist' if args.release else 'dist')
archive = root / ('.release/site.zip' if args.release else 'MBN_GLOBAL_NETLIFY.zip')
if args.release and (root / '.release').is_symlink():
    raise SystemExit('.release must not be a symbolic link')

# Recreate this generated directory so stale source documents cannot be uploaded.
if publish.is_symlink():
    raise SystemExit('dist must not be a symbolic link')
if publish.exists():
    shutil.rmtree(publish)
publish.mkdir(parents=True)

selected = [root / name for name in ['index.html', 'MBN_GLOBAL_Admin_Supabase.html', 'apply.html', 'preferences.html', 'documents.html']]
selected += sorted((root / 'assets').rglob('*.js'))
selected += sorted((root / 'assets').rglob('*.css'))
selected += sorted((root / 'assets' / 'brands').glob('*.png'))
selected += sorted((root / 'forms').glob('*.html'))
selected += [root / 'forms' / 'manifest.json']
for source in selected:
    if source.is_symlink() or not source.is_file():
        raise SystemExit(f'Invalid publish input: {source.relative_to(root)}')
    target = publish / source.relative_to(root)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
shutil.copyfile(root / 'netlify' / '_headers', publish / '_headers')
if config:
    for path in publish.rglob('*'):
        if path.is_file() and (path.suffix in {'.html', '.js', '.css', '.json'} or path.name == '_headers'):
            path.write_text(config.rewrite(path.read_text()))
package = json.loads((root / 'package.json').read_text())
asset_fingerprint = hashlib.sha256(b''.join(p.read_bytes() for p in sorted((publish / 'assets').glob('*.js')))).hexdigest()
health = {'application': 'MBN GLOBAL', 'version': package['version'], 'built_at': datetime.now(timezone.utc).isoformat(), 'assets_sha256': asset_fingerprint, 'modules': ['MBN MAIL', 'MBN CRM']}
if config:
    import os
    import re
    commit = os.environ.get('MBN_RELEASE_COMMIT', '')
    if commit and not re.fullmatch('[a-f0-9]{40}', commit):
        raise SystemExit('Invalid MBN_RELEASE_COMMIT')
    health.update(project_ref=config.ref, public_origin=config.origin, commit=commit)
(publish / 'health.json').write_text(json.dumps(health, indent=2)+'\n')

assert len(list((publish / 'forms').glob('*.html'))) == 19
assert len(list((publish / 'assets' / 'brands').glob('*.png'))) == 21
assert not any(p.is_symlink() for p in publish.rglob('*'))

class References(HTMLParser):
    def __init__(self):
        super().__init__()
        self.urls = []
    def handle_starttag(self, tag, attributes):
        for name, value in attributes:
            if name in {'src', 'href'} and value:
                self.urls.append(value)

checked = 0
for page in publish.rglob('*.html'):
    text = page.read_text()
    assert 'script.google.com' not in text
    parser = References()
    parser.feed(text)
    for url in parser.urls:
        parts = urlsplit(url)
        if parts.scheme or parts.netloc or not parts.path:
            continue
        target = (publish / unquote(parts.path).lstrip('/')) if parts.path.startswith('/') else page.parent / unquote(parts.path)
        target = target.resolve()
        assert target.is_relative_to(publish.resolve()), (page, url)
        assert target.is_file(), (page, url)
        checked += 1

with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as output:
    for path in sorted(publish.rglob('*')):
        if path.is_file():
            output.write(path, path.relative_to(publish).as_posix())
with zipfile.ZipFile(archive) as output:
    assert output.testzip() is None
    names = output.namelist()
    assert 'index.html' in names and '_headers' in names
    assert not any(name.startswith(('source/', 'supabase/', 'tests/', 'node_modules/', 'legacy/', 'apps-script/')) for name in names)
print(json.dumps({'publish': str(publish), 'archive': str(archive), 'files': len(names), 'forms': 19, 'local_references_checked': checked, 'bytes': archive.stat().st_size, 'sha256': hashlib.sha256(archive.read_bytes()).hexdigest()}))
