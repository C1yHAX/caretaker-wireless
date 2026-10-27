return {
    -- CHANNEL MENU KEY / TASTE FUER DAS KANALMENUE
    -- Close the game before editing; restart to apply. Keep the quotes.
    -- Spiel vor dem Bearbeiten schliessen; danach neu starten. Anfuehrungszeichen behalten.
    -- Default: German O-umlaut / US backtick (~ key). No German keyboard required.
    -- Standard: deutsches O-Umlaut / US-Backtick (~-Taste).
    -- Examples / Beispiele: 'F8', 'F9', 'K', 'HOME', 'OEM_THREE'.
    -- Use UE4SS Key names, not 'Key.F8'. Upper/lower case does not matter.
    -- UE4SS-Tastennamen verwenden, nicht 'Key.F8'. Gross-/Kleinschreibung ist egal.
    -- Key list / Tastenliste: https://docs.ue4ss.com/lua-api/table-definitions/key.html
    KeyName = 'OEM_THREE',

    -- Optional combination / Optionale Kombination: {}, {'CONTROL'}, {'ALT', 'SHIFT'}.
    -- Example for Ctrl+F8 / Beispiel fuer Strg+F8: KeyName = 'F8', Modifiers = {'CONTROL'}.
    -- Avoid keys already used by the game or another mod.
    -- Bereits vom Spiel oder anderen Mods verwendete Tasten vermeiden.
    Modifiers = {},

    -- Maximum interaction distance in cm / Maximale Bedienentfernung in cm.
    MaxReach = 350,
}
