-- ThemeManager ModuleScript
local ThemeManager = {}
ThemeManager.Presets = {
 Glass={Background=Color3.fromRGB(17,18,21),Surface=Color3.fromRGB(28,30,35),Hover=Color3.fromRGB(42,44,50),Border=Color3.fromRGB(105,110,121),Text=Color3.fromRGB(239,241,245),Muted=Color3.fromRGB(157,162,173),Accent=Color3.fromRGB(211,218,229),AccentText=Color3.fromRGB(20,21,24)},
 Mono={Background=Color3.fromRGB(12,12,12),Surface=Color3.fromRGB(25,25,25),Hover=Color3.fromRGB(39,39,39),Border=Color3.fromRGB(90,90,90),Text=Color3.fromRGB(245,245,245),Muted=Color3.fromRGB(155,155,155),Accent=Color3.fromRGB(220,220,220),AccentText=Color3.fromRGB(20,20,20)},
 Slate={Background=Color3.fromRGB(18,22,28),Surface=Color3.fromRGB(29,36,45),Hover=Color3.fromRGB(43,52,64),Border=Color3.fromRGB(110,126,144),Text=Color3.fromRGB(240,244,248),Muted=Color3.fromRGB(165,178,193),Accent=Color3.fromRGB(194,211,231),AccentText=Color3.fromRGB(23,29,36)},
}
function ThemeManager:SetLibrary(library) self.Library=library end
function ThemeManager:Apply(name)
 assert(self.Library,"Call SetLibrary first"); local preset=assert(self.Presets[name],"Unknown theme")
 for k,v in pairs(preset) do self.Library.Theme[k]=v end
 return preset
end
function ThemeManager:GetThemes() local out={}; for name in pairs(self.Presets) do table.insert(out,name) end; table.sort(out); return out end
return ThemeManager
