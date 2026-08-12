local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

local cam = workspace.CurrentCamera
local util = require(rs.Modules.Utility)

local ents = {}
local function scan()
    ents = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChildOfClass("Humanoid") then
            table.insert(ents, v)
        elseif v.Name == "HurtEffect" then
            for _, hv in pairs(v:GetChildren()) do
                if hv.ClassName ~= "Highlight" then
                    table.insert(ents, hv)
                end
            end
        end
    end
end

local function closest()
    local char = ps.LocalPlayer.Character
    if not char then return end
    
    scan()
    local best, dist = nil, 99999
    local scr = cam.ViewportSize/2
    
    for _, v in pairs(ents) do
        if v == ps.LocalPlayer then continue end
        if not v.HumanoidRootPart then continue end
        
        local pos, vis = cam:WorldToViewportPoint(v.HumanoidRootPart.Position)
        if not vis then continue end
        
        local d = (Vector2.new(pos.X, pos.Y) - scr).Magnitude
        if d < dist then
            best = v
            dist = d
        end
    end
    return best
end

local old_ray = util.Raycast
util.Raycast = function(s, o, d, len, f, ft, viz)
    if len == 999 and len > 100 and f then
        local tgt = closest()
        if tgt and tgt:FindFirstChild("Head") then
            local hitpos = tgt.Head.Position
            return {
                Position = hitpos,
                Distance = (hitpos - o).Magnitude,
                Instance = tgt.Head,
                Material = tgt.Head.Material,
                Normal = Vector3.yAxis
            }
        end
    end
    return old_ray(s, o, d, len, f, ft, viz)
end
