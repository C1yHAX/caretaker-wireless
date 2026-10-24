# Native Rückkehrkorrektur (1.0.0)

`native/catchup.c` ergänzt die Ressourcen-Netzverteilung von Voyage
0.10.0.653173 / Steam 25982825. Die EXE auf der Festplatte bleibt unverändert.

Die native Modulberechnung überspringt Aufholschritte, wenn
`LastUpdatedWorldTime + step > GlobalTime + epsilon` gilt. Die beiden nachfolgenden
Netzverteilungsfunktionen erhalten dennoch den globalen Aufhol-Zeitschritt. Dadurch
kann eine vollständig aktuell gehaltene Funkanlage während der Nachberechnung
anderer, tatsächlich entladener Geräte nochmals Ressourcen übertragen.

Die Korrektur prüft ausschließlich während eines nativen Aufholschritts die
Modulmenge des jeweiligen Netzes. Sind alle initialisierten Module bereits
aktuell, entfallen dessen überflüssige Verteilungs- und Ausgleichsdurchläufe.
Sobald ein Modul echte Zeitschuld hat, bleibt der originale Ablauf erhalten.
Normale Spielticks bleiben unverändert. Es werden keine Ressourcen kopiert,
Zeitstempel verändert oder globalen Catch-up-Einstellungen abgeschaltet.

## Nachgewiesene Schnittstellen

Für genau den geprüften EXE-Hash:

- Ressourcenverteilung: RVA `0x56ab2c0`, Signatur `void(subsystem, grid, float)`.
- Ausgleich: RVA `0x56aca40`, gleiche Signatur.
- `bCatchupTick`: Subsystem + `0x330`; GlobalTime + `0x168`; step + `0x1d8`.
- Netz: `TSet<UVoyageModuleComponent*>` + `0x8`, Elemente 16 Bytes.
- Modul: Subsystem + `0x620`, initialisiert + `0x977`, Zeitstempel + `0x988`.
- Epsilon entspricht dem nativen `float(0.0001)` als double.

Die DLL prüft zunächst SHA-256 der vollständigen Spiel-EXE und danach die
ersten 16 Bytes beider Funktionen im Speicher. Abweichungen verhindern die
Installation der Hooks. Die Lua-Mod lässt dann die normale Bereichsentladung
zu und schreibt den Grund ins UE4SS-Protokoll. Ein Spielupdate benötigt eine
erneute Prüfung; es gibt kein unkontrolliertes Suchen nach ähnlichen Adressen.

MinHook installiert die beiden Hooks. Die DLL bleibt im Prozess geladen, damit
Lua-Neuladen keine noch verwendeten Funktionszeiger freigibt. Callbacks verwenden
keine Lua-API und verändern keine UE-Container. Während normaler Ticks beschränkt
sich die Zusatzarbeit auf Statusprüfungen; die Modulmenge wird nur bei
Aufholschritten gelesen. Ungültige oder unvollständige Netzdaten behalten den
Originalablauf. `M.setEnabled(false)` deaktiviert auch den nativen Schutz.

## Bauen und prüfen

Windows x64, Zig 0.13.0:

```powershell
./tools/build_catchup.ps1 -Zig '<Pfad zu zig.exe>'
```

Das baut die DLL, führt `native/test_catchup.c` aus und kopiert ausschließlich
die DLL in den installierbaren Modordner. Die Tests unterscheiden normale Ticks,
aktuelle Netze, echte Zeitschuld, Lücken im TSet, fehlende Initialisierung,
ungültige Zeitwerte und deaktivierten Schutz. Die Ergebnisse der zusätzlichen
nativen Spielprüfung stehen in
[verification/native-universal-resources.json](verification/native-universal-resources.json).

Vor der Veröffentlichung muss `Dateien.json` die Hashes der fertigen Dateien
enthalten. `tools/package_release.py` prüft sie und erzeugt das Mod-ZIP.
Quellen, Tests, Dokumentation und Lizenztexte bleiben außerhalb des Mod-ZIP.
