# Caretaker Wireless Fix 1.0.0 – Strom und Ressourcen

**1.000 m Funkübertragung für Strom und neun weitere Ressourcen:** Benzin, Diesel, Rohöl, Frischwasser, Salzwasser, Sauerstoff, CO₂, Methan und Dampf. 18 zusätzliche Geräte, getrennte Kanäle 1–9999 mit **Ö**, native Schlauchanschlüsse und Hintergrundbetrieb. Ressourcen-Sender benötigen einen separaten Stromanschluss. Die bisherigen Stromgeräte und unterschiedlichen Sender-/Empfänger-Icons bleiben enthalten.

Freischaltung je Paar für zwei Punkte: Level 18 Benzin/Diesel/Frischwasser/Salzwasser, Level 20 Rohöl/Sauerstoff/CO₂/Dampf, Level 21 Methan. Senderbedarf 1 kW + 1 kW je Empfänger; 1.000-Einheiten-Puffer und nominal 72.000 Einheiten/h Schlauchrate.

## Download und Installation

`Caretaker-Wireless-Fix-1.0.0.zip` entpacken. Voraussetzung: Spiel **0.10.0.653173 / Build 25982825**, **UE4SS v3.0.1-1125-g527a483b** und zusätzlich **AssetBridge 0.4.0**. Autorenlinks und Anleitung stehen in der README. Bei geschlossenem Spiel `Install-Wireless.ps1 -GamePath '<Spielordner>'` ausführen oder den enthaltenen `Voyage`-Ordner in den Spielordner kopieren. Alle vier Container-/Registrierungsdateien und beide Lua-Modordner zusammen verwenden. Eine vorhandene Fassung am selben Ziel ersetzen.

**Neue Ressourcenpaare: Offline-Prüfungen bestanden; nativer Durchfluss-, Platzierungs- und Speichern/Laden-Test steht aus.** Kein Spielstart für diese Erweiterung. Frühere native Stromtests sind kein Nachweis für die zusätzlichen Gas-/Flüssigkeitsgeräte.

Version bleibt 1.0.0; `SHA256SUMS.txt` enthält die aktuellen Download-Prüfsummen.

## Farbige Ressourcen-Icons – weiterhin 1.0.0

18 eigene Icons unterscheiden alle Ressourcenpaare; neun Freischaltungen nutzen die passenden Symbole.

| Ressource | Iconfarbe |
|---|---|
| Benzin | Rot |
| Diesel | Gelb |
| Methan | Gedecktes Graugrün, an die Methan-Tanks angelehnt |
| Rohöl | Braun / Kupfer |
| Frischwasser | Blau |
| Salzwasser | Türkis |
| Sauerstoff | Eisblau |
| CO₂ | Violett |
| Dampf | Silbergrau |

Sender: hohe Antenne mit ausgehendem Pfeil. Empfänger: flacher Anschluss mit eingehendem Pfeil. Statische 256×256-Texturen ohne neue Laufzeitskripte. Bestehende Geräte behalten ihre Identität. Installation durch Ersetzen der bisherigen Paketdateien; Anleitung in README.md. Exportdaten, Icon-Referenzen, Transparenz und Rückextraktion offline geprüft. Nativer UI-Test der neuen Icons steht aus; kein Spielstart für diese Änderung.
