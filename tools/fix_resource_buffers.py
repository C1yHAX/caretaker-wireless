"""Preserve stored wireless liquids/gases when receivers stop taking resources.

Patch semantic dumps of the current assets, never reconstruct older visual
templates. Stock schema donors and the game's mapping must match that build.
"""
from pathlib import Path
import argparse
import copy
import json
import shutil
import subprocess


def patch(asset):
    removed = []
    for export in asset['Exports']:
        if export['ObjectName'] != 'ModuleComponent':
            continue
        for prop in export.get('Data', []):
            if prop['Name'] == 'ActiveFlowResources':
                expired = [v for v in prop['Value'] if v['Value'] != 'EModuleResourceType::Electricity']
                removed.extend(v['Value'] for v in expired)
                prop['Value'] = [v for v in prop['Value'] if v not in expired]
    return removed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('source', 'dumps', 'output', 'mapping', 'writer', 'stock'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists(), 'Output must be a new directory'
    shutil.copytree(args.source, args.output)
    donor = next(args.stock.rglob('BP_Module_WirelessResourceTransmitter.uasset'))
    changes = []
    for source in sorted(args.source.rglob('BP_Wireless_*Transmitter.uasset')):
        dump = args.dumps / (source.name + '.json')
        before = json.loads(dump.read_text(encoding='utf-8-sig'))
        asset = copy.deepcopy(before)
        removed = patch(asset)
        assert removed, source.name
        target = args.output / source.relative_to(args.source)
        inp = target.with_suffix('.input.json')
        inp.write_text(json.dumps(asset, ensure_ascii=False), encoding='utf-8')
        subprocess.run(['dotnet', str(args.writer), str(args.mapping), str(inp), str(target), str(donor)], check=True)
        checked = json.loads(target.with_suffix('.uasset.checked.json').read_text(encoding='utf-8-sig'))
        assert checked['Imports'] == before['Imports']
        for expected, actual in zip(asset['Exports'], checked['Exports'], strict=True):
            # Removing set entries changes serialized lengths/offsets only.
            skip = {'SerialSize', 'SerialOffset'}
            assert {k:v for k,v in expected.items() if k not in skip} == {k:v for k,v in actual.items() if k not in skip}, expected['ObjectName']
        changes.append({'asset': target.relative_to(args.output).as_posix(), 'removedIdleExpiry': removed})
    assert len(changes) == 10 and sum(len(c['removedIdleExpiry']) for c in changes) == 18
    (args.output.parent / 'resource-buffer-verification.json').write_text(json.dumps({
        'version': '1.0.0', 'changes': changes, 'otherExportsAndKismetPreserved': True}, indent=2), encoding='utf-8')
    print('Verified ten transmitter templates; receiver sockets share these buffers.')


if __name__ == '__main__':
    main()
