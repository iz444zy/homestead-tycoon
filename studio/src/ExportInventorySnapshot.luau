local roots={game.ReplicatedStorage.AssetLibrary.InventoryItems,workspace.InventoryWorkshop,game.ServerScriptService.InventoryWorkshopDemo}
local ids={};local n=0
for _,root in roots do n+=1;ids[root]=tostring(n);for _,x in root:GetDescendants() do n+=1;ids[x]=tostring(n) end end
local function encode(v)
    local t=typeof(v)
    if t=="Vector3" then return {v.X,v.Y,v.Z} elseif t=="Vector2" then return {v.X,v.Y}
    elseif t=="Color3" then return {v.R,v.G,v.B} elseif t=="CFrame" then return {v:GetComponents()}
    elseif t=="UDim2" then return {v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset}
    elseif t=="EnumItem" then return v.Value elseif t=="Instance" then return ids[v] or "null" end
    return v
end
local function dump(x)
    local s={class=x.ClassName,id=ids[x],name=x.Name,attributes=x:GetAttributes(),props={},children={}}
    local function p(tag,key,property) s.props[key]={tag,encode(x[property or key])} end
    if x:IsA("BasePart") then
        p("CoordinateFrame","CFrame");p("Vector3","size","Size");p("Color3","Color");p("token","Material")
        for _,k in {"Anchored","CanCollide","CanTouch","CanQuery","Massless","CastShadow"} do p("bool",k) end
        p("float","Transparency")
        if x:IsA("Part") then p("token","shape","Shape") end
    end
    if x:IsA("Tool") then p("CoordinateFrame","Grip");p("bool","RequiresHandle");p("bool","CanBeDropped");p("string","ToolTip") end
    if x:IsA("WeldConstraint") then p("Ref","Part0");p("Ref","Part1");p("bool","Enabled") end
    if x:IsA("SurfaceGui") then p("token","Face");p("Vector2","CanvasSize");p("token","SizingMode");p("bool","AlwaysOnTop");p("float","LightInfluence");p("bool","Enabled");p("float","MaxDistance") end
    if x:IsA("TextLabel") then
        p("string","Text");p("Color3","TextColor3");p("token","Font");p("bool","TextScaled");p("float","BackgroundTransparency");p("UDim2","Size");p("UDim2","Position")
    end
    if x:IsA("ProximityPrompt") then
        for _,k in {"ActionText","ObjectText"} do p("string",k) end
        for _,k in {"HoldDuration","MaxActivationDistance"} do p("float",k) end
        p("bool","RequiresLineOfSight")
    end
    if x:IsA("Script") then p("ProtectedString","Source") end
    for _,c in x:GetChildren() do table.insert(s.children,dump(c)) end
    return s
end
local out={};for _,r in roots do table.insert(out,dump(r)) end
return game:GetService("HttpService"):JSONEncode(out)
