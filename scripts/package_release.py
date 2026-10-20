from pathlib import Path
import zipfile,json,hashlib

root=Path(__file__).resolve().parents[1]
archive=root/'MBN_GLOBAL_SUITE_DEVELOPPEMENT.zip'
excluded={'node_modules','.git','.temp','.branches','.release','__pycache__','legacy','apps-script','.netlify','dist'}
inactive_files={'build_backend.py','apps-script.test.ts','environment.test.ts','http.test.ts'}
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as output:
    for path in sorted(root.rglob('*')):
        relative=path.relative_to(root)
        if any(part in excluded for part in relative.parts):continue
        if path.is_symlink() or not path.is_file() or path==archive:continue
        if path.name in inactive_files:continue
        if path.suffix in {'.zip','.log'}:continue
        if path.name=='.env' or path.name.startswith('.env.') and path.name!='.env.example':continue
        if relative.parts[:2]==('source','forms'):continue
        if len(relative.parts)==2 and relative.parts[0]=='source' and path.suffix in {'.docx','.pdf','.jpg'}:continue
        # Original financial/contractual files are already retained in the supplied Library assets.
        # Keep their manifest; do not duplicate banking annex bytes into the code deliverable.
        if relative.parts[:2]==('source','mail-assets') and path.suffix in {'.pdf','.jpg'}:continue
        output.write(path,relative.as_posix())
with zipfile.ZipFile(archive) as packaged:
    assert packaged.testzip() is None
    names=packaged.namelist()
    assert 'MBN_GLOBAL_GUIDE_INSTALLATION.txt' in names
    assert 'assets/native-client.js' in names
    assert 'forms/evry-bts.html' in names
    assert len([name for name in names if name.startswith('forms/') and name.endswith('.html')])==19
    assert not any(name.startswith('apps-script/') or name.startswith('legacy/') for name in names)
    assert not any('node_modules' in name or '/.temp/' in name for name in names)
print(json.dumps({'path':str(archive),'files':len(names),'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest()}))
