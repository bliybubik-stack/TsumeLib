-- Glassline UI Library (Roblox Studio ModuleScript)
-- Original Obsidian/Linoria-inspired API; intended for experiences you own.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Library = {}
Library.__index = Library
Library.Options, Library.Toggles = {}, {}
Library.Theme = {
 Background=Color3.fromRGB(17,18,21), Surface=Color3.fromRGB(28,30,35),
 Hover=Color3.fromRGB(42,44,50), Border=Color3.fromRGB(105,110,121),
 Text=Color3.fromRGB(239,241,245), Muted=Color3.fromRGB(157,162,173),
 Accent=Color3.fromRGB(211,218,229), AccentText=Color3.fromRGB(20,21,24)
}
local function new(class, props, parent)
 local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end; o.Parent=parent; return o
end
local function tween(o,p,t) TweenService:Create(o,TweenInfo.new(t or .15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local function round(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function outline(o,trans)
 new("UIStroke",{Color=Library.Theme.Border,Transparency=trans or .45,Thickness=1},o)
end
local function label(parent,txt,size,color,bold)
 return new("TextLabel",{BackgroundTransparency=1,Text=tostring(txt or ""),Font=bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,TextSize=size or 12,TextColor3=color or Library.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,Size=UDim2.new(1,0,0,20)},parent)
end
local function frame(parent,color,transparency,r)
 local f=new("Frame",{BackgroundColor3=color or Library.Theme.Surface,BackgroundTransparency=transparency or .15,BorderSizePixel=0},parent); round(f,r or 9); outline(f); return f
end
function Library:Notify(info)
 if not self.ScreenGui then return end; info=info or {}
 local f=frame(self.ScreenGui,self.Theme.Surface,.04,10); f.Size=UDim2.fromOffset(290,76); f.AnchorPoint=Vector2.new(1,1); f.Position=UDim2.new(1,310,1,-18); f.ZIndex=30
 new("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},f)
 new("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},f)
 local a=label(f,info.Title or "Notification",14,self.Theme.Text,true); a.LayoutOrder=1; a.ZIndex=31
 local b=label(f,info.Description or "",12,self.Theme.Muted,false); b.LayoutOrder=2; b.ZIndex=31
 tween(f,{Position=UDim2.new(1,-18,1,-18)},.2)
 task.delay(tonumber(info.Time) or 3,function() if f.Parent then tween(f,{Position=UDim2.new(1,310,1,-18)},.2); task.wait(.22); f:Destroy() end end)
end
function Library:CreateWindow(config)
 config=config or {}; local player=Players.LocalPlayer
 local gui=new("ScreenGui",{Name="GlasslineUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild("PlayerGui")); self.ScreenGui=gui
 local root=frame(gui,self.Theme.Background,.07,13); root.Name="Window"; root.Size=config.Size or UDim2.fromOffset(700,470); root.Position=config.Position or UDim2.new(.5,-350,.5,-235); root.ClipsDescendants=true; self.Root=root
 local top=new("Frame",{BackgroundColor3=self.Theme.Surface,BackgroundTransparency=.2,BorderSizePixel=0,Size=UDim2.new(1,0,0,58)},root)
 new("Frame",{BackgroundColor3=self.Theme.Border,BackgroundTransparency=.55,BorderSizePixel=0,Position=UDim2.new(0,15,1,-1),Size=UDim2.new(1,-30,0,1)},top)
 local title=label(top,config.Title or "GLASSLINE",16,self.Theme.Text,true); title.Position=UDim2.fromOffset(17,6); title.Size=UDim2.new(1,-90,0,24)
 local footer=label(top,config.Footer or "UI FRAMEWORK",10,self.Theme.Muted,false); footer.Position=UDim2.fromOffset(18,31); footer.Size=UDim2.new(1,-90,0,16)
 local close=new("TextButton",{Text="×",Font=Enum.Font.Gotham,TextSize=23,TextColor3=self.Theme.Muted,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=.25,BorderSizePixel=0,Size=UDim2.fromOffset(31,31),Position=UDim2.new(1,-45,0,13),AutoButtonColor=false},top); round(close,8)
 close.MouseEnter:Connect(function() tween(close,{TextColor3=self.Theme.Text,BackgroundTransparency=.05}) end); close.MouseLeave:Connect(function() tween(close,{TextColor3=self.Theme.Muted,BackgroundTransparency=.25}) end)
 close.Activated:Connect(function() self:Unload() end)
 local sidebar=new("ScrollingFrame",{Name="Sidebar",BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(12,69),Size=UDim2.new(0,150,1,-81),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=self.Theme.Border},root)
 new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sidebar); new("UIPadding",{PaddingTop=UDim.new(0,4),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,4)},sidebar)
 local content=new("Frame",{Name="Pages",BackgroundTransparency=1,Position=UDim2.new(0,174,0,69),Size=UDim2.new(1,-186,1,-81)},root)
 self.Window={Root=root,Sidebar=sidebar,Content=content,Tabs={},ActiveTab=nil}; self._drag=false
 local dragStart,startPos
 top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then self._drag=true; dragStart=i.Position; startPos=root.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then self._drag=false end end) end end)
 self._dragConn=UserInputService.InputChanged:Connect(function(i) if self._drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
 self.ToggleKeybind=config.ToggleKeybind or Enum.KeyCode.RightControl
 self._keyConn=UserInputService.InputBegan:Connect(function(i,processed) if not processed and i.KeyCode==self.ToggleKeybind and gui.Parent then root.Visible=not root.Visible end end)
 return {Library=self,Tabs=self.Window.Tabs,Root=root}
end
function Library:AddTab(name,icon)
 assert(self.Window,"CreateWindow must be called first"); local w=self.Window
 local b=new("TextButton",{Text="  "..name,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=self.Theme.Muted,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,35),AutoButtonColor=false},w.Sidebar); round(b,7)
 local page=new("ScrollingFrame",{Name=name.."Page",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),Visible=false,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=self.Theme.Border},w.Content)
 new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalFlex=Enum.UIFlexAlignment.Fill},page); new("UIPadding",{PaddingTop=UDim.new(0,2),PaddingRight=UDim.new(0,3),PaddingBottom=UDim.new(0,6)},page)
 local tab={Name=name,Button=b,Page=page,Columns={},Library=self}
 function tab:AddGroupbox(opts) return self.Library:_Group(self,opts or {}) end
 function tab:AddLeftGroupbox(name) return self:AddGroupbox({Name=name,Side="Left"}) end
 function tab:AddRightGroupbox(name) return self:AddGroupbox({Name=name,Side="Right"}) end
 b.Activated:Connect(function() for _,t in pairs(w.Tabs) do t.Page.Visible=false; tween(t.Button,{BackgroundTransparency=1,TextColor3=self.Theme.Muted},.1) end; page.Visible=true; w.ActiveTab=tab; tween(b,{BackgroundTransparency=.25,TextColor3=self.Theme.Text},.1) end)
 w.Tabs[name]=tab; if not w.ActiveTab then b:Activate() end; return tab
