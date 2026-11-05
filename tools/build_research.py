"""Build research costs from the verified public 1.0.0, preserving other chunks.

Only 21 skill chunks are replaced. The existing container dependency header,
all models, textures, items and Blueprints remain byte-identical.
"""
from pathlib import Path
import argparse, hashlib, json, os, shutil, subprocess

ROOT=Path(__file__).resolve().parents[1]
BASE_SHA='1b882767fc0be41eae0d816d3567b307146dcab0036f7de2585f8db77bdda69c'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def build(retoc, baseline, base, mapping, output):
    assert sha(baseline.with_suffix('.ucas'))==BASE_SHA, 'Unexpected public baseline'
    output.mkdir(parents=True,exist_ok=False)
    def run(*args):subprocess.run(list(map(str,args)),check=True)
    context=output/'context';context.mkdir()
    for p in base.iterdir():
        if p.suffix in ('.pak','.utoc','.ucas'):os.link(p,context/p.name)
    for ext in ('.pak','.utoc','.ucas'):
        shutil.copy2(baseline.with_suffix(ext),context/baseline.with_suffix(ext).name)
    source=output/'source'
    run(retoc,'to-legacy',context,source,'--filter','/CaretakerWireless/Skills/','--version','UE5_7')
    project=ROOT/'tools/ResearchBuilder/ResearchBuilder.csproj'
    run('dotnet','build',project,'-c','Release','--nologo')
    dll=project.parent/'bin/Release/net10.0/ResearchBuilder.dll'
    patched=output/'patched'
    run('dotnet',dll,mapping,source,patched,ROOT/'research.json',ROOT/'localization.json')
    shutil.copy2(source/'scriptobjects.bin',patched/'scriptobjects.bin')
    partial=output/'partial';partial.mkdir()
    run(retoc,'to-zen',patched,partial/'Skills.utoc','--version','UE5_7')
    raw=output/'raw';replacement=output/'replacement'
    run(retoc,'unpack-raw',baseline,raw)
    run(retoc,'unpack-raw',partial/'Skills.utoc',replacement)
    manifest=json.loads((raw/'manifest.json').read_text())
    patch_manifest=json.loads((replacement/'manifest.json').read_text())
    specs=json.loads((ROOT/'research.json').read_text())
    expected={s['asset'] for s in specs}
    before={p.name:sha(p) for p in (raw/'chunks').iterdir()}
    changed=[]
    for key,name in patch_manifest['chunk_paths'].items():
        if Path(name).stem not in expected:continue
        assert manifest['chunk_paths'][key]==name
        shutil.copy2(replacement/'chunks'/key,raw/'chunks'/key)
        changed.append(key)
    assert len(changed)==len(expected)==21
    package=output/'package';package.mkdir()
    target=package/baseline.name
    run(retoc,'pack-raw',raw,target)
    run(retoc,'verify',target)
    shutil.copy2(baseline.with_suffix('.pak'),target.with_suffix('.pak'))
    check=output/'verified-raw';run(retoc,'unpack-raw',target,check)
    assert json.loads((check/'manifest.json').read_text())==manifest
    after={p.name:sha(p) for p in (check/'chunks').iterdir()}
    assert before.keys()==after.keys()
    assert {k for k in before if before[k]!=after[k]}==set(changed)
    for ext in ('.pak','.utoc','.ucas'):shutil.copy2(target.with_suffix(ext),context/target.with_suffix(ext).name)
    extracted=output/'verified-skills'
    run(retoc,'to-legacy',context,extracted,'--filter','/CaretakerWireless/Skills/','--version','UE5_7')
    audit=output/'verified-audit';run('dotnet',dll,mapping,extracted,audit)
    checked={s['asset']:s for s in json.loads((audit/'skills.json').read_text())}
    for spec in specs:
        assert checked[spec['asset']]['cost']==spec['cost']
        assert checked[spec['asset']]['level']==spec['level']
    # Roundtrip the final container again: preserve all skill imports and
    # semantic exports, except the two intentionally changed properties.
    for p in patched.rglob('*.uasset.json'):
        final=json.loads((audit/p.relative_to(patched)).read_text(encoding='utf-8-sig'))
        intended=json.loads(p.read_text(encoding='utf-8-sig'))
        for doc in (final,intended):
            for e in doc['Exports']:
                e.pop('SerialSize',None);e.pop('SerialOffset',None)
        assert final['Imports']==intended['Imports'],p.name
        assert final['Exports']==intended['Exports'],p.name
    report=dict(version='1.0.1',skills=specs,changedSkills=21,
                preservedChunks=len(before)-len(changed),containerDependenciesPreserved=True,
                modelsTexturesItemsBlueprintsPreserved=True,
                baselineUcasSha256=BASE_SHA,files=[dict(name=p.name,sha256=sha(p),bytes=p.stat().st_size) for p in sorted(package.iterdir())])
    (output/'verification.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    print(json.dumps(report,indent=2))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for key in ('retoc','baseline','base','mapping','output'):parser.add_argument('--'+key,type=Path,required=True)
    build(**vars(parser.parse_args()))
