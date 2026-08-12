local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local utility = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"))
local playerScripts = player:WaitForChild("PlayerScripts")
local updateCameraRotation = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("Replication")
	:WaitForChild("Fighter")
	:WaitForChild("UpdateCameraRotation")

local MAX_TARGET_DISTANCE = 15
local AIM_DURATION = 0.3
local UPDATE_INTERVAL = 1 / 60

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local aiming = false
local patched = false

local function getCharacterRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getClosestTarget()
	local character = player.Character
	local myHead = character and character:FindFirstChild("Head")
	if not myHead then
		return nil
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end

	raycastParams.FilterDescendantsInstances = { character }
	local screenCenter = camera.ViewportSize / 2
	local closestTarget
	local closestScreenDistance = math.huge

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local targetCharacter = otherPlayer.Character
			local targetRoot = getCharacterRoot(targetCharacter)
			local targetHead = targetCharacter and targetCharacter:FindFirstChild("Head")
			local humanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

			if targetRoot and targetHead and humanoid and humanoid.Health > 0 then
				local offset = targetRoot.Position - myHead.Position
				if offset.Magnitude <= MAX_TARGET_DISTANCE then
					local screenPosition, isOnScreen = camera:WorldToViewportPoint(targetRoot.Position)
					if isOnScreen then
						local screenDistance = (
							Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter
						).Magnitude

						local direction = targetHead.Position - myHead.Position
						local result = workspace:Raycast(myHead.Position, direction, raycastParams)
						local isVisible = not result or result.Instance:IsDescendantOf(targetCharacter)

						if isVisible and screenDistance < closestScreenDistance then
							closestTarget = targetCharacter
							closestScreenDistance = screenDistance
						end
					end
				end
			end
		end
	end

	return closestTarget
end

local function getBackstepRotation(target)
	local targetRoot = getCharacterRoot(target)
	if not targetRoot then
		return nil
	end

	local lookVector = targetRoot.CFrame.LookVector
	local yaw = math.atan2(lookVector.X, lookVector.Z) + math.pi
	return Vector2.new(0, yaw)
end

local function startBackstep()
	if aiming then
		return
	end

	aiming = true
	task.spawn(function()
		local startedAt = os.clock()

		while aiming and os.clock() - startedAt < AIM_DURATION do
			local target = getClosestTarget()
			local rotation = target and getBackstepRotation(target)

			if rotation then
				updateCameraRotation:FireServer(utility:EncodeCameraRotation(rotation), nil)
			end

			task.wait(UPDATE_INTERVAL)
		end

		aiming = false
	end)
end

local function patchKnifeModule()
	if patched then
		return true
	end

	local knifeModule = playerScripts
		:WaitForChild("Modules")
		:WaitForChild("Items")
		:WaitForChild("Knife")

	local ok, knife = pcall(require, knifeModule)
	if not ok or type(knife) ~= "table" or type(knife.StartAiming) ~= "function" then
		return false
	end

	local originalStartAiming = knife.StartAiming
	knife.StartAiming = function(self, ...)
		startBackstep()
		return originalStartAiming(self, ...)
	end

	patched = true
	return true
end

task.spawn(function()
	while not patchKnifeModule() do
		task.wait(1)
	end
end)