end
function Library:_Group(tab,opts)
 local side=string.lower(opts.Side or "Left"); local col=tab.Columns[side]
 if not col then col=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(.5,-5,1,0)},tab.Page); new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},col); tab.Columns[side]=col end
 local box=frame(col,self.Theme.Surface,.18,9); box.Name=opts.Name or "Groupbox"; box.Size=UDim2.new(1,0,0,10); box.AutomaticSize=Enum.AutomaticSize.Y
 new("UIPadding",{PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11),PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11)},box); new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},box)
 local h=label(box,opts.Name or "Group",13,self.Theme.Text,true); h.LayoutOrder=1
 if opts.Description then local d=label(box,opts.Description,10,self.Theme.Muted,false); d.LayoutOrder=2 end
 local g={Frame=box,Library=self}
 function g:AddToggle(id,info) return self.Library:_Toggle(self,id,info or {},true) end
 function g:AddCheckbox(id,info) return self.Library:_Toggle(self,id,info or {},true) end
 function g:AddButton(info,legacy) if type(info)=="string" then info={Text=info,Func=legacy} end; return self.Library:_Button(self,info or {}) end
 function g:AddLabel(value,wrap) local l=label(box,value,11,self.Library.Theme.Muted,false); l.TextWrapped=wrap~=false; return {Instance=l,SetText=function(_,v) l.Text=tostring(v) end} end
 function g:AddDivider() return new("Frame",{BackgroundColor3=self.Library.Theme.Border,BackgroundTransparency=.6,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},box) end
 function g:AddSlider(id,info) return self.Library:_Slider(self,id,info or {}) end
 function g:AddInput(id,info) return self.Library:_Input(self,id,info or {}) end
 function g:AddDropdown(id,info) return self.Library:_Dropdown(self,id,info or {}) end
 return g
