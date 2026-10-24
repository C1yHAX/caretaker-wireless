# Änderungen

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
