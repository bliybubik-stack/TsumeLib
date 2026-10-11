-- Example LocalScript for a Roblox experience you own.
-- Put this in StarterPlayer > StarterPlayerScripts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packageFolder = ReplicatedStorage:WaitForChild("Glassline")
local Library = require(packageFolder:WaitForChild("Library"))
local Controls = require(packageFolder:WaitForChild("Controls"))
local ThemeManager = require(packageFolder:WaitForChild("Addons"):WaitForChild("ThemeManager"))
local SaveManager = require(packageFolder:WaitForChild("Addons"):WaitForChild("SaveManager"))

local Window = Library:CreateWindow({Title = "GLASSLINE", Footer = "LIQUID GLASS UI  •  v1.0.0", ToggleKeybind = Enum.KeyCode.RightControl})
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

local MainTab = Library:AddTab("Main", "house")
local PlayerTab = Library:AddTab("Player", "user")
local SettingsTab = Library:AddTab("Settings", "settings")

local MainBox = MainTab:AddGroupbox({Name = "Welcome", Side = "Left", Description = "A minimal liquid-glass UI framework."})
MainBox:AddLabel("Build your own controls with a compact, familiar API. This demo runs in Roblox Studio.", true)
MainBox:AddDivider()
MainBox:AddButton({Text = "Test notification", Func = function()
    Library:Notify({Title = "Glassline", Description = "Your UI library is running.", Time = 3})
end})
local demoToggle = MainBox:AddToggle("DemoToggle", {Text = "Example toggle", Default = false, Callback = function(value) print("Demo toggle:", value) end})

local PlayerBox = PlayerTab:AddGroupbox({Name = "Character settings", Side = "Left", Description = "Example controls for your own experience."})
PlayerBox:AddSlider("DemoNumber", {Text = "Demo value", Default = 16, Min = 0, Max = 100, Rounding = 0, Callback = function(value) print("Demo value:", value) end})
PlayerBox:AddInput("DemoText", {Text = "Text input", Default = "", Placeholder = "Type something...", Callback = function(value) print("Input:", value) end})
PlayerBox:AddDropdown("ThemeChoice", {Text = "Theme preset", Values = {"Glass", "Slate", "Mono"}, Default = "Glass", Callback = function(value)
    ThemeManager:Apply(value)
    Library:Notify({Title = "Theme selected", Description = value .. " palette stored. Recreate the window to recolor existing controls.", Time = 3})
end})

local ConfigBox = SettingsTab:AddGroupbox({Name = "Configuration", Side = "Left", Description = "Snapshots can be copied from the Output window."})
ConfigBox:AddButton({Text = "Print config JSON", Func = function()
    print(SaveManager:Encode())
    Library:Notify({Title = "Config snapshot", Description = "JSON printed in Studio Output.", Time = 3})
end})
ConfigBox:AddButton({Text = "Unload UI", Func = function() Library:Unload() end})

Library:Notify({Title = "Glassline loaded", Description = "Press Right Ctrl to hide or show the window.", Time = 4})
