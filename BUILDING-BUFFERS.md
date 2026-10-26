# Conserved wireless resource buffers

The electrical transmitter uses `VoyageCustomModuleComponent.ActiveFlowResources`.
That native mechanism expires an idle resource after `ActiveFlowTimerLength`
(0.5 seconds in the tested build). Adding liquids and gases to this set caused
their full 1,000-unit buffers to be erased when no output was taking resources.
Repeated filling then emptied upstream storage without delivering anything.

The resource transmitter templates now retain only Electricity in that set.
Their existing `MaxResources` entries remain at 1,000. Native routing therefore
stops intake when a buffer is full and resumes when an output frees capacity.
There is no Lua refill, compensation, timer extension or simulated consumption.
Electricity keeps its native behaviour and the devices' normal operating cost.

Nine specialized transmitters and the universal transmitter require the fix.
Receiver sockets are registered as external sockets on the transmitter module;
the receiver's displayed quantity is that shared buffer, not a second reservoir.
No receiver asset, socket transform, material, mesh or Blueprint instruction is
changed by this correction. Already placed actors use the corrected template
when the game loads them again.

`tools/fix_resource_buffers.py` takes the current extracted source tree plus
matching UAssetAPI dumps named `BP_Wireless_*.uasset.json`. Use the installed
game's `.usmap`, matching stock schema donors and the existing
`tools/SocketDefaultsWriter` executable. Example:

```powershell
python tools/fix_resource_buffers.py --source current-source --dumps current-semantic-dumps --output conserved-source --mapping Voyage.usmap --writer tools/SocketDefaultsWriter/bin/Release/net10.0/SocketDefaultsWriter.dll --stock extracted-stock
```

The writer verifies binary roundtrip equality. The patch verifies every export
against the expected semantic change, allowing only serialized size/offset
changes, and preserves all imports and Kismet instructions. Pack only runtime
asset files from the resulting source tree with retoc. Keep the accepted antenna
art containers unchanged. Apply this correction after any legacy generator that
adds non-electrical resources to `ActiveFlowResources`.

For game verification, count source + shared transmitter buffer + destination
exactly once. Test all nine resources with each specialized sender and with the
universal sender, disconnected outputs, full targets, removal of a known amount,
and distant operation. Use an isolated save profile. A stock full CO2 tank vents
above 99.9% via `LeakExcessResources`; use a sealed test reservoir to isolate
wireless conservation rather than mistaking that intentional stock loss for a
wireless defect. The stock tank itself must remain unchanged.

Version stays 1.0.0. This document, tools and verification data remain outside
the runtime-only release ZIPs.
