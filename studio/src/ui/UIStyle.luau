local A=require(script.Parent.UIAssets)
local P=require(script.Parent.UIPrimitives)
local S={Colors=A.Colors,Label=26,Number=30,Title=34,Tool=80,SmallTool=64,Tile=104}
function S.round(x,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 18) c.Parent=x end
function S.text(parent,value,size)
    local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.TextColor3=S.Colors.ink l.Font=Enum.Font.GothamBold l.TextSize=size or 26 l.Text=value or "" l.Size=UDim2.fromScale(1,1) l.TextWrapped=true l.Parent=parent return l
end
function S.panel(parent,name)
    local f=P.panel(parent,UDim2.fromOffset(480,300),UDim2.new()) f.Name=name f.Active=true
    local stroke=Instance.new("UIStroke") stroke.Color=S.Colors.outline stroke.Transparency=.4 stroke.Thickness=1 stroke.Parent=f return f
end
function S.reduced()
    local ok,value=pcall(function() return game:GetService("GuiService").ReducedMotionEnabled end)
    return ok and value or game.Players.LocalPlayer:GetAttribute("ReducedMotion")==true
end
function S.button(parent,name,text,fn)
    local b=Instance.new("TextButton") b.Name=name b.Text=text or "" b.TextSize=26 b.Font=Enum.Font.GothamBold b.TextColor3=S.Colors.ink b.BackgroundColor3=S.Colors.creamRaised b.BorderSizePixel=0 b.AutoButtonColor=false b.Selectable=true b.Parent=parent S.round(b)
    local stroke=Instance.new("UIStroke") stroke.Name="Outline" stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Color=S.Colors.green stroke.Thickness=3 stroke.Enabled=false stroke.Parent=b
    b.SelectionGained:Connect(function() stroke.Enabled=true end) b.SelectionLost:Connect(function() stroke.Enabled=b:GetAttribute("Selected")==true end)
    b.Activated:Connect(fn)
    b.MouseButton1Down:Connect(function() if not S.reduced() then game:GetService("TweenService"):Create(b,TweenInfo.new(.08),{BackgroundColor3=S.Colors.slot}):Play() end end)
    b.MouseButton1Up:Connect(function() b.BackgroundColor3=S.Colors.creamRaised end) return b
end
function S.selected(b,yes) b:SetAttribute("Selected",yes==true) b.Outline.Enabled=yes==true end
function S.icon(parent,id,size,pos)
    local im=Instance.new("ImageLabel") im.Name="Icon" im.Size=size or UDim2.fromScale(1,1) im.Position=pos or UDim2.new() A.apply(im,id) im.Parent=parent return im
end
function S.badge(parent,q)
    if not q or q=="Common" then return end
    local f=Instance.new("Frame") f.Name="Quality" f.Size=UDim2.fromOffset(30,30) f.Position=UDim2.new(1,-32,0,2) f.BackgroundColor3=S.Colors.creamRaised f.BorderSizePixel=0 f.Parent=parent S.round(f,8) P.icon(f,q)
end
return S
