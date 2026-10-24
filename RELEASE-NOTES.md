# Caretaker Wireless Fix 1.0.0 – Erstrelease

Erste öffentliche Fassung der eigenständigen Wireless-Mod für **The Last Caretaker 0.10.0.653173 / Steam-Build 25982825**.

## Verbesserungen gegenüber den Original-Spielassets

- **Unterschiedliche Icons:** Sender mit orangefarbenen ausgehenden Funkwellen, Empfänger mit blauen eingehenden Funkwellen. Transparent, gut in kleiner Darstellung unterscheidbar.
- **1.000 m Funkstrom** statt 10 m.
- **Kanäle 1–9999** für getrennte Stromnetze; Einstellung direkt am Sender oder Empfänger mit **Ö**. E/F bleiben für normale Kabelaktionen verfügbar.
- Reparierte Strom-/Datenanschlüsse, regulärer Empfänger-Ausgang und zerlegbarer Empfänger.
- Stabile Zuordnung bei überlappenden Sendern und Ersatzsender bei Versorgungsausfall auf demselben Kanal.
- Native Fernsimulation der benötigten Geräte bei entladener Umgebung; begrenzte Netzprüfung alle fünf Sekunden.
- **50-m-Wandbrücken** und eindeutige deutsche Namen/Beschreibungen. Die Wandbrücken-Reichweite war bereits Bestandteil der zuvor genutzten „Longer Wireless Cables“-Mod.
- Transparente Balance: 1-kWh-Senderpuffer, 1 kW Grundbedarf plus 1 kW pro Empfänger, zusätzlich zur übertragenen Leistung. Sieben Itemdefinitionen behalten Modpack-Gewicht 0 / Stapelgröße 99.999.

## Download und Installation

Die Datei **`Caretaker-Wireless-Fix-1.0.0.zip`** herunterladen. `SHA256SUMS.txt` enthält ihre Prüfsumme. Die automatisch erzeugten Quellcodearchive sind nicht der empfohlene Installationsdownload.

Zusätzlich erforderlich: [UE4SS v3.0.1-1125-g527a483b vom Originalprojekt](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1125-g527a483b.zip). UE4SS separat unter `Voyage/Binaries/Win64` installieren. Anschließend bei geschlossenem Spiel das Mod-ZIP entpacken und ausführen:

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-Wireless.ps1 -GamePath 'E:\Games\steamapps\common\Voyage'
```

Das vollständige Modpack und AssetBridge sind nicht erforderlich. Ältere zusätzliche Kopien von `CaretakerWirelessFix` und `zLong_Wireless_Cables_P` aus `Paks` herausnehmen. Im Modpack ab 1.0.0 bereits enthalten: nicht doppelt installieren. Bestehende Geräte behalten ihre Identität.

## Prüfstatus

Kontrollierte Engine-Tests für Stromfluss, Reichweite, Ausfall, Kanaltrennung, entfernte Simulation und Bedienung sind dokumentiert. Der Ö-Callback wurde programmgesteuert ausgelöst; native E/F-Kabelaktionen wurden an beiden Geräten erfolgreich ausgeführt. Kein vollständiger Langzeittest großer bestehender Fabriken oder beliebiger Modkombinationen. Die beschriebenen Testgrenzen gelten für diesen Erstrelease. Details, Grenzen und Herkunftsangaben stehen im beiliegenden README.

English: extends existing game devices with 1,000 m wireless power, independent channels, repaired sockets/dismantling, and background simulation. Requires the linked UE4SS build; no full modpack or AssetBridge needed. German in-game text; configurable Ö hotkey. Download the named installable ZIP above.
