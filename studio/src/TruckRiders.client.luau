-- Jump releases a standing hold, including the mobile jump button.
local player=game:GetService('Players').LocalPlayer
local input=game:GetService('UserInputService')
local remote=script.Parent:WaitForChild('ReleaseHold')
input.JumpRequest:Connect(function()
 if player:GetAttribute('HoldingSeedTruck') then remote:FireServer() end
end)