end
local function register(lib,id,obj,isToggle)
 obj._callbacks={}; function obj:OnChanged(cb) table.insert(self._callbacks,cb) end
 function obj:SetValue(v) self.Value=v; if self._render then self:_render(v) end; for _,cb in ipairs(self._callbacks) do task.spawn(cb,v) end; if self.Callback then task.spawn(self.Callback,v) end end
 if isToggle then lib.Toggles[id]=obj else lib.Options[id]=obj end; return obj
end
function Library:_Toggle(g,id,info,isToggle)
 local row=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,26)},g.Frame); local l=label(row,info.Text or id,11,self.Theme.Text,false); l.Size=UDim2.new(1,-50,1,0)
 local sw=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=self.Theme.Hover,BorderSizePixel=0,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-38,.5,-10)},row); round(sw,10)
 local knob=new("Frame",{BackgroundColor3=self.Theme.Muted,BorderSizePixel=0,Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3)},sw); round(knob,8)
 local selfTheme=self.Theme
 local obj=register(self,id,{Value=info.Default==true,Callback=info.Callback},true)
 function obj:_render(v) tween(sw,{BackgroundColor3=v and selfTheme.Accent or selfTheme.Hover},.12); tween(knob,{Position=v and UDim2.new(1,-17,0,3) or UDim2.fromOffset(3,3),BackgroundColor3=v and selfTheme.AccentText or selfTheme.Muted},.12) end
 obj:_render(obj.Value); sw.Activated:Connect(function() if not info.Disabled then obj:SetValue(not obj.Value) end end); return obj
end
function Library:_Button(g,info)
 local b=new("TextButton",{Text=info.Text or "Button",Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=self.Theme.Text,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=.15,BorderSizePixel=0,Size=UDim2.new(1,0,0,31),AutoButtonColor=false},g.Frame); round(b,7); outline(b,.6)
 b.MouseEnter:Connect(function() tween(b,{BackgroundTransparency=0},.1) end); b.MouseLeave:Connect(function() tween(b,{BackgroundTransparency=.15},.1) end); b.Activated:Connect(function() if not info.Disabled and info.Func then task.spawn(info.Func) end end); return {Instance=b}
