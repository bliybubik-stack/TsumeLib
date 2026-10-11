-- ThemeManager ModuleScript
local ThemeManager = {}
ThemeManager.Presets = {
    Glass = {Background=Color3.fromRGB(17,18,21), Surface=Color3.fromRGB(27,29,34), Hover=Color3.fromRGB(39,42,48), Border=Color3.fromRGB(105,110,122), Text=Color3.fromRGB(240,242,246), Muted=Color3.fromRGB(157,162,173), Accent=Color3.fromRGB(218,224,235), AccentText=Color3.fromRGB(20,22,26)},
    Slate = {Background=Color3.fromRGB(18,22,28), Surface=Color3.fromRGB(29,35,43), Hover=Color3.fromRGB(42,50,61), Border=Color3.fromRGB(108,124,142), Text=Color3.fromRGB(240,244,248), Muted=Color3.fromRGB(164,178,193), Accent=Color3.fromRGB(196,214,233), AccentText=Color3.fromRGB(22,27,33)},
    Mono = {Background=Color3.fromRGB(12,12,12), Surface=Color3.fromRGB(24,24,24), Hover=Color3.fromRGB(39,39,39), Border=Color3.fromRGB(91,91,91), Text=Color3.fromRGB(245,245,245), Muted=Color3.fromRGB(158,158,158), Accent=Color3.fromRGB(222,222,222), AccentText=Color3.fromRGB(20,20,20)},
}
function ThemeManager:SetLibrary(library) self.Library = library end
function ThemeManager:GetThemes()
    local names = {}
    for name in pairs(self.Presets) do table.insert(names, name) end
    table.sort(names)
    return names
end
function ThemeManager:Apply(name)
    assert(self.Library, "Call SetLibrary(library) first")
    local preset = assert(self.Presets[name], "Unknown theme: " .. tostring(name))
    for key, value in pairs(preset) do self.Library.Theme[key] = value end
    -- For this starter release, recreate the window after applying to recolor existing elements.
    return preset
end
return ThemeManager
