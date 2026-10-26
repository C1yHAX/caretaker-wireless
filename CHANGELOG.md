# Änderungen

### Pufferkorrektur vom 26.10.2026 innerhalb 1.0.0

- Volle Flüssigkeits- und Gaspuffer werden nicht mehr durch die geerbte Durchflusslogik geleert. Ohne Abnahme stoppt der Zufluss; Entnahmen werden regulär nachgeliefert.
- Gilt für alle neun einzelnen Ressourcensender und den Universal-Sender mit den jeweiligen Empfängern. Die Anzeigen nutzen denselben Puffer.
- Im kompletten Modpack mit separatem Testspielstand geprüft: 18 Ressourcenkombinationen ohne angeschlossenen Verbraucher, mit leeren/vollen Zieltanks, nach 250 Einheiten Entnahme und auf große Spielerentfernung. Zusätzlich Stromübertragung geprüft. Keine Bilanzabweichung in den Messdaten.
- Das freigegebene Antennenmodell, Materialien, Lichter und Anschlusspositionen bleiben unverändert. Version 1.0.0, nur Laufzeitdateien in den ZIPs.
- [Messumfang und Einschränkungen](verification/resource-conservation-20261026.json), [technische Ursache](BUILDING-BUFFERS.md).

### Korrekturen vom 25.10.2026 innerhalb 1.0.0

- Voller Bauplanspeicher: Kapazität vor dem Laden erweitern und ausschließlich bereits verdiente Wireless-Baupläne wiederherstellen.
- Entfernte gespeicherte Netze regulär initialisieren; nur simulierende Physikkörper sperren; gepoolte Funkgeräte ignorieren.
- Native Prüfung aller Einzelpaare, des Universalpaars, der Wandanschlüsse und Signalrelais im vollständigen Modpack.
- Zwölf Offline-Lua-Tests. 17 Laufzeitdateien im separaten ZIP; Version unverändert.
- Historische Prüfstände unten werden durch den aktuellen Bericht vom 25.10.2026 ergänzt.

## 1.0.0 – Erstrelease, 24. Oktober 2026

- Bestehende Funkstrom-Reparaturen, 1.000 m, Ö-Kanäle 1–9999, Hintergrundbetrieb, zwei unterschiedliche Icons und 50-m-Wandbrücken.
- Neu: neun Ressourcenpaare für Benzin, Diesel, Rohöl, Frischwasser, Salzwasser, Sauerstoff, CO₂, Methan und Dampf.
- 18 Geräte und neun Freischaltungen auf Level 18–21; AssetBridge 0.4.0 jetzt zusätzlich erforderlich.
- Sender mit getrennten Strom-/Ressourcen-Eingängen, 1.000-Einheiten-Puffer und nominal 72.000 Einheiten/h Schlauchrate.
- Gemeinsame Hintergrund-Gerätesuche alle fünf Sekunden statt einer Suche pro Ressourcenklasse.
- Offline-Asset-/Referenz-/Rückextraktionsprüfung und Lua-Tests bestanden. Nativer Spieltest der zusätzlichen Ressourcenpaare steht aus.

Version bleibt auf ausdrücklichen Wunsch **1.0.0**. Die Release-Dateien wurden um die Ressourcen erweitert; aktuelle Prüfsummen beachten. Frühere Fassungen enthielten die ursprünglichen Funkstrom-Geräte und Wandbrücken-/Datenkorrekturen.

### Ressourcen-Icons innerhalb des Erstreleases 1.0.0

18 neue farbige Sender-/Empfänger-Icons, einschließlich Rot für Benzin, Gelb für Diesel und gedecktem Tank-Graugrün für Methan. Neun passende Skill-Icons. Keine Änderungen an Durchsatz, Kanälen, Freischaltungen oder Lua-Laufzeit. Offline geprüft; nativer UI-Test ausstehend.

### Universalsender innerhalb des Erstreleases 1.0.0

Ein zusätzlicher Sender überträgt Strom und alle neun Flüssigkeits-/Gasressourcen. Zehn getrennte Eingänge, vorhandene Empfänger, 1.000 m, gemeinsamer Ö-Kanal, Level 22 / vier Punkte und eigenes mehrfarbiges Icon. Grundlast 3 kW plus 1 kW je Empfänger. Offline geprüft; nativer Durchfluss und Anschlussbedienung stehen aus.

### Universal-Empfänger innerhalb des Erstreleases 1.0.0

Ein zusätzlicher Empfänger für alle zehn Ressourcen, mit getrennten Kabel-/Schlauchausgängen und eigenem mehrfarbigen Empfangs-Icon. Gemeinsame Freischaltung mit dem Universal-Sender auf Level 22 / vier Punkte. Ein gemeinsamer Ö-Kanal. Der Sender zählt Empfängergeräte statt ihrer Anschlüsse, sodass ein Universal-Empfänger 1 kW Verbindungsbedarf verursacht. Alle Ausgänge folgen Strom-, Kanal- und Reichweitenwechseln. Native Spieltests bleiben ausstehend.

### Anschluss- und Rückkehrkorrektur innerhalb 1.0.0

36 typisierte Anschlüsse behalten jetzt ihre richtige Ressource bei der nativen
Initialisierung. Die native Rückkehrkorrektur verhindert erneute Netzverteilung
für bereits aktuelle Anlagen. Der Spieltest mit dem Universal-Paar bestand für
alle zehn Ressourcen bei entladener Umgebung und bei der Rückkehr. Ein getrenntes
Stock-Wassernetz wurde weiterhin regulär nachberechnet. Acht Lua-Tests und die
nativen Entscheidungstests bestehen. 16 reine Laufzeitdateien im Download-ZIP;
Dokumentation, Quellen und Lizenztexte bleiben auf den Projektseiten.