end
function Library:_Slider(g,id,info)
 local min,max=tonumber(info.Min) or 0,tonumber(info.Max) or 100; local start=math.clamp(tonumber(info.Default) or min,min,max)
 local row=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,45)},g.Frame); local l=label(row,info.Text or id,11,self.Theme.Text,false); l.Size=UDim2.new(1,-60,0,18)
 local vl=label(row,tostring(start)..(info.Suffix or ""),11,self.Theme.Muted,false); vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Position=UDim2.new(1,-60,0,0); vl.Size=UDim2.fromOffset(60,18)
 local bar=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=self.Theme.Hover,BorderSizePixel=0,Position=UDim2.new(0,0,0,28),Size=UDim2.new(1,0,0,6)},row); round(bar,5); local fill=new("Frame",{BackgroundColor3=self.Theme.Accent,BorderSizePixel=0,Size=UDim2.new((start-min)/math.max(max-min,.001),0,1,0)},bar); round(fill,5)
 local obj=register(self,id,{Value=start,Callback=info.Callback},false); local dragging=false
 local function setx(x) local r=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1); local v=min+(max-min)*r; local mult=10^(tonumber(info.Rounding) or 0); obj:SetValue(math.floor(v*mult+.5)/mult) end
 function obj:_render(v) vl.Text=tostring(v)..(info.Suffix or ""); tween(fill,{Size=UDim2.new((v-min)/math.max(max-min,.001),0,1,0)},.06) end
 bar.Activated:Connect(function() setx(UserInputService:GetMouseLocation().X) end); bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setx(i.Position.X) end end)
 local c1=UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setx(i.Position.X) end end); local c2=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
 obj:_render(start); return obj
end
function Library:_Input(g,id,info)
 local l=label(g.Frame,info.Text or id,11,self.Theme.Text,false)
 local box=new("TextBox",{Text=tostring(info.Default or ""),PlaceholderText=info.Placeholder or "Enter text...",ClearTextOnFocus=info.ClearTextOnFocus==true,Font=Enum.Font.Gotham,TextSize=11,TextColor3=self.Theme.Text,PlaceholderColor3=self.Theme.Muted,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=.16,BorderSizePixel=0,Size=UDim2.new(1,0,0,31)},g.Frame); round(box,7); outline(box,.65); new("UIPadding",{PaddingLeft=UDim.new(0,8)},box)
 local obj=register(self,id,{Value=box.Text,Callback=info.Callback},false); box.FocusLost:Connect(function() obj:SetValue(box.Text) end); function obj:_render(v) box.Text=tostring(v) end; return obj
end
function Library:_Dropdown(g,id,info)
 local vals=info.Values or {"Option 1","Option 2"}; local v=info.Default; if type(v)=="number" then v=vals[v] end; v=v or vals[1]
 label(g.Frame,info.Text or id,11,self.Theme.Text,false)
 local b=new("TextButton",{Text=tostring(v).."     ▾",Font=Enum.Font.Gotham,TextSize=11,TextColor3=self.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=.15,BorderSizePixel=0,Size=UDim2.new(1,0,0,31),AutoButtonColor=false},g.Frame); round(b,7); new("UIPadding",{PaddingLeft=UDim.new(0,8)},b)
 local list=frame(g.Frame,self.Theme.Surface,.02,7); list.Visible=false; list.Size=UDim2.new(1,0,0,math.min(#vals,5)*27); list.ZIndex=8; new("UIListLayout",{Padding=UDim.new(0,2)},list); new("UIPadding",{PaddingTop=UDim.new(0,3),PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,3)},list)
 local obj=register(self,id,{Value=v,Callback=info.Callback},false); function obj:_render(x) b.Text=tostring(x).."     ▾" end
 for _,item in ipairs(vals) do local opt=new("TextButton",{Text=tostring(item),Font=Enum.Font.Gotham,TextSize=11,TextColor3=self.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=self.Theme.Hover,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,25),ZIndex=9,AutoButtonColor=false},list); new("UIPadding",{PaddingLeft=UDim.new(0,6)},opt); round(opt,4); opt.MouseEnter:Connect(function() tween(opt,{BackgroundTransparency=.15},.08) end); opt.MouseLeave:Connect(function() tween(opt,{BackgroundTransparency=1},.08) end); opt.Activated:Connect(function() obj:SetValue(item); list.Visible=false end) end
 b.Activated:Connect(function() list.Visible=not list.Visible end); return obj
end
function Library:Unload()
 if self._keyConn then self._keyConn:Disconnect() end; if self._dragConn then self._dragConn:Disconnect() end; if self.ScreenGui then self.ScreenGui:Destroy() end; self.ScreenGui=nil; self.Root=nil
end
return Library
