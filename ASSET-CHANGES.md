# Bearbeitete Spielassets

Elf vorhandene Paketpfade werden überschrieben. Hinzu kommen 22 eigene Icontexturen und 50 Ressourcen-/Universal-Assets, insgesamt **83 Pakete**. AssetBridge registriert **20 neue Items und zehn Skills**. Die elf bisherigen Spielasset-Overrides und zwei Funkstrom-Icons bleiben bytegleich zur vorherigen Fassung.

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

## Ressourcen-Icons (1.0.0)

18 Texturen unter `/Game/CaretakerWireless/Icons/Icon_Wireless_<Resource>_<Transmitter|Receiver>`. Die 18 Ressourcen-Items und neun Skills referenzieren diese neuen Texturen. Alle bisherigen 58 Export-Payloads bleiben bytegleich; nur 27 Asset-Header ändern je zwei Icon-Namen. Insgesamt 76 Pakete, unverändert 27 AssetBridge-Registrierungen. `icons.json` enthält alle 20 Texturen und 29 Bindungen. Die beiden Funkstrom-Icons bleiben bytegleich.

## Universalsender (1.0.0)

Vier additive Pakete: `/Game/CaretakerWireless/Blueprints/BP_Wireless_Universal_Transmitter`, `Items/DA_Wireless_Universal_Transmitter`, `Skills/DA_Skill_Wireless_Universal` und `Icons/Icon_Wireless_Universal_Transmitter` unter demselben Basisverzeichnis. Alle 76 bisherigen Pakete bleiben bytegleich. Eine explizite Liste der zehn vorhandenen Empfängerklassen erweitert die Senderzuordnung; alle Empfängerfunktionen bleiben unverändert. Neun optionale Ressourceneingänge, ein benötigter Stromeingang, zehn native Puffer. Zwei neue AssetBridge-Einträge. Die gemeinsamen devices.lua-Listen erkennen zusätzlich den Universalsender. Keine weiteren Laufzeitskripte.

## Universal-Empfänger (aktueller Stand 1.0.0)

Drei additive Pakete: `Blueprints/BP_Wireless_Universal_Receiver`, `Items/DA_Wireless_Universal_Receiver` und `Icons/Icon_Wireless_Universal_Receiver` unter `/Game/CaretakerWireless/`. Ein platzierter Actor mit zehn nativen Ausgängen und wiederverwendeten Anschlussplatten; keine untergeordneten Sender/Empfänger-Actors. Alle Anschlüsse werden zusammen registriert, bei Kanal-/Reichweitenwechsel abgemeldet und bei Stromausfall gesperrt. Eigene, pro Instanz und Ressource unterschiedliche Socket-IDs.

Zwei vorhandene Pakete geändert: der Universal-Sender akzeptiert zusätzlich die neue Empfängerklasse und berechnet Verbindungsstrom anhand unterschiedlicher Besitzer seiner externen Anschlüsse; der vorhandene Skill schaltet beide Universal-Geräte frei. 78 der vorherigen 80 Pakete bleiben bytegleich. Ein neuer AssetBridge-Item-Eintrag, insgesamt 30. Gemeinsame Gerätefilter erweitert auf 22 Klassen. 83 Pakete und 22 Icons mit 32 Bindungen. Keine zusätzlichen Laufzeit-Schleifen oder Ressourcen-Kopierskripte.

Prüfnachweis: verification/universal-receiver-tests.json. Kontrollflussprüfung führt die serialisierten Blueprint-Ausdrücke mit simulierten nativen Aufrufen aus; sie prüft keine echte Unreal-Ressourcen-Simulation. Die früheren Abschnitte beschreiben die jeweiligen vorherigen Erweiterungsschritte.
