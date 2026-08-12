local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local success, GunModule = pcall(function()
    return require(LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
end)

if success and GunModule and GunModule.Equip then
    local oldEquip = GunModule.Equip

    GunModule.Equip = function(self, ...)
        local result = { oldEquip(self, ...) }

        if self.ViewModel then
            if self.ViewModel.StopAnimation then
                self.ViewModel:StopAnimation('Equip')
                self.ViewModel:StopAnimation('EquipEmpty')
            end
        end

        return unpack(result)
    end
end
