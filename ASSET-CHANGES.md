# Bearbeitete Spielassets

Alle elf Pfade existieren im geprüften Original-Spielbuild. Das Paket überschreibt diese Pfade; es registriert keine zusätzlichen Gegenstände oder Skills. Bestehende Geräte behalten ihre Identität.

| Paketpfad unter `/Game/` | Änderung |
|---|---|
| `Blueprints/Modules/Utility/Wireless/BP_Module_WirelessResourceTransmitter` | Stromanschluss, 1.000-m-Reichweite, Puffer und Energiefluss, stabile Senderzuordnung, gespeicherter Kanal und Dialogkontext |
| `Blueprints/Modules/Utility/Wireless/BP_WirelessResource_Socket_Base` | Stromausgang, native Modul-/Persistenz-/Zerlegeanbindung, Kanalfilterung und Dialogkontext |
| `Blueprints/Modules/Utility/Wireless/BP_WallSocket_Electric` | Gemeinsame Wandbrücken-Basisreichweite 50 m |
| `Blueprints/Modules/Utility/Signaling/Relays/BP_Module_Wireless_Relay` | Explizite Datenkabelkategorie |
| `Data/Assets/Cable/DA_Module_WirelessResourceTransmitter` | Name, Funktionsbeschreibung einschließlich Ö-Bedienung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WirelessResourceTransmitter_Socket_Electricity` | Name, Funktionsbeschreibung einschließlich Ö-Bedienung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_Wireless_Relay` | Abgrenzung zu Funkstrom, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Electric` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Fuel` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Gas` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |
| `Data/Assets/Cable/DA_Module_WallSocket_Water` | Deutsche Wandbrücken-Beschreibung, Modpack-Gewicht/Stapelgröße |

Die Ausführung von Hintergrundbetrieb und Ö-Tastenhandler erfolgt zusätzlich durch die beiden Lua-Modordner. Kein bestehender Blueprint-Kanalalgorithmus wurde für die Tastenänderung von 1.4.2 umgeschrieben. Der Installer kontrolliert die Datei-Hashes aus `Dateien.json`.
