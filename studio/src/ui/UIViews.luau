local C=require(script.Parent.Catalog) local I=require(script.Parent.Inventory)
local A=require(script.Parent.UIAssets) local P=require(script.Parent.UIPrimitives) local S=require(script.Parent.UIStyle)
local GS=game:GetService("GuiService") local UIS=game:GetService("UserInputService")
local Views={}
function Views.attach(v)
    function v:rebuild()
        local mode=self.Mode if not mode then return end
        local focused=GS.SelectedObject and GS.SelectedObject.Name
        local panel=self.Panel
        local old=panel:FindFirstChild("Content") if old then old:Destroy() end
        local content=Instance.new("Frame") content.Name="Content" content.BackgroundTransparency=1 content.Size=UDim2.fromScale(1,1) content.Parent=panel
        local compactBag=self.Small and mode=="Bag"
        local cols=compactBag and 2 or self.Small and 3 or (mode=="Chest" and 3 or 4)
        local rows=mode=="Chest" and not self.Small and 2 or 1
        local width=cols*112+32+(compactBag and 112 or 0) local height=mode=="Chest" and (self.Small and 252 or 380) or 244
        if mode=="Bag" then height=compactBag and 244 or 296 end
        if mode=="Details" then width=self.Small and 368 or 480 height=280 end
        panel.Size=UDim2.fromOffset(width,height) panel.Position=UDim2.new(1,-16,0,self.Small and 12 or 90)
        local function btn(name,text,x,y,w,h,fn)
            local b=S.button(content,name,text,fn) b.Position=UDim2.fromOffset(x,y) b.Size=UDim2.fromOffset(w,h) return b
        end
        local function text(value,x,y,w,h,size)
            local l=S.text(content,value,size or 24) l.Position=UDim2.fromOffset(x,y) l.Size=UDim2.fromOffset(w,h) return l
        end
        local title=text(mode,16,2,width-88,50,34) title.TextXAlignment=Enum.TextXAlignment.Left
        local close=btn("Close","",width-64,2,56,52,self.Close) P.icon(close,"close")
        local itemName=text("",16,height-62,width-154,56,24) itemName.Name="ItemName" itemName.TextXAlignment=Enum.TextXAlignment.Left
        local entries={} local gridY=56 local state=self.State local pageSize=cols*rows
        if mode=="Seeds" then entries=state.Loaded and I.entries(state,"Seeds") or {}
        elseif mode=="Bag" then
            entries=state.Loaded and I.entries(state,self.Category) or {} gridY=compactBag and 56 or 108
            for j,cat in ipairs({"Seeds","Produce","Tools"}) do local b=btn(cat,cat,compactBag and 16 or 16+(j-1)*112,compactBag and 56+(j-1)*56 or 54,108,48,function() self.Category=cat self.Page=1 self:rebuild() end) S.selected(b,self.Category==cat) end
        elseif mode=="Chest" then entries=state.Loaded and I.entries(state,nil,true) or {}
        elseif mode=="Market" then
            btn("Buy","Buy",16,82,148,64,function() self.Mode="Shop" self.Page=1 self:rebuild() end)
            btn("Sell","Sell",180,82,148,64,function() self.Mode="Sell" self.Page=1 self:rebuild() end) return
        elseif mode=="Shop" then
            for _,id in ipairs(C.Order) do local c=C.Crops[id] table.insert(entries,{Item=c.SeedId,Count=4,Key=id}) end
            table.insert(entries,{Item="fertilizer_bag",Count=12,Key="fertilizer_bag"})
        elseif mode=="Buy" then
            local offer=self.Offer local crop=C.Items[offer.Item].Crop local c=crop and C.Crops[crop]
            local count=offer.Quantity local price=c and c.Packs[count] or C.Equipment.fertilizer_bag.Price
            S.icon(content,offer.Item,UDim2.fromOffset(108,116),UDim2.fromOffset(16,56))
            text(tostring(count).."  ·  "..price,130,56,210,52,30)
            S.icon(content,"sterne",UDim2.fromOffset(30,30),UDim2.fromOffset(width-46,68))
            if c then for j,n in ipairs({4,9}) do local b=btn("Pack"..n,tostring(n),138+(j-1)*86,120,76,52,function() offer.Quantity=n self:rebuild() end) S.selected(b,count==n) end end
            itemName.Text=A.Sprites[offer.Item].Label
            btn("Buy","Buy",width-140,height-62,124,56,function()
                self.Send({Kind="Buy",Crop=crop,Item=not c and offer.Item or nil,Quantity=count},function(r) if r.Ok then self.Mode="Shop" self:rebuild() end end)
            end) return
        elseif mode=="Sell" then entries=state.Loaded and I.entries(state,"Produce") or {}
        elseif mode=="Review" then
            for _,line in ipairs(self.Quote.Lines) do table.insert(entries,{Item=C.Crops[line.Crop].HarvestId,Quality=line.Quality,Count=line.Quantity,Key=line.Crop..":"..line.Quality,Unit=line.Unit}) end
        elseif mode=="Details" then
            text(self.Failure or "Connection interrupted.",16,60,width-32,148,24)
            btn("Retry","Retry",16,216,140,56,function() self.Send(self.FailedTransfer or {Kind="Snapshot"},function() if self.State.Loaded and not self.State.Blocked then self.Close() end end) end) return
        end
        local pages=math.max(1,math.ceil(#entries/pageSize)) self.Page=math.clamp(self.Page,1,pages)
        local headerPages=compactBag or mode=="Chest" or mode=="Sell" or mode=="Review"
        if pages>1 then
            if headerPages then title.Size=UDim2.fromOffset(width-210,50) end
            local py=headerPages and 2 or height-60 local px=headerPages and width-184 or width-136
            btn("Previous","‹",px,py,52,52,function() self.Page=(self.Page-2)%pages+1 self:rebuild() end)
            btn("Next","›",px+58,py,52,52,function() self.Page=self.Page%pages+1 self:rebuild() end)
        end
        for index=(self.Page-1)*pageSize+1,math.min(self.Page*pageSize,#entries) do
            local e=entries[index] local position=index-(self.Page-1)*pageSize-1 local x=16+(compactBag and 112 or 0)+(position%cols)*112 local y=gridY+math.floor(position/cols)*124
            local b=btn(e.Key or e.Item,"",x,y,104,116,function()
                if mode=="Seeds" or mode=="Bag" then self.Equip(e)
                elseif mode=="Shop" then self.Offer={Item=e.Item,Quantity=e.Count} self.Mode="Buy" self:rebuild()
                else self.Selected=e self.Amount=nil self.AmountOpen=false self:rebuild() end
            end)
            b.BackgroundColor3=A.Colors.slot S.icon(b,e.Item,UDim2.fromOffset(90,82),UDim2.fromOffset(7,3))
            local count=S.text(b,tostring(e.Count),30) count.Position=UDim2.fromOffset(0,84) count.Size=UDim2.fromOffset(104,32)
            S.badge(b,e.Quality) S.selected(b,(self.Selected and self.Selected.Key==e.Key) or (state.Equipped and state.Equipped.Item==e.Item and state.Equipped.Quality==e.Quality) or false)
            local function describe() itemName.Text=A.Sprites[e.Item].Label..(e.Quality and e.Quality~="Common" and " · "..e.Quality or "") end
            b.MouseEnter:Connect(describe) b.SelectionGained:Connect(describe)
            if mode=="Review" then count.TextSize=22 count.Text=e.Count.." × "..e.Unit end
        end
        if compactBag then itemName.Position=UDim2.fromOffset(128,180) itemName.Size=UDim2.fromOffset(width-144,56) end
        if #entries==0 then text(mode=="Seeds" and "No Seeds" or "Empty",16,80,width-32,64,28) end
        if mode=="Chest" then
            itemName.Visible=false
            local entry=self.Selected or (self.Held and {Item=self.Held.Item,Quality=self.Held.Quality,Count=I.quantity(state,self.Held.Item,self.Held.Quality)})
            local y=height-66
            if entry and entry.Count>0 then
                S.icon(content,entry.Item,UDim2.fromOffset(56,56),UDim2.fromOffset(16,y))
                text(tostring(self.Amount or entry.Count),76,y,72,56,30)
                btn("Transfer",self.Selected and "Take" or "Store",154,y,110,56,function()
                    self.Send({Kind=self.Selected and "Withdraw" or "Deposit",Chest=self.Chest,Item=entry.Item,Quality=entry.Quality,Quantity=self.Amount or entry.Count,RequestId=game:GetService("HttpService"):GenerateGUID(false)},function(r) if r.Ok then self.Selected=nil self.Amount=nil self.AmountOpen=false end end)
                end)
                btn("Amount","Amount",270,y,82,56,function() self.AmountOpen=not self.AmountOpen self.Amount=self.Amount or entry.Count self:rebuild() end).TextSize=22
                if self.AmountOpen then
                    for _,child in ipairs(content:GetChildren()) do if child:IsA("TextButton") and child.Position.Y.Offset>=gridY and child.Position.Y.Offset<y then child.Visible=false end end
                    btn("Minus","−",16,gridY+8,64,64,function() self.Amount=math.max(1,self.Amount-1) self:rebuild() end)
                    btn("Plus","+",88,gridY+8,64,64,function() self.Amount=math.min(entry.Count,self.Amount+1) self:rebuild() end)
                    btn("All","All",160,gridY+8,92,64,function() self.Amount=entry.Count self:rebuild() end)
                    btn("Done","✓",264,gridY+8,64,64,function() self.AmountOpen=false self:rebuild() end)
                end
            else text("Select a hotbar item",16,y,width-32,56,24) end
        elseif mode=="Sell" then
            itemName.Visible=false local entry=self.Selected
            if entry then
                local n=self.Sales[entry.Key] or entry.Count local y=height-62
                btn("Minus","−",16,y,52,52,function() self.Sales[entry.Key]=math.max(0,n-1) self:rebuild() end)
                btn("Plus","+",74,y,52,52,function() self.Sales[entry.Key]=math.min(entry.Count,n+1) self:rebuild() end)
                btn("All","All",132,y,62,52,function() self.Sales[entry.Key]=entry.Count self:rebuild() end)
                text(tostring(n),196,y,52,52,26)
                btn("Review","Review",252,y,100,52,function()
                    self.Sales[entry.Key]=n local lines={}
                    for _,e in ipairs(I.entries(state,"Produce")) do local count=self.Sales[e.Key] or 0 if count>0 then table.insert(lines,{Crop=C.Items[e.Item].Crop,Quality=e.Quality,Quantity=count}) end end
                    self.Send({Kind="Quote",Lines=lines},function(r) if r.Ok then self.Quote=r.Quote self.Mode="Review" self.Page=1 self:rebuild() end end)
                end).TextSize=22
            end
        elseif mode=="Review" then
            itemName.Text="Total "..self.Quote.Total
            btn("Sell","Sell",width-130,height-62,114,56,function() self.Send({Kind="Sell",QuoteId=self.Quote.Id},function(r) self.Quote=nil self.Mode="Sell" self.Selected=nil if r.Ok then self.Sales={} else self.Show("Updated") end self:rebuild() end) end)
        end
        if UIS.GamepadEnabled then GS.SelectedObject=(focused and content:FindFirstChild(focused)) or close end
    end
end
return Views
