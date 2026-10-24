# Explicit resource socket defaults

Native `UModuleSocketComponent::InitializeSockets` uses a module's primary
resource when `bAutoInitialize` is enabled. Wireless modules use Electricity as
their primary resource. Explicit liquid/gas ports must set this flag to false,
as the game's own typed generator ports do. Setting `Port.ResourceType` and
`ResourceCategory` alone is insufficient.

`tools/fix_resource_socket_defaults.py` updates 36 typed component templates in
20 Blueprints: nine specialized sender/receiver pairs and both universal
devices. The original electrical sockets retain their automatic initialization.
The fix is serialized into the assets and adds no runtime loop.

Prerequisites: .NET 10, Python 3, the UAssetAPI libraries described in
[BUILDING-ICONS.md](BUILDING-ICONS.md), the matching game `.usmap`, and an extracted
83-asset source tree with UAssetAPI `.uasset.checked.json` representations.
Matching stock wireless transmitter/receiver assets supply dependent schemas.
These game files are not obtained by the tool.

```powershell
dotnet build tools/SocketDefaultsWriter -c Release
python tools/fix_resource_socket_defaults.py --source extracted-source --output fixed-source --mapping Voyage.usmap --writer tools/SocketDefaultsWriter/bin/Release/net10.0/SocketDefaultsWriter.dll --stock extracted-stock
```

The output directory must be new. The writer checks binary roundtrip equality;
the Python check verifies all 36 flags, unchanged Kismet instructions and all
pre-existing fields on the modified socket templates. The resulting source tree
can then be packed using the existing retoc workflow. A fresh native game run
is required to validate the initialization result on actual placed instances.

This document and the build tools stay in the repository. Release ZIPs contain
runtime mod files only, version 1.0.0.
