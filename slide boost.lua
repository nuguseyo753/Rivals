local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local mechanicsController = require(playerScripts:WaitForChild("Controllers"):WaitForChild("MechanicsController"))

local BOOST_MULTIPLIER = 1.5
local boostedSpeeds = setmetatable({}, { __mode = "k" })
local originalSlide = mechanicsController.Slide

local function applySlideBoost(fighter)
	if not fighter then
		return
	end

	local boostedSpeed = boostedSpeeds[fighter]
	if not boostedSpeed then
		local currentSpeed = tonumber(fighter:Get("SlidingSpeedMax")) or 3
		boostedSpeed = currentSpeed * BOOST_MULTIPLIER
		boostedSpeeds[fighter] = boostedSpeed
	end

	fighter:Set("SlidingSpeedMax", boostedSpeed)
end

function mechanicsController:Slide(...)
	local fighter = self.LocalFighter
	applySlideBoost(fighter)

	local result = originalSlide(self, ...)
	-- Slide can refresh its movement settings, so apply the value once more.
	applySlideBoost(self.LocalFighter or fighter)

	return result
end
