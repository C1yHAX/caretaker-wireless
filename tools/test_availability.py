"""Regression tests for earned recipes, full vaults and load-time capacity.

Native unlock/crafting/save-load coverage is recorded separately. These small
fixtures exercise the repair's ownership and non-destructive invariants.
"""
import unittest
from test_resources import setup


class Availability(unittest.TestCase):
    def fixture(self):
        lua = setup()
        lua.execute('''
        inventory=validObject({Type=2,Capacity=1024,count=1024,items={}})
        function inventory:GetNumOccupiedSlots()return self.count end
        function inventory:GetNumItems(item)return self.items[item.path] or 0 end
        function inventory:AddItem(item,data,stack,notify)
          assert(data.ItemCount==1 and stack and notify)
          assert(self.Capacity==0 or self.count<self.Capacity)
          self.items[item.path]=1;self.count=self.count+1
        end
        playerState=validObject({AddSkill=function(self,skill,notify)
          assert(not notify and skill.Unlock.Cost==0)
          owned[skill.path]=true
        end})
        pc=validObject({Pawn=validObject(),PlayerState=playerState,
          GetInventoryComponent=function(self,kind)assert(kind==2);return inventory end})
        owned={};scanned={};assets={}
        gp=validObject({
          HasItemBeenScanned=function(self,pc,item)return scanned[item.path]==true end,
          HasPlayerSkill=function(self,skill,pc)return owned[skill.path]==true end})
        template=validObject({Type=2,Capacity=1024})
        pawnClass=validObject({GetCDO=function()return {VaultInventory=template}end})
        function StaticFindObject(path)
          if path:find('Default__VoyageGameplay')then return gp end
          if path:find('BP_FirstPersonCharacter_New')then return pawnClass end
          assets[path]=assets[path]or validObject({path=path,Unlock={Cost=0}})
          return assets[path]
        end
        LoadAsset=StaticFindObject
        function RegisterInitGameStatePreHook(fn)initGame=fn end
        function LoopInGameThreadWithDelay(ms,fn)assert(ms==10000)end
        M=dofile(controls..'availability.lua')
        function own(resource)
          local s='DA_Skill_Wireless_'..resource
          owned['/Game/CaretakerWireless/Skills/'..s..'.'..s]=true
        end
        ''')
        return lua

    def test_full_vault_repairs_only_earned_pair_once_without_deleting(self):
        lua = self.fixture()
        lua.execute('''
        inventory.items.existing=7;own('Diesel')
        assert(M.repair(pc)==2 and inventory.count==1026)
        assert(inventory.items.existing==7 and inventory.Capacity==1280)
        assert(M.repair(pc)==0 and inventory.count==1026)
        assert(inventory.Capacity==1280)
        ''')

    def test_no_ownership_does_not_grant_items_or_skills(self):
        self.fixture().execute('''
        assert(M.repair(pc)==0 and inventory.count==1024)
        assert(next(owned)==nil and next(inventory.items)==nil)
        ''')

    def test_legacy_pair_migrates_receiver_without_extra_vault_copy(self):
        lua=self.fixture()
        lua.execute('''
        own('Diesel')
        local n='DA_Wireless_Diesel_Receiver'
        local path='/Game/CaretakerWireless/Items/'..n..'.'..n
        inventory.items[path]=1
        assert(M.repair(pc)==1)
        assert(owned['/Game/CaretakerWireless/Skills/DA_Skill_Wireless_Diesel_Receiver.DA_Skill_Wireless_Diesel_Receiver'])
        assert(inventory.items[path]==1 and inventory.count==1025)
        assert(M.repair(pc)==0 and inventory.count==1025)
        ''')

    def test_receiver_owned_independently_does_not_grant_sender(self):
        self.fixture().execute('''
        own('Diesel_Receiver')
        assert(M.repair(pc)==1)
        assert(inventory.items['/Game/CaretakerWireless/Items/DA_Wireless_Diesel_Receiver.DA_Wireless_Diesel_Receiver']==1)
        assert(inventory.items['/Game/CaretakerWireless/Items/DA_Wireless_Diesel_Transmitter.DA_Wireless_Diesel_Transmitter']==nil)
        ''')

    def test_retired_universal_receiver_is_not_regranted_or_deleted(self):
        self.fixture().execute('''
        own('Universal')
        local n='DA_Wireless_Universal_Receiver'
        local path='/Game/CaretakerWireless/Items/'..n..'.'..n
        assert(M.repair(pc)==1)
        assert(inventory.items[path]==nil)
        assert(not owned['/Game/CaretakerWireless/Skills/DA_Skill_Wireless_Universal_Receiver.DA_Skill_Wireless_Universal_Receiver'])
        inventory.items[path]=1;own('Universal_Receiver')
        assert(M.repair(pc)==0 and inventory.items[path]==1)
        ''')

    def test_scanned_stock_sender_is_recovered_and_unlimited_vault_preserved(self):
        self.fixture().execute('''
        local n='DA_Module_WirelessResourceTransmitter'
        scanned['/Game/Data/Assets/Cable/'..n..'.'..n]=true
        inventory.Capacity=0
        assert(M.repair(pc)==1 and inventory.Capacity==0)
        assert(M.repair(pc)==0)
        ''')

    def test_template_prepared_before_load_and_larger_capacity_preserved(self):
        self.fixture().execute('''
        M.start();initGame()
        assert(template.Capacity==4096)
        assert(inventory.Capacity==1024)
        template.Capacity=8192;initGame();assert(template.Capacity==8192)
        template.Capacity=0;initGame();assert(template.Capacity==0)
        ''')


if __name__ == '__main__':
    unittest.main()
