"""Regression for UE4SS schedulers that ignore a callback's return value."""
from pathlib import Path
import unittest
from lupa.lua54 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


class LocalizationScheduler(unittest.TestCase):
    def test_registers_once_even_if_timer_keeps_running(self):
        lua = LuaRuntime()
        lua.globals().path = (ROOT / 'Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessControls/Scripts/localization.lua').as_posix()
        lua.execute('''
            function LoopInGameThreadWithDelay(_, callback) tick=callback end
            local m=dofile(path)
            local calls=0
            m.register=function()calls=calls+1;return calls>=2 end
            m.start({},'test')
            for _=1,100 do tick() end
            assert(calls==2,'Registered repeatedly after success')
        ''')

    def test_engine_errors_are_bounded(self):
        lua = LuaRuntime()
        lua.globals().path = (ROOT / 'Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessControls/Scripts/localization.lua').as_posix()
        lua.execute('''
            function LoopInGameThreadWithDelay(_, callback) tick=callback end
            local m=dofile(path)
            local calls=0
            m.register=function()calls=calls+1;error('unavailable API')end
            m.start({},'test')
            for _=1,100 do tick() end
            assert(calls==3,'Unbounded registration errors')
        ''')


if __name__ == '__main__':
    unittest.main()
