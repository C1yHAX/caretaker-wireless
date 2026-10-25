# Caretaker Wireless Fix 1.0.0

## Reparaturen und vollständige Geräteprüfung vom 25.10.2026

**Freigeschaltet, aber im Baumenü fehlend:** Der native Bauplanspeicher war auf
1.024 Einträge begrenzt. Eine Fähigkeit konnte erfolgreich freigeschaltet werden,
obwohl für ihre beiden Geräte kein Platz mehr vorhanden war. Die Mod bereitet
den Bauplanspeicher vor dem Laden mit mindestens 4.096 Plätzen vor und stellt
fehlende, bereits durch Fähigkeiten oder Scans verdiente Wireless-Baupläne wieder
her. Sie vergibt keine neuen Fähigkeiten und löscht keine vorhandenen Einträge.
Normale Inventare und Materialanforderungen bleiben unverändert.

Nach der Installation vollständig neu starten, den Spielstand laden und etwa
zehn Sekunden warten. Das Baumenü danach neu öffnen. Bereits freigeschaltete
Fähigkeiten müssen nicht erneut gekauft werden. Jede Ressourcen-Fähigkeit
schaltet **Sender und Empfänger gemeinsam** frei; im Fähigkeitenbaum steht dafür
ein gemeinsamer Eintrag. Auch das Universalpaar teilt eine Freischaltung.

**Gerätezuordnung:** Der orange Funkstrom-Sender hat einen Stromanschluss. Der
gelbe Diesel-Funksender hat einen Strom- und einen Treibstoffanschluss. Die vier
Wandanschlussarten sind Strom, Treibstoff, Gas und Wasser; sie sind zusätzlich zu
den einzelnen Funkempfängern vorhanden. Ein Treibstoff-Wandanschluss deckt die
Treibstoffressourcen ab, ein Gas-Wandanschluss die Gasressourcen.

**Neustart und Fernbetrieb:** Gespeicherte entfernte Netze werden zunächst über
reguläre Streamingquellen des Spiels initialisiert. Höchstens vier temporäre
Quellen bestehen gleichzeitig; danach werden sie entfernt und die Umgebung
darf wieder entladen. Physiksperren betreffen ausschließlich tatsächlich
simulierende Körper. Bereits zerlegte, vom Spiel gepoolte Funkgeräte werden bei
der Gerätesuche ignoriert. Dadurch bleibt kein solcher Geräteeintrag als
zusätzlicher Hintergrund-Anker bestehen.

Mit dem vollständigen Modpack, unverändertem **Dynamic Grinder 1.0.1** und
**AssetBridge 0.4.1** wurden in einem separaten Testprofil geprüft: zehn
Fähigkeiten und ihre 20 neuen Baupläne; native Herstellung und Platzierung;
49 Ressourcenanschlüsse der 22 Funkgeräte; alle zehn Ressourcen über Einzel-
und Universalgeräte; Kanaltrennung; Entladung, Rückkehr und Kaltstart;
vier Wandbrückenarten sowie Signalrelais. Die Tests verwenden die tatsächlichen
Spielfunktionen. Sie sind keine manuelle Prüfung jedes Mausklicks.

Dampf wird mit eigens konfigurierten nativen Testreservoirs eingespeist. Deren
vorübergehende Ressourcenkonfiguration und Schlauchverbindung werden nach einem
Neustart erneut eingerichtet; die gespeicherten Funkgeräte bleiben dabei
unverändert. Ein Langzeittest beliebig großer Fabriken ist damit nicht ersetzt.
Der anonymisierte [Prüfbericht](verification/wireless-audit-20261025.json)
beschreibt den Umfang. Private Spielstände und Rohprotokolle werden nicht
veröffentlicht.

**Universal-Funksender und Universal-Funkempfänger:** ein Gerätepaar für Strom, Benzin, Diesel, Rohöl, Frischwasser, Salzwasser, Sauerstoff, CO₂, Methan und Dampf. Je zehn getrennte Kabel-/Schlauchanschlüsse, ein gemeinsamer Ö-Kanal und 1.000 m Reichweite. Beide Geräte über **Universelle Funkversorgung ab Level 22 für vier Skillpunkte**. Nicht benötigte Ressourcenanschlüsse dürfen frei bleiben.

Der Universal-Empfänger benötigt einen Universal-Sender. Der Universal-Sender unterstützt außerdem die bisherigen einzelnen Empfänger. Die bisherigen Geräte bleiben erhalten. **3 kW Grundlast + 1 kW je Empfängergerät** am Sender: ein Universal-Paar benötigt 4 kW Eigenbedarf, zusätzlich zum weitergeleiteten Strom. Zehn Ausgänge eines Empfängers zählen nur einmal.

Das Paket enthält außerdem die bisherigen Funkstrom-Reparaturen und neun einzelne Ressourcenpaare. Kanäle 1–9999 mit **Ö** öffnen, ein gemeinsamer Hintergrundscan für 22 Gerätetypen und begrenztes Nachladen verbundener Versorgungsbereiche. Die Standard-Kabelbedienung bleibt verfügbar. Ressourcen-Icons: Benzin rot, Diesel gelb, Methan gedecktes Graugrün; die übrigen Ressourcen besitzen eigene Farben. Die beiden Universal-Geräte haben unterschiedliche mehrfarbige Sende-/Empfangs-Icons.

