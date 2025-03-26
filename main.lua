local mod = RegisterMod("SamiraR",1)
local Samira = Isaac.GetItemIdByName("Samira rose")
local json = require("json")
local Hit = 0 --number of hit by isaac--
local MoveBonus = 0.05
local MoveTotal = 0
local sfx= SFXManager()
local SamiraSoundEffect1 = Isaac.GetSoundIdByName("SamiraBoom")
local SamiraSoundEffect2 = Isaac.GetSoundIdByName("SamiraShoot")

--I got more ideas to make this mod better like animation but its my first mod so i dont know many things--
--if u find some bug just post in the comments section on the workshop mod page--
--If you have any tips to get better code or anything  to improve, I'll gladly take them. ty--

local Settings = {
    SfxActive= true,
}

if ModConfigMenu then
    
      
    ModConfigMenu.AddSetting(
        "Samira R",
        "",
        {
          Type = ModConfigMenu.OptionType.BOOLEAN,
          CurrentSetting = function()
            return Settings.SfxActive
          end,
          Display = function()
            local bool = "False"
				if Settings.SfxActive then
					bool = "True"
				end
            return "SFX: " .. bool
          end,
          OnChange = function(bool)
            Settings.SfxActive = bool
          end,
          Info ="disable SFX or NOT"
        }
    )

end

function mod:SaveSettings()
    local jsonString = json.encode(Settings)
    mod:SaveData(jsonString)
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.SaveSettings)

function mod:LoadSettings()
    if mod:HasData() then
        local jsonString = mod:LoadData()
        Settings = json.decode(jsonString)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.LoadSettings)

function mod:takingHIT(target,amount,flag,source,num)
    local play = Isaac.GetPlayer(0)
    if target:IsVulnerableEnemy() then
        if (source.Entity.Parent == player or source.Entity.SpawnerEntity == player or source.Type < 9 or source.Type == 1000 )and play:HasCollectible(Samira) then
            --Check when an enemy get hit by Isaac and increase Hit by 1 (I found this if on reddit thanks to the author)--
            Hit=Hit+1
            if ((play.MoveSpeed)+MoveBonus)<= 2.0 then
                play.MoveSpeed= play.MoveSpeed + MoveBonus
                MoveTotal = MoveTotal + MoveBonus
            end
            --Increase the speed of Isaac every time a enemy get hit--
            if Hit==5 then
                --At 5 stacks we play the sound effect--
                if Settings.SfxActive==true then
                sfx:Play(SamiraSoundEffect1)
                end
            end
            if Hit==6 then
                Hit=0
                play.MoveSpeed= play.MoveSpeed - MoveTotal
                MoveTotal = 0
                --At 6 we reset the variable and the movespeed of Isaac--
                for i,entity in pairs(Isaac.GetRoomEntities()) do
                    if entity:IsVulnerableEnemy() then
                        entity:TakeDamage(play.Damage+1, 0, EntityRef(player), 1)
                        for j=1,5 do
                            entity:BloodExplode()
                        end
                        --damage all the enemy in the room with the player damage + 1 and make a bloody explosion--
                        --I dont know if its deal to much damage for me its fine--
                    end
                end
                if Settings.SfxActive==true then
                    sfx:Play(SamiraSoundEffect2)
                end
                
            end
        end
    end
end





function mod:resetHitCount()
    Hit = 0
    local play = Isaac.GetPlayer(0)
    play.MoveSpeed= play.MoveSpeed - MoveTotal
    MoveTotal = 0
    --just a reset of the move speed and the number of Hit when we go to the next room--
end



mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,mod.resetHitCount)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.takingHIT) --trigger the function takingHIT when something get hit--

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.resetHitCount) --trigger the function resetHitCount when we change room--