local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local success, GunModule = pcall(function()
    return require(LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
end)

if success and GunModule then
    if GunModule.StartAiming then
        local oldStartAiming = GunModule.StartAiming

        GunModule.StartAiming = function(self, ...)
            self:SetReplicate('IsAiming', true)
            self.StopSprinting:Fire()
            self.ViewModel:SetAiming(true)
            self:SetReplicate('FOVOffset', self.Info.AimFOVOffset)

            if self.ViewModel.CurrentAimValue then
                self.ViewModel.CurrentAimValue = 1
            end

            return true, 'StartAiming'
        end
    end

    if GunModule.GetAimSpeed then
        local oldGetAimSpeed = GunModule.GetAimSpeed

        GunModule.GetAimSpeed = function(self)
            return 999
        end
    end
end
