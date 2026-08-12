local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local utility = require(ReplicatedStorage.Modules.Utility)
local cameraController = require(localPlayer.PlayerScripts.Controllers.CameraController)

local updateCameraRotation = ReplicatedStorage.Remotes.Replication.Fighter.UpdateCameraRotation

_G.CurrentCameraLoopID = (_G.CurrentCameraLoopID or 0) + 1
local myLoopID = _G.CurrentCameraLoopID

local targetAngle = math.rad(179) 

local yaw, cameraRotation, encodedRotation

task.spawn(function()
    while _G.CurrentCameraLoopID == myLoopID do
        yaw = cameraController.Rotation and cameraController.Rotation.Y or 0
        cameraRotation = Vector2.new(targetAngle, yaw)
        encodedRotation = utility:EncodeCameraRotation(cameraRotation)
        
        updateCameraRotation:FireServer(encodedRotation, nil)
        
        task.wait()
    end
end)