Einzelpaare werden für zwei Punkte freigeschaltet: Level 18 Benzin/Diesel/Frischwasser/Salzwasser, Level 20 Rohöl/Sauerstoff/CO₂/Dampf, Level 21 Methan. Je Flüssigkeits-/Gasanschluss nominell 72.000 Einheiten/h, tatsächlicher Durchsatz abhängig vom Spielnetz. Universal-Sender: 20 Kunststoff + 20 Eisen; Universal-Empfänger: 16 Kunststoff + 16 Eisen.

## Installation

Für den geprüften Spielbuild **0.10.0.653173 / Steam 25982825**. **UE4SS v3.0.1-1125-g527a483b** und **AssetBridge 0.4.1** werden separat benötigt; Links und Prüfsummen stehen in der [Installationsanleitung](https://github.com/C1yHAX/caretaker-wireless#installation). Das Spiel schließen, ZIP entpacken und den enthaltenen Voyage-Ordner in den Spielinstallationsordner kopieren. Die Anleitung und der optionale Installer stehen im Repository. Alte Wireless-Paketdateien ersetzen und nur eine Kopie laden. Anschließend vollständig neu starten.

Alle 17 Installationsdateien sind im Dateikatalog des Repositorys aufgeführt. 83 Assetpakete, 30 zusätzliche Item-/Skill-Registrierungen, 22 Icons. Vollständige Anschlussanleitung: **UNIVERSAL.md**. Die vorhandene gemeinsame Freischaltung enthält beide Universal-Geräte; den neuen Empfänger separat herstellen.

## Prüfstatus

83 Assetpakete insgesamt. Die Anschlusskorrektur betrifft 36 Komponenten in 20 Blueprints; die übrigen 63 Pakete bleiben dabei bytegleich. Anschlusszuordnung, Abmeldung aller Ausgänge bei Kanal-/Reichweitenwechsel, Stromsperre und Wiederanlauf, gemeinsame Freischaltung, eindeutige Anschluss-IDs, Blueprint-Sprünge, Rückextraktion und Konfliktprüfung bestanden. Zwölf Lua-Tests prüfen Kanalbedienung, gespeicherte Netze und Hintergrund-Erkennung, darunter drei neue Tests für das Universal-Paar mit allen zehn Ressourcen und der Kabelwiederherstellung. Tests des serialisierten Blueprint-Kontrollflusses verwenden simulierte native Aufrufe.

**Nativer Spieltest vom 24.10.2026:** Alle zehn Ressourcen liefen gleichzeitig über ein Universal-Paar mit 997 m Abstand weiter, während der Spieler 20–21 km entfernt war und die native Bereichsabfrage beide Umgebungen als entladen meldete. In rund 60 Sekunden kamen bei jeder Flüssigkeit/jedem Gas etwa weitere 1.200 Einheiten und beim Strom etwa 16,6 kWh an. Quell-/Zielmengen blieben bilanziert; Eigenbedarf des Paars 4 kW. Dampf wurde mit zwei nativen Testreservoirs geprüft. [Messbericht](verification/native-universal-resources.json)

**Rückkehrfehler behoben:** Die native Nachberechnung konnte bereits weitergelaufene Netze zusätzlich verteilen lassen. Ein kleiner nativer Schutz überspringt diese überflüssigen Netz-Durchläufe, wenn alle zugehörigen Geräte bereits aktuell sind. Die Wiederholungsprüfung mit den installierbaren Dateien bestand: auch beim Wiederladen der Umgebung unverändert 20 Einheiten/s pro Flüssigkeit/Gas und regulärer Stromverbrauch. Ein getrenntes Wasser-Kontrollnetz wurde vollständig entladen und anschließend weiterhin regulär nachberechnet. [Technik und Build](BUILDING-CATCHUP.md)

Die DLL prüft die exakte Spiel-EXE und beide Funktionssignaturen. Bei einer nicht unterstützten Version bleibt die normale Entladung aktiv; der Grund erscheint im UE4SS-Protokoll. Die Korrektur kopiert keine Ressourcen, verändert keine Modulzeitstempel und schaltet die Nachberechnung anderer Netze nicht global ab.

Außerdem korrigiert das Paket 36 typisierte Flüssigkeits-/Gasanschlüsse in 20 Blueprints: `bAutoInitialize=false` verhindert, dass die Initialisierung deren Ressourcenart mit Strom überschreibt. Alle Kismet-Instruktionen bleiben unverändert; 63 der 83 Assetpakete sind von dieser Anschlusskorrektur unberührt. [Asset-Werkzeug](BUILDING-SOCKETS.md)

Der Hintergrundschutz gilt für alle zehn Ressourcen einschließlich Quellen, Verbraucher und Kabel. Die Umgebung darf entladen werden; die benötigten Geräte bleiben aktiv. Er läuft während des Spiels bis zu den Schutzgrenzen von 256 Gerätebereichen / 2.048 Objekten. Fernbetrieb und Rückkehrprüfung mit allen zehn Ressourcen bestanden; siehe Messbericht.

## Inhalt des Mod-Downloads

Das Release-ZIP enthält ausschließlich die zum Betrieb benötigten Moddateien in der `Voyage`-Ordnerstruktur. Anleitung, Änderungslisten, Lizenztexte, Drittanbieterhinweise, Entwicklungswerkzeuge und Prüfberichte bleiben im Repository bzw. auf der Release-Seite. Sie werden nicht mit ins Mod-ZIP gepackt. Die Prüfsumme ist ein separater Download. Version bleibt **1.0.0**.
