# Icons nachbauen

Die fertig installierbare Mod liegt im Release-ZIP. Der folgende optionale Schritt erzeugt ausschließlich die Icon-Ergänzung auf Basis der vorherigen elf Wireless-Assets; er ersetzt nicht den vollständigen Editor-Build der übrigen Reparaturen.

Voraussetzungen: Windows, Python 3, .NET 10 mit Windows-Desktop-Unterstützung, retoc und UAssetAPI. Die passende UAssetAPI-Fassung und der UE5.8-Payload-Patch sind in der [Energy-Bauanleitung](https://github.com/C1yHAX/caretaker-energy/blob/main/BUILDING.md) beschrieben. Die drei DLLs `UAssetAPI.dll`, `Newtonsoft.Json.dll` und `ZstdSharp.dll` lokal unter `tools/lib` ablegen. Mapping und Original-Spielassets sind nicht im Quellcode enthalten.

1. Aus dem geprüften Spielbuild die Textur `/Game/UI/Icons/Cables/Icon_Extender_Electricity` mit retoc als Legacy-Asset extrahieren; Verzeichnisstruktur `Voyage/Content` erhalten.
2. Die elf Wireless-Assets vor der Icon-Ergänzung einschließlich `scriptobjects.bin` als Legacy-Baum bereitstellen. Die übrigen Reparaturen müssen bereits enthalten sein.
3. `python tools/build_icons.py --mapping <Voyage.usmap> --stock <Stock-Legacy-Baum> --wireless-source <Wireless-Legacy-Baum> --retoc <retoc.exe> --output <neuer Ausgabeordner>` ausführen.

`icons.json` ordnet jedem Gegenstand eine eigene Textur zu. Der Builder übernimmt Größe und Pixelformat, erzeugt transparente 256×256-BGRA8-Texturen und ändert nur die zwei Icon-Imports in den Gegenständen. Das ursprüngliche Extender-Symbol bleibt erhalten. Der Container enthält anschließend 13 Assetpakete; Gegenstandsanzahl, Gameplay-Exports und Lua-Skripte ändern sich dabei nicht. Die PNG-Quellen und Bildbearbeitungs-Prompts liegen unter `assets/icons`.

Nach einer Payload-Aktualisierung müssen die SHA-256-Werte in `Dateien.json` erneuert werden. `python tools/package_release.py` kontrolliert die zwölf installierbaren Dateien und erzeugt `Caretaker-Wireless-Fix-1.0.0.zip` samt Prüfsumme.
