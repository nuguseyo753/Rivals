local GunItem = require(game:GetService("Players").LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local old = GunItem.StartShooting 

GunItem.StartShooting = function(self, ...)
    local res = {old(self, ...)}
    if self.ClientFighter and self.ClientFighter.IsLocalPlayer then 
        res[4] = true
    end 
    return unpack(res)
end
