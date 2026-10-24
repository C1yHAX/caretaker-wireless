"""Apply the icon-only change to extracted Wireless 1.0.0 legacy assets."""
import argparse,subprocess,shutil,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
def run(*args):subprocess.run([str(x) for x in args],check=True)
def main():
 p=argparse.ArgumentParser()
 for name in ('mapping','stock','wireless-source','retoc','output'):p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();out=a.output.resolve()
 if out.exists() and any(out.iterdir()):raise SystemExit('Use a new empty output directory')
 source=out/'source';shutil.copytree(a.wireless_source,source)
 before={p.relative_to(source).as_posix() for p in source.rglob('*.uasset')}
 assert len(before) in (58,76),'Expected complete resource-enabled Wireless assets (58 before or 76 after resource icons)'
 spec=json.loads((ROOT/'icons.json').read_text(encoding='utf-8'))
 expected=before|{'Voyage/Content/'+r['packageRoot'][6:]+'/'+r['id']+'.uasset' for r in spec}
 project=ROOT/'tools/IconBuilder'
 run('dotnet','build',project/'IconBuilder.csproj','-c','Release','--nologo')
 run('dotnet',project/'bin/Release/net10.0-windows/IconBuilder.dll',a.mapping,a.stock,ROOT/'icons.json',source,out/'reports')
 assert {p.relative_to(source).as_posix() for p in source.rglob('*.uasset')}==expected
 assert len(expected)==76,'Never drop the resource devices when rebuilding icons'
 package=out/'package';package.mkdir()
 run(a.retoc,'to-zen',source,package/'CaretakerWirelessFix_P.utoc','--version','UE5_6')
 run(a.retoc,'verify',package/'CaretakerWirelessFix_P.utoc')
if __name__=='__main__':main()
