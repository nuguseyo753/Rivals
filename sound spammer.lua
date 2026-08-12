local plr = game:GetService("Players").LocalPlayer
local mc = require(plr.PlayerScripts.Controllers.MechanicsController)
local UIS = game:GetService("UserInputService")

local enabled = false

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.N then
        enabled = not enabled
        print("Auto Jump Sound:", enabled)
    end
end)

task.spawn(function()
    while true do
        if enabled then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local vel = hrp.AssemblyLinearVelocity

                mc:DoubleJump()

                task.defer(function()
                    if hrp then
                        hrp.AssemblyLinearVelocity = vel
                    end
                end)
            end
        end

        task.wait(0.2)
    end
end)
