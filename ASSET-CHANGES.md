# Bearbeitete Spielassets

Elf Pfade existieren im geprüften Original-Spielbuild und werden überschrieben. Hinzu kommen zwei eigene Icontexturen unter `/Game/CaretakerWireless/Icons/`, insgesamt 13 Pakete. Es werden keine zusätzlichen Gegenstände oder Skills registriert. Bestehende Geräte behalten ihre Identität.

| Paketpfad unter `/Game/` | Änderung |
|---|---|
| `Blueprints/Modules/Utility/Wireless/BP_Module_WirelessResourceTransmitter` | Stromanschluss, 1.000-m-Reichweite, Puffer und Energiefluss, stabile Senderzuordnung, gespeicherter Kanal und Dialogkontext |
| `Blueprints/Modules/Utility/Wireless/BP_WirelessResource_Socket_Base` | Stromausgang, native Modul-/Persistenz-/Zerlegeanbindung, Kanalfilterung und Dialogkontext |
| `Blueprints/Modules/Utility/Wireless/BP_WallSocket_Electric` | Gemeinsame Wandbrücken-Basisreichweite 50 m |
| `Blueprints/Modules/Utility/Signaling/Relays/BP_Module_Wireless_Relay` | Explizite Datenkabelkategorie |
| `Data/Assets/Cable/DA_Module_WirelessResourceTransmitter` | Eigenes Sender-Icon, Name, Funktionsbeschreibung einschließlich Ö-Bedienung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WirelessResourceTransmitter_Socket_Electricity` | Eigenes Empfänger-Icon, Name, Funktionsbeschreibung einschließlich Ö-Bedienung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_Wireless_Relay` | Abgrenzung zu Funkstrom, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Electric` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Fuel` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Gas` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Water` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `CaretakerWireless/Icons/Icon_WirelessPower_Transmitter` | Neue transparente 256×256-Icontextur: Antenne mit orangefarbenen ausgehenden Funkwellen |
| `CaretakerWireless/Icons/Icon_WirelessPower_Receiver` | Neue transparente 256×256-Icontextur: flacher Anschluss mit blauen eingehenden Funkwellen |

Die Ausführung von Hintergrundbetrieb und Ö-Tastenhandler erfolgt zusätzlich durch die beiden Lua-Modordner. Die Ö-Bedienung verwendet einen eigenen Tastenhandler; die Kanalzuordnung läuft im Blueprint. Der Installer kontrolliert die Datei-Hashes aus `Dateien.json`.
