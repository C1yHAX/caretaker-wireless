"""Preserve explicit resource ports through native module initialization.

Inputs are an existing extracted source tree including UAssetAPI checked JSON,
the matching game mapping and the built SocketDefaultsWriter DLL. No game files
are extracted or downloaded by this tool. Kismet instructions are not changed.
"""
import argparse
import copy
import json
from pathlib import Path
import shutil
import subprocess


def patch(asset):
    changed = []
    for export in asset['Exports']:
        data = export.get('Data', [])
        port = next((p for p in data if p['Name'] == 'Port'), None)
        if not port or not export['ObjectName'].endswith('_GEN_VARIABLE'):
            continue
        resource = next((p['Value'] for p in port['Value'] if p['Name'] == 'ResourceType'), None)
        if not resource or resource in ('Electricity', 'EModuleResourceType::Electricity'):
            continue
        setting = next((p for p in data if p['Name'] == 'bAutoInitialize'), None)
        if setting is None:
            setting = {'$type': 'UAssetAPI.PropertyTypes.Objects.BoolPropertyData, UAssetAPI',
                       'Name': 'bAutoInitialize', 'ArrayIndex': 0, 'IsZero': True, 'Value': False}
            data.append(setting)
        else:
            setting.update(Value=False, IsZero=True)
        if 'bAutoInitialize' not in asset['NameMap']:
            asset['NameMap'].append('bAutoInitialize')
        changed.append({'socket': export['ObjectName'], 'resource': resource})
    return changed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('source', 'output', 'mapping', 'writer', 'stock'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise SystemExit('Output must be a new directory')
    shutil.copytree(args.source, args.output)
    results = []
    for source in sorted(args.source.rglob('BP_Wireless_*.uasset.checked.json')):
        before = json.loads(source.read_text(encoding='utf-8'))
        asset = copy.deepcopy(before)
        sockets = patch(asset)
        if not sockets:
            continue
        destination = args.output / source.relative_to(args.source)
        input_json = destination.with_suffix('.input.json')
        input_json.write_text(json.dumps(asset, ensure_ascii=False), encoding='utf-8')
        output_asset = Path(str(destination).removesuffix('.checked.json'))
        donor_name = 'BP_WirelessResource_Socket_Base' if 'Receiver' in source.name else 'BP_Module_WirelessResourceTransmitter'
        donor = next(args.stock.rglob(donor_name + '.uasset'))
        subprocess.run(['dotnet', str(args.writer), str(args.mapping), str(input_json), str(output_asset), str(donor)], check=True)
        after = json.loads(destination.read_text(encoding='utf-8'))
        # Every script and every existing field must retain its meaning. Compare
        # the changed templates directly after re-reading the serialized asset.
        for original, rebuilt in zip(before['Exports'], after['Exports'], strict=True):
            if 'ScriptBytecode' in original:
                assert original['ScriptBytecode'] == rebuilt['ScriptBytecode'], original['ObjectName']
            if any(s['socket'] == rebuilt['ObjectName'] for s in sockets):
                assert next(p['Value'] for p in rebuilt['Data'] if p['Name'] == 'bAutoInitialize') is False
                old_fields = {p['Name']: p for p in original['Data'] if p['Name'] != 'bAutoInitialize'}
                new_fields = {p['Name']: p for p in rebuilt['Data'] if p['Name'] != 'bAutoInitialize'}
                assert old_fields == new_fields, rebuilt['ObjectName']
        results.append({'asset': output_asset.relative_to(args.output).as_posix(), 'sockets': sockets})
    assert len(results) == 20, len(results)
    assert sum(len(r['sockets']) for r in results) == 36
    (args.output.parent / 'socket-defaults-verification.json').write_text(
        json.dumps({'assets': results, 'assetCount': 20, 'socketCount': 36,
                    'kismetUnchanged': True, 'typedPortsAutoInitialize': False}, indent=2) + '\n', encoding='utf-8')
    print('Verified 36 typed sockets in 20 Blueprints; all Kismet unchanged.')


if __name__ == '__main__':
    main()
