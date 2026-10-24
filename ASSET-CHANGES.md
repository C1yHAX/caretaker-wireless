# Bearbeitete Spielassets

Elf vorhandene Paketpfade werden überschrieben. Hinzu kommen zwei eigene Icontexturen und 45 Ressourcen-Assets, insgesamt **58 Pakete**. AssetBridge registriert **18 neue Items und neun Skills**. Die 13 bisherigen Assetpakete und ihre Geräteidentitäten bleiben bytegleich zur vorherigen Icon-Fassung.

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

## Neue Ressourcenpakete

Pro Ressource in `resources.json` liegen unter `/Game/CaretakerWireless/` fünf neue Pakete:

```text
Blueprints/BP_Wireless_<Resource>_Transmitter
Blueprints/BP_Wireless_<Resource>_Receiver
Items/DA_Wireless_<Resource>_Transmitter
Items/DA_Wireless_<Resource>_Receiver
Skills/DA_Skill_Wireless_<Resource>
```

Eigenständige Klassenkopien mit passenden gegenseitigen Referenzen, typisierten Schlauchanschlüssen, nativen Anschlussgrafiken und einem zusätzlichen elektrischen Sendereingang. Ressourcenpuffer, Durchsatz, Rezepte, Texte und Freischaltungen stehen in README/resources.json. Die Eigenbedarfsberechnung berücksichtigt den zusätzlichen lokalen Anschluss. Sender suchen nur ihren jeweiligen Empfängertyp.

`devices.lua` erweitert Ö-Bedienung und aktuelle/gespeicherte Netzerkennung. Ein gemeinsamer Persistenzkomponenten-Scan findet alle Typen; die bisherigen Schutzgrenzen bleiben. Der Container ist fertig gebaut; ein vollständiger Editor-/Asset-Build ist weiterhin nicht Bestandteil des Repositories.
