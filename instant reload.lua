local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local rs = game:GetService("RunService")

local function getfighter()
    if lp.Character then
        local mechctrl = lp.PlayerScripts:FindFirstChild("Controllers"):FindFirstChild("MechanicsController")
        if mechctrl then
            local req = require(mechctrl)
            if req and req.LocalFighter then
                return req.LocalFighter
            end
        end
    end
end

local function hookgunstuff()
    local fighter = getfighter()
    if not fighter then return end
    
    local item = fighter.EquippedItem
    if not item then return end
    
    if item._reload_cooldown then
        item._reload_cooldown = 0
    end
    if item._reload_cancel_cooldown then
        item._reload_cancel_cooldown = 0
    end
    if item._reload_cancel_expiration then
        item._reload_cancel_expiration = 0
    end
end

rs.Heartbeat:Connect(function()
    pcall(hookgunstuff)
end)
