-- Crisp UI controls and non-color status symbols; no extra image uploads needed.
local P={}
local ink=Color3.fromRGB(23,55,30)
local cream=Color3.fromRGB(255,245,214)
local function rect(parent,x,y,w,h,color,angle,radius)
    local f=Instance.new("Frame")
    f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.fromScale(x,y)
    f.Size=UDim2.fromScale(w,h) f.Rotation=angle or 0 f.BackgroundColor3=color or ink
    f.BorderSizePixel=0 f.Parent=parent
    if radius then local c=Instance.new("UICorner") c.CornerRadius=UDim.new(radius,0) c.Parent=f end
    return f
end
local function line(p,x1,y1,x2,y2,color,thickness)
    local dx,dy=x2-x1,y2-y1
    return rect(p,(x1+x2)/2,(y1+y2)/2,math.sqrt(dx*dx+dy*dy),thickness or .10,color,math.deg(math.atan2(dy,dx)),.5)
end
function P.icon(parent,kind,color)
    local f=Instance.new("Frame") f.Name=kind f.BackgroundTransparency=1
    f.Size=UDim2.fromScale(1,1) f.Parent=parent color=color or ink
    if kind=="close" then line(f,.25,.25,.75,.75,color) line(f,.25,.75,.75,.25,color)
    elseif kind=="check" then line(f,.18,.52,.41,.74,color) line(f,.41,.74,.82,.27,color)
    elseif kind=="plus" then line(f,.20,.50,.80,.50,color) line(f,.50,.20,.50,.80,color)
    elseif kind=="minus" then line(f,.20,.50,.80,.50,color)
    elseif kind=="left" or kind=="right" then
        local a,b=kind=="left" and .63 or .37,kind=="left" and .33 or .67
        line(f,a,.20,b,.50,color) line(f,b,.50,a,.80,color)
    elseif kind=="store" or kind=="take" then
        local a,b=kind=="store" and .15 or .85,kind=="store" and .80 or .20
        local tail=kind=="store" and .57 or .43
        line(f,a,.5,b,.5,color) line(f,tail,.26,b,.5,color) line(f,b,.5,tail,.74,color)
    elseif kind=="lock" then
        local u=rect(f,.5,.36,.42,.44,color,0,.4)
        local hole=rect(u,.5,.49,.55,.65,cream,0,.4)
        rect(f,.5,.65,.60,.45,color,0,.12)
    elseif kind=="water" then
        rect(f,.5,.59,.51,.51,color,0,1) rect(f,.5,.40,.35,.35,color,45,.12)
    elseif kind=="Blue" then
        rect(f,.5,.5,.70,.70,Color3.fromRGB(65,124,173),0,.16)
        rect(f,.5,.5,.25,.25,cream,0,1)
    elseif kind=="Silver" then
        rect(f,.5,.5,.61,.61,Color3.fromRGB(183,195,202),45,.06)
        line(f,.36,.35,.64,.35,ink,.06) line(f,.36,.65,.64,.65,ink,.06)
    elseif kind=="Gold" then
        rect(f,.5,.5,.70,.70,Color3.fromRGB(222,173,67),0,1)
        line(f,.27,.36,.38,.68,ink,.08) line(f,.38,.68,.5,.35,ink,.08)
        line(f,.5,.35,.62,.68,ink,.08) line(f,.62,.68,.74,.36,ink,.08)
    elseif kind=="Common" then
        -- Common has no visible badge.
    else error("Unknown UI primitive: "..tostring(kind)) end
    return f
end
function P.panel(parent,size,position)
    local f=Instance.new("Frame") f.BackgroundColor3=cream f.BorderSizePixel=0
    f.Size=size f.Position=position f.Parent=parent
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,24) c.Parent=f
    return f
end
return P
