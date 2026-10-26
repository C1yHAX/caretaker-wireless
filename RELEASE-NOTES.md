# Caretaker Wireless Fix 1.0.0

**Ressourcenverlust behoben:** Volle Flüssigkeits- und Gaspuffer bleiben erhalten. Ohne Abnahme stoppt der Zufluss; nach einer Entnahme läuft er wieder an. Alle neun Ressourcen an einzelnen Sendern und am Universal-Sender wurden in einem separaten Testprofil geprüft. [Messbericht](https://github.com/C1yHAX/caretaker-wireless/blob/main/verification/resource-conservation-20261026.json).

Der Universal-Funksender behält das freigegebene Antennenmodell mit drei
Standfüßen, 5,024 m Höhe und 48 cm senkrechtem Anschlussabstand. Die Anschlüsse
ragen aus dem Gehäuse, die Lackierung geht in die ursprünglichen Gehäuseränder
über, und drei echte Lichtquellen ergänzen die emissiven Flächen. Die aktuelle
Pufferkorrektur verändert das Aussehen nicht.

Der Universal-Sender versorgt die einzelnen Empfänger für Strom, Benzin,
Diesel, Rohöl, Frischwasser, Salzwasser, Sauerstoff, CO₂, Methan und Dampf.
Reichweite 1.000 m; Kanäle 1–9999 über Ö aus der Nähe. E/F bleiben für Kabel frei.
3 kW Sender-Grundbedarf plus 1 kW je verbundenem Empfängergerät.

Sender und Empfänger haben getrennte Fähigkeiten, einschließlich der beiden
Stromgeräte. Bereits verdiente Baupläne und frühere Paarfreischaltungen werden
berücksichtigt. Der Universalempfänger wird nicht mehr neu angeboten; seine
Kennungen bleiben zum Laden vorhandener Geräte erhalten. Der Universal-Sender
bleibt ab Level 22 verfügbar. Aktuelle Skillkosten: null Punkte.

## Geprüft

Aktuelle Pufferkorrektur: automatisierte Mengenmessungen im laufenden Spiel mit
komplettem Modpack und separatem Testspielstand. Alle neun Flüssigkeits- und
Gasressourcen am jeweiligen Einzelsender und am Universal-Sender: unverbundene
Empfänger, leere und volle Zieltanks, Nachfüllen nach 250 Einheiten Entnahme und
Betrieb auf große Spielerentfernung. In den aufgezeichneten Messungen keine
Bilanzabweichung. Die Stromübertragung wurde zusätzlich geprüft; der reguläre
Stromverbrauch ist davon ausgenommen. Der originale CO₂-Tank lässt oberhalb von
99,9 % absichtlich Gas ab; zur Prüfung der Wireless-Bilanz dient ein geschlossener
Testbehälter. Originalbehälter wurden nicht geändert.

Frühere Bedienprüfung der Antenne, ebenfalls im separaten Testspielstand mit
komplettem Modpack: normaler Neubau und
Materialverbrauch, Dieselschlauch an beiden Enden mit E, tatsächlicher Zufluss,
Ö-Menü und Kanaländerung, Betriebsanzeige sowie Speichern und erneuter Kaltstart.
Zusätzlich nativer Übertragungstest aller zehn Ressourcen bei 997 m Abstand
zwischen Sender und Empfängern, auch bei über 18 km Spielerentfernung.
15 Skripttests bestanden. Ein vollständiger manueller Abriss-/Kabeltest aller
Geräte und ein Langzeit-Leistungstest großer Fabriken sind nicht enthalten.
Details: [Prüfbericht](https://github.com/C1yHAX/caretaker-wireless/blob/main/verification/antenna-revision2-20261026.json).

## Installation

Für The Last Caretaker 0.10.0.653173 / Steam-Build 25982825 mit separat installiertem
UE4SS v3.0.1-1125-g527a483b und AssetBridge 0.4.1.

1. Spiel schließen.
2. **Caretaker-Wireless-Fix-1.0.0.zip** herunterladen und entpacken.
3. Den enthaltenen **Voyage**-Ordner in den Spielinstallationsordner kopieren
   und die bisherigen Dateien ersetzen. Alle **20 Dateien** gehören zusammen,
   einschließlich der drei neuen **CaretakerAntenna_P**-Containerdateien.
4. Spiel vollständig neu starten. Vorhandene Sender behalten ihre Identität,
   benötigen mit dem größeren Gehäuse aber mehr freien Platz.

[Ausführliche Anleitung und Abhängigkeiten](https://github.com/C1yHAX/caretaker-wireless#installation).
Im kompletten Modpack ist diese Fassung bereits enthalten; dort keine zweite
Wireless-Kopie hinzufügen. Version bleibt **1.0.0**. Der benannte Mod-Download
enthält ausschließlich Laufzeitdateien, ohne Dokumentation, Bilder, Entwicklungs-
oder Testwerkzeuge. **SHA256SUMS.txt** ist ein separater Prüfsummen-Download.
