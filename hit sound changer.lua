local soundtochange = "rbxassetid://4764109000" --Rust Sound

game:GetService("Players").LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel.ChildAdded:Connect(function(v)
	if v:IsA("Sound") and v.SoundId ~= "rbxassetid://16537449730" then
		v.SoundId = soundtochange
		v.Pitch = 1
		v.Volume = 1
	end
end)
