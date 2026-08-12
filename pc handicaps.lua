local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DebugController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DebugController"))
DebugController:SetHandicapsEnabled(true)
