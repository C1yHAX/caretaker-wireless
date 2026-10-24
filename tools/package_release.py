"""Verify the checked-in payload and create a deterministic installable release."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parent.parent
VERSION = '1.0.0'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def main():
    rows = json.loads((ROOT/'Dateien.json').read_text(encoding='utf-8'))
    expected = {row['path'] for row in rows}
    actual = {p.relative_to(ROOT).as_posix() for p in (ROOT/'Voyage').rglob('*') if p.is_file()}
    assert len(rows) == len(expected) == 12 and actual == expected, 'Unexpected install payload'
    for row in rows:
        p = ROOT/row['path']
        assert p.resolve().is_relative_to((ROOT/'Voyage').resolve()), row['path']
        data = p.read_bytes()
        assert len(data) == row['bytes'] and sha(data) == row['sha256'], row['path']
    metadata = ['README.md', 'CHANGELOG.md', 'THIRD-PARTY-NOTICES.md', 'LICENSE',
                'ASSET-CHANGES.md', 'Install-Wireless.ps1', 'Dateien.json', 'Funkstrom-Kanaele.txt', 'icons.json', 'BUILDING-ICONS.md']
    files = [ROOT/name for name in metadata] + [ROOT/name for name in expected]
    files += list((ROOT/'verification').glob('*.json'))
    files += [p for p in (ROOT/'assets/icons').iterdir() if p.is_file()]
    for p in files:
        assert p.suffix not in ('.sav', '.log', '.dmp') and 'CaretakerAudit' not in str(p)
        if p.suffix not in ('.pak', '.ucas', '.utoc', '.png'):
            text = p.read_text(encoding='utf-8')
            for private in ['C:\\Users\\', 'C:/Users/', 'E:\\Program Files\\GitHub',
                            'E:/Program Files/GitHub', 'ghp_', 'glpat-', 'gho_']:
                assert private not in text, f'Private data marker in {p.name}'
    out = ROOT/'dist'; out.mkdir(exist_ok=True)
    archive = out/f'Caretaker-Wireless-Fix-{VERSION}.zip'
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for p in sorted(files):
            info = zipfile.ZipInfo(p.relative_to(ROOT).as_posix(), (2026, 10, 24, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            # Preserve install payload bytes; canonicalize documentation newlines.
            data = p.read_bytes() if p.relative_to(ROOT).as_posix() in expected or p.suffix=='.png' else p.read_text(encoding='utf-8').encode('utf-8')
            z.writestr(info, data, compresslevel=9)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for row in rows: assert sha(z.read(row['path'])) == row['sha256']
    digest = sha(archive.read_bytes())
    (out/'SHA256SUMS.txt').write_text(f'{digest}  {archive.name}\n', encoding='ascii')
    print(json.dumps(dict(file=archive.name, bytes=archive.stat().st_size, sha256=digest,
                          checkedPayloadFiles=len(rows)), indent=2))

if __name__ == '__main__':
    main()
