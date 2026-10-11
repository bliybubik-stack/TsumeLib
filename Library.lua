-- Glassline UI Library | Roblox Studio ModuleScript
-- Reusable UI for experiences you own. No executor APIs or remote code execution.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library
Library.Options = {}
Library.Toggles = {}
Library.Unloaded = false
Library.Theme = {
    Background = Color3.fromRGB(17, 18, 21),
    Surface = Color3.fromRGB(27, 29, 34),
    Hover = Color3.fromRGB(39, 42, 48),
    Border = Color3.fromRGB(105, 110, 122),
    Text = Color3.fromRGB(240, 242, 246),
    Muted = Color3.fromRGB(157, 162, 173),
    Accent = Color3.fromRGB(218, 224, 235),
    AccentText = Color3.fromRGB(20, 22, 26),
}

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function round(obj, px)
    new("UICorner", {CornerRadius = UDim.new(0, px or 8)}, obj)
end
local function outline(obj, color, transparency)
    return new("UIStroke", {Color = color or Library.Theme.Border, Transparency = transparency or 0.5, Thickness = 1}, obj)
end
local function animate(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function makeText(parent, value, size, color, bold)
    return new("TextLabel", {
        BackgroundTransparency = 1, Text = tostring(value or ""), Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        TextSize = size or 12, TextColor3 = color or Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = true, Size = UDim2.new(1, 0, 0, 20),
    }, parent)
end
local function panel(parent, transparency, radius)
    local f = new("Frame", {BackgroundColor3 = Library.Theme.Surface, BackgroundTransparency = transparency or 0.15, BorderSizePixel = 0}, parent)
    round(f, radius or 9); outline(f, Library.Theme.Border, 0.55)
    return f
end

local function register(lib, id, initial, callback, isToggle)
    assert(type(id) == "string" and id ~= "", "Control ID must be a non-empty string")
    local object = {Value = initial, Callback = callback, _listeners = {}}
    function object:OnChanged(fn) table.insert(self._listeners, fn); return self end
    function object:SetValue(value)
        self.Value = value
        if self._render then self:_render(value) end
        for _, fn in ipairs(self._listeners) do task.spawn(fn, value) end
        if self.Callback then task.spawn(self.Callback, value) end
    end
    local registry = isToggle and lib.Toggles or lib.Options
    registry[id] = object
    return object
end

function Library:CreateWindow(config)
    config = config or {}
    local player = Players.LocalPlayer
    assert(player, "CreateWindow must be called from a LocalScript")
    self.Unloaded = false
    local gui = new("ScreenGui", {Name = "GlasslineUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, player:WaitForChild("PlayerGui"))
    self.ScreenGui = gui
    local root = panel(gui, 0.08, 13)
    root.Name = "Window"
    root.Size = config.Size or UDim2.fromOffset(720, 480)
    root.Position = config.Position or UDim2.new(0.5, -360, 0.5, -240)
    root.ClipsDescendants = true
    self.Root = root

    local top = new("Frame", {Name = "Topbar", BackgroundColor3 = self.Theme.Surface, BackgroundTransparency = 0.18, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 62)}, root)
    makeText(top, config.Title or "GLASSLINE", 16, self.Theme.Text, true).Position = UDim2.fromOffset(17, 7)
    local subtitle = makeText(top, config.Footer or "UI FRAMEWORK  •  v1.0", 10, self.Theme.Muted, false)
    subtitle.Position = UDim2.fromOffset(17, 34)
    new("Frame", {BackgroundColor3 = self.Theme.Border, BackgroundTransparency = 0.68, BorderSizePixel = 0, Position = UDim2.new(0, 14, 1, -1), Size = UDim2.new(1, -28, 0, 1)}, top)
    local close = new("TextButton", {Text = "×", Font = Enum.Font.Gotham, TextSize = 24, TextColor3 = self.Theme.Muted, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.2, BorderSizePixel = 0, Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -46, 0, 14), AutoButtonColor = false}, top)
    round(close, 8)
    close.MouseEnter:Connect(function() animate(close, {TextColor3 = self.Theme.Text, BackgroundTransparency = 0.02}) end)
    close.MouseLeave:Connect(function() animate(close, {TextColor3 = self.Theme.Muted, BackgroundTransparency = 0.2}) end)
    close.Activated:Connect(function() self:Unload() end)

    local sidebar = new("ScrollingFrame", {Name = "Sidebar", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(11, 73), Size = UDim2.new(0, 154, 1, -85), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = self.Theme.Border}, root)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
    new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 3)}, sidebar)
    local content = new("Frame", {Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0, 177, 0, 73), Size = UDim2.new(1, -189, 1, -85)}, root)
    self.Window = {Root = root, Sidebar = sidebar, Content = content, Tabs = {}, ActiveTab = nil}

    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, root.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    self._dragConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self._toggleKey = config.ToggleKeybind or Enum.KeyCode.RightControl
    self._keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self._toggleKey and gui.Parent then root.Visible = not root.Visible end
    end)
    return self.Window
