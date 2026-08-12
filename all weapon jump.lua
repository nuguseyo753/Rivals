local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local mechanicsController = require(playerScripts:WaitForChild("Controllers"):WaitForChild("MechanicsController"))

local EXTRA_JUMPS = 1
local lastItem

local function allowExtraJump(item)
	if not item or not item.Info then
		return
	end

	local info = item.Info
	local currentJumps = tonumber(info.MaxDoubleJumps) or 0

	if currentJumps < EXTRA_JUMPS then
		info.MaxDoubleJumps = EXTRA_JUMPS
	end
end

RunService.Heartbeat:Connect(function()
	local fighter = mechanicsController.LocalFighter
	local item = fighter and fighter.EquippedItem

	if item ~= lastItem then
		lastItem = item
		allowExtraJump(item)
	elseif item and item.Info and (tonumber(item.Info.MaxDoubleJumps) or 0) < EXTRA_JUMPS then
		-- Some weapons rebuild their info table while equipped.
		allowExtraJump(item)
	end
end)
