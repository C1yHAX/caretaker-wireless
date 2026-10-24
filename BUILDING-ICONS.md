# Icons nachbauen

Der Release enthält die fertig installierbare Mod. Dieser optionale Builder aktualisiert ausschließlich Icons in einem vollständigen Ressourcen-Wireless-Build; er erstellt die Gameplay-Reparaturen und Geräte nicht neu.

Voraussetzungen: Windows, Python 3, .NET 10 mit Windows-Desktop-Unterstützung, retoc und UAssetAPI. Die passende UAssetAPI-Fassung und der UE5.8-Payload-Patch sind in der [Energy-Bauanleitung](https://github.com/C1yHAX/caretaker-energy/blob/main/BUILDING.md) beschrieben. UAssetAPI.dll, Newtonsoft.Json.dll und ZstdSharp.dll lokal unter tools/lib ablegen. Mapping und Original-Spielassets werden nicht mitgeliefert.

1. Die Textur `/Game/UI/Icons/Cables/Icon_Extender_Electricity` aus dem geprüften Spielbuild als Legacy-Asset mit Struktur `Voyage/Content` extrahieren.
2. Den vollständigen vorherigen Wireless-Ressourcen-Build als Legacy-Baum mit `scriptobjects.bin` bereitstellen: 58 Pakete vor bzw. 76 Pakete nach der Icon-Erweiterung. Eine alte Fassung mit nur elf Geräten enthält die neuen Ressourcen nicht und wird abgewiesen.
3. `python tools/build_icons.py --mapping <Voyage.usmap> --stock <Stock-Legacy-Baum> --wireless-source <Wireless-Legacy-Baum> --retoc <retoc.exe> --output <neuer Ausgabeordner>` ausführen.
4. Die unveränderte `CaretakerWirelessFix_P.tlcaddon.json` und beide vollständigen Lua-Modordner aus demselben Ressourcen-Build zusammen mit den drei neu erzeugten Containerdateien ausliefern. Der Icon-Builder erzeugt nur die Container, keine Registrierungsdatei oder Lua-Mods.

`icons.json` beschreibt die 20 Icons und 29 Item-/Skill-Bindungen. `original` benennt den bisherigen Icon-Import; `template` optional eine andere Stock-Textur als Pixelformatvorlage. Der Builder unterstützt bereits zugewiesene Ziel-Imports, prüft die Texture2D-Klasse, erhält die Import-Indizes und erzeugt transparente 256×256-BGRA8-Texturen. Seine Ausgabe enthält 76 Pakete.

PNG-Quellen und Prompts: `assets/icons`. Eine offline erzeugte Übersicht aus den gepackten 256-Pixel-Quellen erstellt `powershell -File tools/preview_resource_icons.ps1 -Reports <Build-Ausgabe>/reports`; sie ersetzt keinen UI-Test im Spiel.

Danach SHA-256 und Dateigrößen in `Dateien.json` aktualisieren. `python tools/package_release.py` prüft alle 15 installierbaren Dateien und erzeugt `Caretaker-Wireless-Fix-1.0.0.zip` mit Prüfsumme. Version bleibt 1.0.0.
