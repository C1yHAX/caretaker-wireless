# Herkunft und Abhängigkeiten

- **The Last Caretaker / Channel37:** Geräte, Modelle, Symbole, ursprüngliche Blueprints und Itemdefinitionen stammen aus dem Spiel. Die drei Containerdateien enthalten bearbeitete, davon abgeleitete Assets. Sie sind von der MIT-Lizenz für unseren eigenen Code ausgeschlossen. Die Mod beansprucht keine Urheberschaft an den ursprünglichen Spielgeräten und setzt eine eigene Spielinstallation voraus.
- **UE4SS-RE / RE-UE4SS:** externe Laufzeit, separat vom Originalprojekt zu beziehen. Getesteter Quellstand: [527a483b](https://github.com/UE4SS-RE/RE-UE4SS/commit/527a483b). Der [Originaldownload](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1125-g527a483b.zip) und seine Lizenz gehören dem ursprünglichen Projekt; UE4SS wird hier nicht erneut verteilt.
- **Longer Wireless Cables:** die bisher verwendete Mod erhöhte die Basisreichweite der Wandbrücken von 5 auf 50 m. Unser Paket übernimmt diese Einstellung aus der bestehenden Modpack-Integration und ersetzt den früheren Container `zLong_Wireless_Cables_P`. Herkunft des ursprünglichen Downloads: [Nexus Mods, The Last Caretaker, Mod 147](https://www.nexusmods.com/thelastcaretaker/mods/147). Die 50-m-Einstellung wird nicht als neue eigene Geräteentwicklung dargestellt. Die neu hinzugefügten Funkstrom-Kanäle, der Hintergrundbetrieb und die Ö-Bedienung sind unsere Erweiterungen.
- **Eigener Beitrag:** Lua-Quellen der Ordner `CaretakerWirelessBackground` und `CaretakerWirelessControls`, Installer, Paketierung und Dokumentation sowie die beschriebenen Anpassungen an den vorhandenen Geräten. Die MIT-Lizenz erteilt keine zusätzlichen Rechte an fremden Spielinhalten.

Dieses Release enthält weder das vollständige Modpack noch Caretaker Energy, fremde Lua-Mods, Spielstände, AssetBridge-Caches oder lokale Testprogramme.

- **AssetBridge von NotLazy:** Version 0.4.0 für die 27 zusätzlichen Registrierungen erforderlich, separat vom Autor: https://www.nexusmods.com/thelastcaretaker/mods/225. Nicht mitgeliefert; die `.tlcaddon.json` beschreibt unsere zusätzlichen Geräte und Skills.

Die 18 Ressourcen-Iconvarianten wurden mit dem integrierten OpenAI-Bildwerkzeug aus den bestehenden Sender-/Empfänger-Icons farblich abgeleitet. Die Geräteformen basieren auf den originalen Spielgeräten. Die Farbpalette und vollständigen Bearbeitungsprompts stehen in assets/icons/RESOURCE-PROMPTS.json. Die erzeugten PNGs werden unverändert als Quellen mitgeliefert; nur Größenanpassung und Texturverpackung erfolgen im Builder.

Das Universalsender-Icon ist eine zusätzliche farbliche Bearbeitung des Sender-Icons mit dem integrierten OpenAI-Bildwerkzeug. Prompt: assets/icons/UNIVERSAL-PROMPT.json. Die Darstellung ist ein Menüsymbol und keine technische Darstellung der Anschlusspositionen.

Das Universal-Empfänger-Icon ist eine zusätzliche Bearbeitung des Empfänger-Icons mit dem integrierten OpenAI-Bildwerkzeug. Prompt: assets/icons/UNIVERSAL-RECEIVER-PROMPT.json. Die Darstellung kennzeichnet den Gerätetyp im Menü; sie bildet die zehn räumlichen Anschlusspositionen nicht ab.
