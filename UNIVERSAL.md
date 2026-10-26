# Universal-Sender mit einzelnen Ressourcenempfängern

Der Universal-Funksender bleibt für Strom, Benzin, Diesel, Rohöl, Frischwasser,
Salzwasser, Sauerstoff, CO₂, Methan und Dampf vorgesehen. Am Ziel werden die
jeweiligen einzelnen Ressourcenempfänger verwendet.

## Entfallener Universalempfänger

Der Universalempfänger wird nicht mehr zur Herstellung oder regulären
Freischaltung angeboten. Sein Item, Blueprint und Skill behalten ihre bisherigen
Kennungen, damit vorhandene Spielstände und bereits gebaute Geräte weiterhin
aufgelöst werden können. Die Zerlegefunktion bleibt erhalten. Vorhandene Geräte
werden nicht automatisch gelöscht oder umgewandelt; gespeicherte Baupläne und
Fähigkeiten werden nicht aus Spielständen entfernt.

Die native Gegenstandsdefinition hat CraftFilter 0, bUnlockAsBuildable false und
IsScannable false. Die alte Fähigkeit verwendet UnlockMethod Never, eine leere
Items-Liste und bExcludeFromDistribution true. Die Bauplanwiederherstellung
vergibt das entfallene Gerät nicht neu. Die Registrierung bleibt für alte
Spielstände vorhanden.

## Anschließen

1. Universal-Sender ab Level 22 freischalten. Die aktuelle Korrekturfassung hat
   getrennte Freischaltungen mit null Skillpunktkosten.
2. Stromversorgung und gewünschte Ressourcenquellen an die zugehörigen Eingänge
   des Senders anschließen.
3. Den Sender anvisieren und mit Ö einen Kanal von 1 bis 9999 wählen.
4. Passende einzelne Empfänger auf denselben Kanal stellen und mit Verbrauchern
   verbinden. Diesel und Methan verwenden weiterhin ihre getrennten Anschlüsse.

Die Reichweite bleibt 1.000 m. Der Sender-Eigenbedarf beträgt 3 kW plus 1 kW je
verbundenem Empfängergerät, zusätzlich zur übertragenen elektrischen Leistung.
Je Ressourcenanschluss gelten nominell 72.000 Einheiten/h, abhängig von Quelle,
Verbraucher und Netz. Die Mod erzeugt oder verwandelt keine Ressourcen.

## Gehäuseüberarbeitung

Der neue Sender ist 4,0952 m hoch. Die drei Standfüße liegen im Abstand von
120° mit ihren Sohlen auf Z=0. Zwei getrennte Montageplatten tragen je fünf
native Anschlüsse; vertikaler Mittelpunktabstand 36 cm. Die Anschlüsse wurden
im Spiel auf Abstand zur Verkleidung geprüft. Die ursprünglichen im generierten
Unterteil enthaltenen Scheinbuchsen wurden vollständig entfernt.

Eine kleine bündige Statusanzeige ersetzt die abstehende alte Warnlampe. Sie
verwendet die vorhandene native Stromstatuslogik. Der Mast verwendet die
vorbereiteten 4K-Farb-/Normaltexturen; die neue Basis verwendet einen 2K-Atlas.
Vier Detailstufen mit 9.523 / 6.000 / 3.499 / 1.799 Dreiecken und acht einfache
Kollisionskörper begrenzen den zusätzlichen Render- und Kollisionsaufwand.
Das ist keine Garantie für eine bestimmte Bildrate.

Die bisherige Blueprint-/Item-Identität und alle zehn Anschluss-IDs bleiben.
Bestehende Sender übernehmen die Darstellung beim nächsten Start. Das größere
Gehäuse kann an vorher engen Aufstellorten eine neue Position benötigen.

## Prüfstatus und Installation

Version bleibt 1.0.0. Alle 20 Laufzeitdateien des ZIP gehören zusammen,
einschließlich der drei neuen CaretakerAntenna_P-Containerdateien. Voraussetzungen
und Installation stehen in README.md. Der Universalempfänger wird nicht wieder
in Herstellung oder Freischaltung aufgenommen.

Am 26.10.2026 wurden in einer separaten Spielstandkopie normaler Neubau,
Dieselverkabelung mit E und realer Zufluss, Kanalmenü mit Ö und Kanaländerung,
Betriebsanzeige sowie Speichern/Kaltstart geprüft. Zusätzlich wurden alle zehn
Ressourcen in einem nativen Testaufbau geladen und bei großer Entfernung
übertragen. Manuelles Abreißen mit gehaltenem Werkzeug und jede einzelne
Ressourcenverkabelung wurden in dieser Prüfung nicht vollständig wiederholt.

Alle zwölf Blueprint-Funktionskörper und die Ressourcenparameter bleiben
unverändert. Der neue Artcontainer enthält neun eigene Assets. Aus der bisherigen
95-Asset-Fassung ändert sich ausschließlich der Universal-Sender-Blueprint.
Details und Grenzen stehen in verification/antenna-revision2-20261026.json.
