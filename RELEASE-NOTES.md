# Caretaker Wireless Fix 1.0.0

**Universal-Funksender und Universal-Funkempfänger:** ein Gerätepaar für Strom, Benzin, Diesel, Rohöl, Frischwasser, Salzwasser, Sauerstoff, CO₂, Methan und Dampf. Je zehn getrennte Kabel-/Schlauchanschlüsse, ein gemeinsamer Ö-Kanal und 1.000 m Reichweite. Beide Geräte über **Universelle Funkversorgung ab Level 22 für vier Skillpunkte**. Nicht benötigte Ressourcenanschlüsse dürfen frei bleiben.

Der Universal-Empfänger benötigt einen Universal-Sender. Der Universal-Sender unterstützt außerdem die bisherigen einzelnen Empfänger. Die bisherigen Geräte bleiben erhalten. **3 kW Grundlast + 1 kW je Empfängergerät** am Sender: ein Universal-Paar benötigt 4 kW Eigenbedarf, zusätzlich zum weitergeleiteten Strom. Zehn Ausgänge eines Empfängers zählen nur einmal.

Das Paket enthält außerdem die bisherigen Funkstrom-Reparaturen und neun einzelne Ressourcenpaare. Kanäle 1–9999 mit **Ö** öffnen, ein gemeinsamer Hintergrundscan für 22 Gerätetypen und begrenztes Nachladen verbundener Versorgungsbereiche. Die Standard-Kabelbedienung bleibt verfügbar. Ressourcen-Icons: Benzin rot, Diesel gelb, Methan gedecktes Graugrün; die übrigen Ressourcen besitzen eigene Farben. Die beiden Universal-Geräte haben unterschiedliche mehrfarbige Sende-/Empfangs-Icons.

Einzelpaare werden für zwei Punkte freigeschaltet: Level 18 Benzin/Diesel/Frischwasser/Salzwasser, Level 20 Rohöl/Sauerstoff/CO₂/Dampf, Level 21 Methan. Je Flüssigkeits-/Gasanschluss nominell 72.000 Einheiten/h, tatsächlicher Durchsatz abhängig vom Spielnetz. Universal-Sender: 20 Kunststoff + 20 Eisen; Universal-Empfänger: 16 Kunststoff + 16 Eisen.

## Installation

Für den geprüften Spielbuild **0.10.0.653173 / Steam 25982825**. **UE4SS v3.0.1-1125-g527a483b** und **AssetBridge 0.4.0** werden separat benötigt; Links und Prüfsummen stehen in README.md. Das Spiel schließen, ZIP entpacken und den enthaltenen Voyage-Ordner in den Spielinstallationsordner kopieren. Die Anleitung und der optionale Installer stehen im Repository. Alte Wireless-Paketdateien ersetzen und nur eine Kopie laden. Anschließend vollständig neu starten.

Alle 15 Installationsdateien sind im Dateikatalog des Repositorys aufgeführt. 83 Assetpakete, 30 zusätzliche Item-/Skill-Registrierungen, 22 Icons. Vollständige Anschlussanleitung: **UNIVERSAL.md**. Die vorhandene gemeinsame Freischaltung enthält beide Universal-Geräte; den neuen Empfänger separat herstellen.

## Prüfstatus

78 bisherige Pakete bytegleich; nur Universal-Sender und gemeinsamer Skill angepasst, drei neue Pakete. Anschlusszuordnung, Abmeldung aller Ausgänge bei Kanal-/Reichweitenwechsel, Stromsperre und Wiederanlauf, gemeinsame Freischaltung, eindeutige Anschluss-IDs, Blueprint-Sprünge, Rückextraktion und Konfliktprüfung bestanden. Sieben Lua-Tests prüfen Kanalbedienung, gespeicherte Netze und Hintergrund-Erkennung, darunter drei neue Tests für das Universal-Paar mit allen zehn Ressourcen und der Kabelwiederherstellung. Tests des serialisierten Blueprint-Kontrollflusses verwenden simulierte native Aufrufe.

**Der Spieltest des gleichzeitigen nativen Durchflusses, der Anschlussbedienung/Platzierung, des Verwertens und des Speicherns/Ladens steht aus.** Das Spiel wurde für diese Änderung nicht gestartet. Die Offline-Tests ersetzen keine Prüfung der echten Engine-Simulation. Version bleibt **1.0.0**.

Der Hintergrundschutz gilt für alle zehn Ressourcen einschließlich Quellen, Verbraucher und Kabel. Die Umgebung darf entladen werden; die benötigten Geräte bleiben aktiv. Er läuft nur während des Spiels und bis zu den Schutzgrenzen von 256 Gerätebereichen / 2.048 Objekten. Ein nativer Spieltest des Universal-Paars mit allen Ressourcen steht weiterhin aus.

## Inhalt des Mod-Downloads

Das Release-ZIP enthält ausschließlich die zum Betrieb benötigten Moddateien in der `Voyage`-Ordnerstruktur. Anleitung, Änderungslisten, Lizenztexte, Drittanbieterhinweise, Entwicklungswerkzeuge und Prüfberichte bleiben im Repository bzw. auf der Release-Seite. Sie werden nicht mit ins Mod-ZIP gepackt. Die Prüfsumme ist ein separater Download. Version bleibt **1.0.0**.