end

function Library:AddTab(name, iconName)
    local win = assert(self.Window, "Call CreateWindow first")
    local button = new("TextButton", {Name = name, Text = "   " .. name, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamSemibold, TextSize = 12, TextColor3 = self.Theme.Muted, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false}, win.Sidebar)
    round(button, 7)
    local page = new("ScrollingFrame", {Name = name .. "Page", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = self.Theme.Border}, win.Content)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 6), PaddingRight = UDim.new(0, 3)}, page)
    local tab = {Name = name, Button = button, Page = page, Columns = {}, Library = self}
    function tab:AddGroupbox(opts) return self.Library:_AddGroupbox(self, opts) end
    function tab:AddLeftGroupbox(label) return self:AddGroupbox({Name = label, Side = "Left"}) end
    function tab:AddRightGroupbox(label) return self:AddGroupbox({Name = label, Side = "Right"}) end
    button.Activated:Connect(function()
        for _, other in pairs(win.Tabs) do other.Page.Visible = false; animate(other.Button, {BackgroundTransparency = 1, TextColor3 = self.Theme.Muted}) end
        page.Visible = true; win.ActiveTab = tab
        animate(button, {BackgroundTransparency = 0.22, TextColor3 = self.Theme.Text})
    end)
    win.Tabs[name] = tab
    if not win.ActiveTab then button:Activate() end
    return tab
end

function Library:_AddGroupbox(tab, opts)
    opts = opts or {}
    local side = string.lower(opts.Side or "Left")
    local column = tab.Columns[side]
    if not column then
        column = new("Frame", {Name = side .. "Column", BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)}, tab.Page)
        new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, column)
        tab.Columns[side] = column
    end
    local box = panel(column, 0.17, 9)
    box.Name = opts.Name or "Groupbox"
    box.Size = UDim2.new(1, 0, 0, 10); box.AutomaticSize = Enum.AutomaticSize.Y
    new("UIPadding", {PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11), PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11)}, box)
    new("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, box)
    local heading = makeText(box, opts.Name or "Group", 13, self.Theme.Text, true); heading.LayoutOrder = 1
    if opts.Description then local d = makeText(box, opts.Description, 10, self.Theme.Muted); d.LayoutOrder = 2 end
    local group = {Frame = box, Library = self}
    function group:AddToggle(id, info) return self.Library:_AddToggle(self, id, info or {}, false) end
    function group:AddCheckbox(id, info) return self.Library:_AddToggle(self, id, info or {}, true) end
    function group:AddButton(info, callback)
        if type(info) == "string" then info = {Text = info, Func = callback} end
        return self.Library:_AddButton(self, info or {})
    end
    function group:AddLabel(value, wrap)
        local lbl = makeText(box, value, 11, self.Library.Theme.Muted); lbl.TextWrapped = wrap ~= false; lbl.LayoutOrder = 50
        return {Instance = lbl, SetText = function(_, v) lbl.Text = tostring(v) end}
    end
    function group:AddDivider() return new("Frame", {BackgroundColor3 = self.Library.Theme.Border, BackgroundTransparency = 0.6, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)}, box) end
    function group:AddSlider(id, info) return self.Library:_AddSlider(self, id, info or {}) end
    function group:AddInput(id, info) return self.Library:_AddInput(self, id, info or {}) end
    function group:AddDropdown(id, info) return self.Library:_AddDropdown(self, id, info or {}) end
    return group
