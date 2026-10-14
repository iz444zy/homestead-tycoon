local S=require(script.Parent.UIStyle)
local C=require(script.Parent.Catalog)
local Tween=game:GetService('TweenService')
local F={}
function F.mount(root,coin)
 local self={Items={},Coins={},RunningItems=false,RunningCoins=false}
 local banner=Instance.new('CanvasGroup') banner.Name='ClaimedPlot' banner.AnchorPoint=Vector2.new(.5,0) banner.Position=UDim2.new(.5,0,0,18) banner.Size=UDim2.new(.7,0,0,76) banner.BackgroundTransparency=1 banner.Visible=false banner.Parent=root
 local title=S.text(banner,'✓  CLAIMED PLOT',44) title.TextColor3=Color3.fromRGB(91,222,118) title.TextStrokeTransparency=.45 title.TextStrokeColor3=Color3.fromRGB(26,49,31)
 local cap=Instance.new('UITextSizeConstraint') cap.MaxTextSize=44 cap.MinTextSize=24 cap.Parent=title title.TextScaled=true
 local function fade(group)
  if not S.reduced() then Tween:Create(group,TweenInfo.new(.4),{GroupTransparency=1}):Play() task.wait(.4) end
  group:Destroy()
 end
 local function play(queue,isCoins)
  local key=isCoins and 'RunningCoins' or 'RunningItems'
  if self[key] then return end self[key]=true
  task.spawn(function()
   while #queue>0 do
    local reward=table.remove(queue,1)
    local g=Instance.new('CanvasGroup') g.Name=isCoins and 'SterneReceipt' or 'ItemReceipt' g.BackgroundTransparency=1 g.Size=UDim2.fromOffset(isCoins and 182 or 280,72) g.Parent=root
    g.AnchorPoint=isCoins and Vector2.new(1,0) or Vector2.zero
    g.Position=isCoins and UDim2.new(1,-16,0,84) or UDim2.new(0,16,.38,0)
    local card=S.panel(g,'Card') card.Size=UDim2.fromScale(1,1) card.Active=false
    local id=isCoins and 'sterne' or reward.Item
    S.icon(card,id,UDim2.fromOffset(60,60),isCoins and UDim2.fromOffset(112,6) or UDim2.fromOffset(6,6))
    local t=S.text(card,'+'..reward.Count,isCoins and 34 or 30) t.Position=UDim2.fromOffset(isCoins and 8 or 76,0) t.Size=UDim2.fromOffset(isCoins and 104 or 194,72)
    if not isCoins then t.TextXAlignment=Enum.TextXAlignment.Left t.Text='+'..reward.Count..' '..(C.Items[id].Label or id) S.badge(card,reward.Quality) end
    if not S.reduced() then g.GroupTransparency=1 Tween:Create(g,TweenInfo.new(.15),{GroupTransparency=0}):Play() end
    task.wait(#queue>3 and .75 or 1.4) fade(g)
   end
   self[key]=false
  end)
 end
 function self:receive(event)
  if event.Claimed then
   banner.Visible=true banner.GroupTransparency=0
   task.delay(3,function() if not S.reduced() then Tween:Create(banner,TweenInfo.new(.4),{GroupTransparency=1}):Play() task.wait(.4) end banner.Visible=false end)
  end
  for _,r in ipairs(event.Rewards or {}) do table.insert(self.Items,r) end
  if event.Coins and event.Coins>0 then table.insert(self.Coins,{Count=event.Coins}) end
  play(self.Items,false) play(self.Coins,true)
 end
 return self
end
return F
