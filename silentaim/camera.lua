local rs = cloneref(game:GetService("ReplicatedStorage"))
local ps = cloneref(game:GetService("Players"))
local workspace = cloneref(game:GetService("Workspace"))

local cam = workspace.CurrentCamera
local util = require(rs.Modules.Utility)
local enums = require(rs.Modules.EnumLibrary)

local lplr = ps.LocalPlayer

local function getTarget()
    if isLobby() then return nil end
    if not entitylib.isAlive then return nil end

    local best, dist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()

    for _, v in pairs(ps:GetPlayers()) do
        if v ~= lplr and v.Character then
            local head = v.Character:FindFirstChild("Head")
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            local hum = v.Character:FindFirstChildOfClass("Humanoid")

            if head and hrp and hum and hum.Health > 0 then
                
                if not canSeeTarget(v.Character) then
                    continue
                end
                
                local pos, vis = cam:WorldToViewportPoint(head.Position)
                if vis then
                    local dist2d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude

                    if RageCircle.Enabled and dist2d > Range.Value then
                        continue
                    end

                    if dist2d < dist then
                        best = v.Character
                        dist = dist2d
                    end
                end
            end
        end
    end

    return best
end

local old

old = hookfunction(
    rs.Remotes.Replication.Fighter.UseItem.FireServer,
    newcclosure(function(self, obj, action, cameradata, ...)
        
        if action == enums:ToEnum("StartShooting") then
            local target = getTarget()

            if target and target:FindFirstChild("Head") then
                local head = target.Head

                local look = CFrame.lookAt(cam.CFrame.Position, head.Position)

                cameradata = cameradata or {}

                cameradata[utf8.char(1)] = {
                    [utf8.char(0)] = util:EncodeCFrame(look),
                    [utf8.char(1)] = util:EncodeCFrame(look),
                    [utf8.char(2)] = head,
                    [utf8.char(3)] = util:EncodeCFrame(
                        head.CFrame:ToObjectSpace(CFrame.new(head.Position))
                    )
                }

                return old(self, obj, action, cameradata, ...)
            end
        end

        return old(self, obj, action, cameradata, ...)
    end)
)