end

function Library:_AddToggle(group, id, info, checkbox)
    local row = new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 27)}, group.Frame)
    local lbl = makeText(row, info.Text or id, 12, self.Theme.Text); lbl.Size = UDim2.new(1, -52, 1, 0)
    local control = new("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.08, BorderSizePixel = 0, Size = UDim2.fromOffset(checkbox and 19 or 37, checkbox and 19 or 20), Position = UDim2.new(1, checkbox and -19 or -37, 0.5, checkbox and -9 or -10)}, row)
    round(control, checkbox and 5 or 10); outline(control, self.Theme.Border, 0.65)
    local knob = new("Frame", {BackgroundColor3 = self.Theme.Muted, BorderSizePixel = 0, Size = UDim2.fromOffset(13, 13), Position = UDim2.fromOffset(3, 3)}, control); round(knob, checkbox and 3 or 8)
    local obj = register(self, id, info.Default == true, info.Callback, true)
    local theme = self.Theme
    function obj:_render(value)
        if checkbox then
            animate(control, {BackgroundColor3 = value and theme.Accent or theme.Hover}, 0.12)
            animate(knob, {BackgroundColor3 = value and theme.AccentText or theme.Muted, Position = UDim2.fromOffset(3, 3)}, 0.12)
            knob.Visible = value
        else
            animate(control, {BackgroundColor3 = value and theme.Accent or theme.Hover}, 0.12)
            animate(knob, {Position = value and UDim2.new(1, -16, 0, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = value and theme.AccentText or theme.Muted}, 0.12)
        end
    end
    obj:_render(obj.Value)
    control.Activated:Connect(function() if not info.Disabled then obj:SetValue(not obj.Value) end end)
    return obj
end

function Library:_AddButton(group, info)
    local b = new("TextButton", {Text = info.Text or "Button", Font = Enum.Font.GothamSemibold, TextSize = 12, TextColor3 = self.Theme.Text, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.18, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), AutoButtonColor = false}, group.Frame)
    round(b, 7); outline(b, self.Theme.Border, 0.65)
    b.MouseEnter:Connect(function() animate(b, {BackgroundTransparency = 0.02}) end)
    b.MouseLeave:Connect(function() animate(b, {BackgroundTransparency = 0.18}) end)
    b.Activated:Connect(function() if not info.Disabled and info.Func then task.spawn(info.Func) end end)
    return {Instance = b}
end

function Library:_AddSlider(group, id, info)
    local min, max = tonumber(info.Min) or 0, tonumber(info.Max) or 100
    local value = math.clamp(tonumber(info.Default) or min, min, max)
    local row = new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48)}, group.Frame)
    local lbl = makeText(row, info.Text or id, 12, self.Theme.Text); lbl.Size = UDim2.new(1, -65, 0, 20)
    local val = makeText(row, tostring(value) .. (info.Suffix or ""), 11, self.Theme.Muted); val.TextXAlignment = Enum.TextXAlignment.Right; val.Position = UDim2.new(1, -62, 0, 0); val.Size = UDim2.fromOffset(62, 20)
    local bar = new("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = self.Theme.Hover, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 6)}, row); round(bar, 5)
    local fill = new("Frame", {BackgroundColor3 = self.Theme.Accent, BorderSizePixel = 0, Size = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 1, 0)}, bar); round(fill, 5)
    local obj = register(self, id, value, info.Callback, false)
    local dragging = false
    local function setAt(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local scale = 10 ^ (tonumber(info.Rounding) or 0)
        obj:SetValue(math.floor((min + (max - min) * ratio) * scale + 0.5) / scale)
    end
    function obj:_render(v) val.Text = tostring(v) .. (info.Suffix or ""); animate(fill, {Size = UDim2.new((v - min) / math.max(max - min, 0.001), 0, 1, 0)}, 0.07) end
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setAt(input.Position.X) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setAt(input.Position.X) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    obj:_render(value)
    return obj
end

function Library:_AddInput(group, id, info)
    makeText(group.Frame, info.Text or id, 12, self.Theme.Text)
    local box = new("TextBox", {Text = tostring(info.Default or ""), PlaceholderText = info.Placeholder or "Enter text...", ClearTextOnFocus = info.ClearTextOnFocus == true, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = self.Theme.Text, PlaceholderColor3 = self.Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.15, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32)}, group.Frame)
    round(box, 7); outline(box, self.Theme.Border, 0.65); new("UIPadding", {PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 8)}, box)
    local obj = register(self, id, box.Text, info.Callback, false)
    box.FocusLost:Connect(function() if info.Numeric then local n = tonumber(box.Text); if n then obj:SetValue(n) else box.Text = tostring(obj.Value) end else obj:SetValue(box.Text) end end)
    function obj:_render(v) box.Text = tostring(v) end
    return obj
