-- Four standing hold points; passenger Seats are handled by Roblox.
local truck = script.Parent
local Players = game:GetService('Players')
local release = truck:WaitForChild('ReleaseHold')
local occupied, riders = {}, {}
local function leave(player)
 local state = riders[player]
 if not state then return end
 riders[player] = nil; occupied[state.point] = nil
 if state.weld then state.weld:Destroy() end
 if state.death then state.death:Disconnect() end
 for _, object in state.ik do object:Destroy() end
 for joint, original in state.joints do
  if joint.Parent then joint.C0 = original end
 end
 local h = state.humanoid
 if h.Parent then
  h.PlatformStand = false; h.AutoRotate = state.autoRotate
  h:ChangeState(Enum.HumanoidStateType.GettingUp)
  local root = h.Parent:FindFirstChild('HumanoidRootPart')
  if root then
   local exit = state.point.CFrame * CFrame.new(0, 3, 3)
   root.CFrame = exit
   root.AssemblyLinearVelocity = truck.Chassis.AssemblyLinearVelocity
  end
 end
 player:SetAttribute('HoldingSeedTruck', false)
 state.prompt.ActionText = 'Hold on'
end
for _, point in truck.HoldPoints:GetChildren() do
 local prompt = point:FindFirstChildOfClass('ProximityPrompt')
 prompt.Triggered:Connect(function(player)
  if riders[player] then leave(player); return end
  if occupied[point] then return end
  local char = player.Character
  local h = char and char:FindFirstChildOfClass('Humanoid')
  local root = char and char:FindFirstChild('HumanoidRootPart')
  if not h or not root or h.Health <= 0 or h.SeatPart then return end
  if (root.Position-point.Position).Magnitude > 11 then return end
  local state = {point=point, prompt=prompt, humanoid=h, autoRotate=h.AutoRotate, joints={}, ik={}}
  occupied[point] = player; riders[player] = state
  h.AutoRotate = false; h.PlatformStand = true
  root.CFrame = point.CFrame * CFrame.new(0, 3.1, 0)
  for _, side in {'Left', 'Right'} do
   local arm, hand = char:FindFirstChild(side..'UpperArm'), char:FindFirstChild(side..'Hand')
   if arm and hand then
    local target=Instance.new('Attachment')
    target.Name=side..'HandTarget'; target.Position=Vector3.new(side=='Left' and -.75 or .75,3.6,-.57);target.Parent=point
    local ik=Instance.new('IKControl');ik.Name='TruckGrip'..side;ik.Type=Enum.IKControlType.Position
    ik.ChainRoot=arm;ik.EndEffector=hand;ik.Target=target;ik.Weight=1;ik.SmoothTime=0;ik.Parent=h
    table.insert(state.ik,ik);table.insert(state.ik,target)
   end
  end
  for _, joint in char:GetDescendants() do
   if h.RigType==Enum.HumanoidRigType.R6 and joint:IsA('Motor6D') and (joint.Name=='Left Shoulder' or joint.Name=='Right Shoulder') then
    state.joints[joint] = joint.C0
    joint.C0 = joint.C0 * CFrame.Angles(math.rad(85), 0, 0)
   end
  end
  local weld = Instance.new('WeldConstraint')
  weld.Name='StandingRider'; weld.Part0=point; weld.Part1=root; weld.Parent=point; state.weld=weld
  state.death=h.Died:Connect(function() leave(player) end)
  player:SetAttribute('HoldingSeedTruck',true)
  prompt.ActionText='Let go'
 end)
end
release.OnServerEvent:Connect(leave)
Players.PlayerRemoving:Connect(leave)
