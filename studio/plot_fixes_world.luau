local plot=workspace.LunaLandingFirstPlot
assert(not plot:GetAttribute('PlotFixesV1'),'Already applied')
game:GetService('ChangeHistoryService'):SetWaypoint('Before plot fixes')
local roads=plot.AutumnDetails.VillageConnections
roads:ClearAllChildren()
local color=Color3.fromRGB(183,169,132)
for _,p in ipairs(plot.Paths:GetChildren()) do if p:IsA('BasePart') then p.Color=color p.Material=Enum.Material.Sand end end
local function segment(name,a,b,width)
 local p=Instance.new('Part') p.Name=name p.Anchored=true p.Size=Vector3.new(width,.16,(b-a).Magnitude+1.5)
 p.CFrame=CFrame.lookAt((a+b)/2,b) p.Material=Enum.Material.Sand p.Color=color p.CanCollide=false p.CanQuery=false p.Parent=roads return p
end
local function v(x,z) return Vector3.new(x,.08,z) end
-- Two full-size 220 x 196 plots on every side; first plot stays in place.
segment('NorthMain',v(-110,135),v(370,135),32)
segment('SouthMain',v(-110,795),v(370,795),32)
segment('WestMain',v(-200,225),v(-200,705),32)
segment('EastMain',v(460,225),v(460,705),32)
for _,corner in ipairs({{-110,225,180},{370,225,270},{370,705,0},{-110,705,90}}) do
 for i=0,35 do
  local a=math.rad(corner[3]+i*2.5) local b=math.rad(corner[3]+(i+1)*2.5)
  segment('RoundedCorner',v(corner[1]+90*math.cos(a),corner[2]+90*math.sin(a)),v(corner[1]+90*math.cos(b),corner[2]+90*math.sin(b)),32)
 end
end
for _,x in ipairs({-17,243}) do segment('PlotApproach',v(x,114),v(x,135),10) segment('PlotApproach',v(x,795),v(x,816),10) end
for _,z in ipairs({335,595}) do segment('PlotApproach',v(-221,z),v(-200,z),10) segment('PlotApproach',v(460,z),v(481,z),10) end
-- A single matching footpath between the two neighboring plots on each side.
segment('NeighborLink',v(105,3),v(155,3),10)
segment('NeighborLink',v(105,927),v(155,927),10)
segment('NeighborLink',v(-332,440),v(-332,490),10)
segment('NeighborLink',v(592,440),v(592,490),10)
local sites=Instance.new('Folder') sites.Name='EightPlotLayout' sites.Parent=workspace
for i,entry in ipairs({{0,0,0},{260,0,0},{-34,930,180},{226,930,180},{-335,318,90},{-335,578,90},{595,352,-90},{595,612,-90}}) do
 local p=Instance.new('Part') p.Name=string.format('Plot%02d',i) p.Anchored=true p.Size=Vector3.new(220,.1,196) p.CFrame=CFrame.new(entry[1],-.12,entry[2])*CFrame.Angles(0,math.rad(entry[3]),0) p.Transparency=1 p.CanCollide=false p.CanQuery=false p.CanTouch=false p:SetAttribute('ReservedPlot',true) p.Parent=sites
end
local box=plot.Commerce.SellBox local origin=Vector3.new(-29,.1,102) local scale=Vector3.new(1.82,1.4,1.4)
for _,p in ipairs(box:GetDescendants()) do if p:IsA('BasePart') then p.Position=origin+(p.Position-origin)*scale p.Size*=scale end end
local sign=plot.Digging.DigSign
for _,g in ipairs(sign:GetChildren()) do if g:IsA('SurfaceGui') then if g.Face==Enum.NormalId.Front then g:Destroy() else g.Face=Enum.NormalId.Back end end end
local chest=plot.HouseChest local delta=Vector3.new(-82,1.15,-38)-chest.InteractionAnchor.Position
chest:PivotTo(chest:GetPivot()+delta)
chest:SetAttribute('FrontStairPlacement',true)
local ground=plot.Ground.SurroundingGround ground.Size=Vector3.new(2600,ground.Size.Y,2600)
-- Center the eight-plot block and its connected farm assets on the playable ground.
local layoutOffset=Vector3.new(-130,0,-465)
local groundCFrame=ground.CFrame
plot:PivotTo(plot:GetPivot()+layoutOffset)
ground.CFrame=groundCFrame
for _,marker in ipairs(sites:GetChildren()) do
 if marker:IsA('BasePart') then marker.CFrame+=layoutOffset end
end
local corners={} for _,p in ipairs(roads:GetChildren()) do if p.Name=='RoundedCorner' then table.insert(corners,p) end end
for i=1,#corners,36 do local base=corners[i] local rest={} for j=i+1,i+35 do table.insert(rest,corners[j]) end local union=base:UnionAsync(rest) union.Name='RoundedCornerSurface' union.Parent=roads base:Destroy() for _,p in ipairs(rest) do p:Destroy() end task.wait() end
plot:SetAttribute('PlotFixesV1',true)
game:GetService('ChangeHistoryService'):SetWaypoint('Roads sell box sign and front chest')
return 'World fixes applied: 32-stud rounded loop, 8 reserved plots, rectangular sell box, one-sided sign, front chest'