end

function Library:_AddDropdown(group, id, info)
    local values = info.Values or {"Option 1", "Option 2"}
    local selected = info.Default
    if type(selected) == "number" then selected = values[selected] end
    selected = selected or values[1]
    makeText(group.Frame, info.Text or id, 12, self.Theme.Text)
    local button = new("TextButton", {Text = tostring(selected) .. "     ▾", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.15, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), AutoButtonColor = false}, group.Frame)
    round(button, 7); new("UIPadding", {PaddingLeft = UDim.new(0, 9)}, button)
    local options = new("Frame", {Visible = false, BackgroundColor3 = self.Theme.Surface, BackgroundTransparency = 0.02, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, math.min(#values, 5) * 28), ZIndex = 5}, group.Frame)
    round(options, 7); outline(options, self.Theme.Border, 0.3)
    new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, options)
    new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, options)
    local obj = register(self, id, selected, info.Callback, false)
    function obj:_render(v) button.Text = tostring(v) .. "     ▾" end
    for _, item in ipairs(values) do
        local option = new("TextButton", {Text = tostring(item), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26), ZIndex = 6, AutoButtonColor = false}, options)
        round(option, 5); new("UIPadding", {PaddingLeft = UDim.new(0, 7)}, option)
        option.MouseEnter:Connect(function() animate(option, {BackgroundTransparency = 0.15}, 0.08) end)
        option.MouseLeave:Connect(function() animate(option, {BackgroundTransparency = 1}, 0.08) end)
        option.Activated:Connect(function() obj:SetValue(item); options.Visible = false end)
    end
    button.Activated:Connect(function() options.Visible = not options.Visible end)
    return obj
end

function Library:Notify(info)
    if not self.ScreenGui then return end
    info = info or {}
    local toast = panel(self.ScreenGui, 0.06, 9)
    toast.Name = "Notification"; toast.Size = UDim2.fromOffset(285, 75); toast.AnchorPoint = Vector2.new(1, 1); toast.Position = UDim2.new(1, 310, 1, -18)
    new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 7)}, toast)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, toast)
    local title = makeText(toast, info.Title or "Notification", 13, self.Theme.Text, true); title.LayoutOrder = 1
    local desc = makeText(toast, info.Description or "", 11, self.Theme.Muted); desc.LayoutOrder = 2
    animate(toast, {Position = UDim2.new(1, -18, 1, -18)}, 0.2)
    task.delay(tonumber(info.Time) or 3, function() if toast.Parent then animate(toast, {Position = UDim2.new(1, 310, 1, -18)}, 0.18); task.wait(0.2); toast:Destroy() end end)
end

function Library:Unload()
    self.Unloaded = true
    if self._dragConnection then self._dragConnection:Disconnect(); self._dragConnection = nil end
    if self._keyConnection then self._keyConnection:Disconnect(); self._keyConnection = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    self.Root = nil
end

return Library
