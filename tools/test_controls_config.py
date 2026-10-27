"""Exercise the shipped Lua entry point with configurable UE4SS key bindings."""
from pathlib import Path
import unittest
from lupa.lua54 import LuaRuntime

ROOT = Path(__file__).resolve().parent.parent
MAIN = ROOT / 'Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessControls/Scripts/main.lua'


def boot(source=None, occupied=False):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().main_path = MAIN.as_posix()
    lua.globals().custom_config = source
    lua.globals().occupied = occupied
    lua.execute('''
        logs={}; bindings={}; timers={}; recovery=0; checks={}
        Key={OEM_THREE=192,F8=119,F9=120,K=75,HOME=36}
        ModifierKey={CONTROL=17,ALT=18,SHIFT=16}
        function print(message) logs[#logs+1]=message end
        local real_dofile=dofile
        function dofile(path)
            if path:match('/config.lua$') and custom_config then
                return assert(load(custom_config))()
            elseif path:match('/availability.lua$') then
                return {start=function() recovery=recovery+1 end}
            end
            return real_dofile(path)
        end
        function IsKeyBindRegistered(key,mods)
            checks[#checks+1]={key=key,mods=mods};return occupied
        end
        function RegisterKeyBind(key,mods,fn)
            bindings[#bindings+1]={key=key,mods=mods,fn=fn}
        end
        function LoopInGameThreadWithDelay(ms,fn) timers[ms]=fn end
        M=dofile(main_path)
    ''')
    return lua


class ControlsConfig(unittest.TestCase):
    def test_shipped_default_keeps_existing_key_and_recipes(self):
        boot().execute('assert(recovery==1 and #bindings==1 and bindings[1].key==192 and #bindings[1].mods==0)')

    def test_portable_keys_normalization_and_legacy_config(self):
        for key, code in [('F8', 119), (' f9 ', 120), ('k', 75), ('HOME', 36)]:
            with self.subTest(key=key):
                lua = boot("return {KeyName='"+key+"', KeyLabel='old label', MaxReach=350}")
                lua.execute(f"assert(#bindings==1 and bindings[1].key=={code})")
                lua.execute("assert(not table.concat(logs):find('old label',1,true))")

    def test_modifier_combo_used_for_registration_and_conflict_check(self):
        lua = boot("return {KeyName='F8',Modifiers={'ctrl','ALT','control','shift'}}")
        lua.execute('''
            assert(#bindings==1 and #bindings[1].mods==3)
            assert(bindings[1].mods[1]==17 and bindings[1].mods[2]==18 and bindings[1].mods[3]==16)
            assert(checks[1].key==119 and checks[1].mods==bindings[1].mods)
        ''')

    def test_invalid_config_keeps_recipe_recovery_without_registering(self):
        for source in ["return {", "return false", "return {KeyName='NO_SUCH_KEY'}",
                       "return {KeyName=123}", "return {KeyName='F8',Modifiers='CTRL'}",
                       "return {KeyName='F8',Modifiers=false}",
                       "return {KeyName='F8',Modifiers={'META'}}",
                       "return {KeyName='F8',Modifiers={[2]='ALT'}}",
                       "return {KeyName='F8',Modifiers={oops='ALT'}}"]:
            with self.subTest(source=source):
                boot(source).execute('assert(recovery==1 and #bindings==0 and next(timers)==nil and #logs>0)')

    def test_occupied_binding_does_not_replace_other_mod(self):
        boot("return {KeyName='F8',Modifiers={'CONTROL'}}", occupied=True).execute(
            "assert(recovery==1 and #bindings==0 and next(timers)==nil and table.concat(logs):find('already used',1,true))")

    def test_callback_defers_dialog_to_game_thread_and_coalesces_presses(self):
        lua = boot("return {KeyName='F8'}")
        lua.execute('''
            opened=0;M.open=function()opened=opened+1 end
            bindings[1].fn();bindings[1].fn();assert(opened==0)
            timers[50]();assert(opened==1)
            timers[50]();assert(opened==1)
            M.open=function()error('test engine error')end
            bindings[1].fn();timers[50]()
            assert(table.concat(logs):find('Open failed',1,true))
        ''')

    def test_invalid_reach_uses_safe_default(self):
        lua = boot("return {KeyName='F8',MaxReach='bad'}")
        lua.execute('''
            local actor={IsValid=function()return true end,GetClass=function()
                return {GetFName=function()return {ToString=function()return 'BP_Module_WirelessResourceTransmitter_C' end}end}
            end}
            local component={IsValid=function()return true end,GetOwner=function()return actor end,
                K2_GetComponentLocation=function()return {X=400,Y=0,Z=0}end}
            local pointer={IsValid=function()return true end,MaxReach=1000,GetHoverReference=function()return component end}
            local pc={Pawn={IsValid=function()return true end,InteractiveDetectorPointerComponent=pointer},
                PlayerCameraManager={GetCameraLocation=function()return {X=0,Y=0,Z=0}end}}
            assert(M.target(pc)==nil)
            component.K2_GetComponentLocation=function()return {X=300,Y=0,Z=0}end
            assert(M.target(pc)==actor)
        ''')


if __name__ == '__main__':
    unittest.main()
