# Caretaker Wireless Fix 1.0.0

## English

The mod automatically follows the game language: German for German, English for English, with English as the fallback for other languages. In-game language changes are picked up automatically.

Wireless transfer for ten resources, individual receivers and the accepted universal antenna; 1,000 m range and channels 1–9999. Full liquid/gas buffers stop intake and retain their contents.

**Channel-key configuration:** Close the game and edit `Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessControls/Scripts/config.lua`. Set `KeyName = 'F8'` and `Modifiers = {}` for F8, or `Modifiers = {'CONTROL'}` for Ctrl+F8, then restart. Other examples: F9, K, HOME. The default OEM_THREE retains German Ö / US backtick. Game descriptions refer to the configured channel key. Key names are case-insensitive; invalid settings or detected UE4SS key conflicts are logged without stopping recipe recovery. Back up your edited config before updating and reapply your key settings afterwards.

**Requirements:** [UE4SS v3.0.1-1125-g527a483b](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1125-g527a483b.zip) and [AssetBridge 0.4.1](https://www.nexusmods.com/thelastcaretaker/mods/225), installed separately. Tested target: The Last Caretaker 0.10.0.653173 / Steam build 25982825, Windows.

**Install/update:** Close the game. Extract `Caretaker-Wireless-Fix-1.0.0.zip` and merge its `Voyage` folder into the game installation, replacing the previous mod files. All 22 runtime files belong together. Remove duplicate older Wireless packages. Restart. The complete modpack is not required.

**Verification:** 24 offline Lua tests passed, including configurable keys/modifiers, conflict handling, malformed configuration, game-thread dispatch and existing resource/recipe tests. 120 actual asset texts were verified in the game engine for en, de, en-US, de-DE and English fallback using a separate empty profile. Original save/config hashes are unchanged. Antenna assets, buffer fixes and native code are unchanged; earlier game-test evidence remains in the repository.

## Deutsch

Die Mod folgt automatisch der Spielsprache: Deutsch bei deutscher Sprache, Englisch bei englischer Sprache. Für andere Spielsprachen wird Englisch verwendet. Ein Sprachwechsel im Spiel wird übernommen.

Funkübertragung für zehn Ressourcen, einzelne Empfänger und die freigegebene Universalantenne; 1.000 m Reichweite und Kanäle 1–9999. Volle Flüssigkeits-/Gaspuffer stoppen die Aufnahme und behalten ihren Inhalt.

**Kanaltaste einstellen:** Spiel schließen und `Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessControls/Scripts/config.lua` bearbeiten. Für F8 `KeyName = 'F8'` und `Modifiers = {}`, für Strg+F8 `Modifiers = {'CONTROL'}` setzen; danach neu starten. Weitere Beispiele: F9, K, HOME. Standard OEM_THREE bleibt deutsches Ö / US-Backtick. Spielbeschreibungen verweisen auf die konfigurierte Kanaltaste. Groß-/Kleinschreibung ist egal; ungültige Einstellungen oder erkannte UE4SS-Tastenkonflikte werden protokolliert, ohne die Bauplanwiederherstellung zu stoppen. Eigene Config vor Updates sichern und die Tasteneinstellungen anschließend übernehmen.

**Voraussetzungen:** [UE4SS v3.0.1-1125-g527a483b](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1125-g527a483b.zip) und [AssetBridge 0.4.1](https://www.nexusmods.com/thelastcaretaker/mods/225), separat installieren. Zielversion: The Last Caretaker 0.10.0.653173 / Steam-Build 25982825, Windows.

**Installation/Update:** Spiel schließen. `Caretaker-Wireless-Fix-1.0.0.zip` entpacken und den `Voyage`-Ordner in den Spielinstallationsordner kopieren; bisherige Mod-Dateien ersetzen. Alle 22 Laufzeitdateien gehören zusammen. Doppelte ältere Wireless-Pakete entfernen. Neu starten. Das vollständige Modpack ist nicht erforderlich.

**Prüfung:** 24 Offline-Lua-Tests bestanden, einschließlich Tasten/Zusatztasten, Konflikten, fehlerhafter Konfiguration, Ausführung im Spielthread sowie bestehenden Ressourcen-/Bauplantests. 120 tatsächliche Asset-Texte wurden mit separatem leerem Testprofil in der Spielengine für en, de, en-US, de-DE und englischen Fallback geprüft. Die Hashes des Originalspielstands und seiner Einstellungen sind unverändert. Antennenassets, Pufferkorrekturen und nativer Code sind unverändert; frühere Spieltestberichte bleiben im Repository.

Version **1.0.0**. ZIP: required runtime files only / ausschließlich benötigte Mod-Dateien. SHA256SUMS.txt is a separate attachment / separate Prüfsummendatei.

Credits: C1yHAX / c0d1ngf1eber (mod)
