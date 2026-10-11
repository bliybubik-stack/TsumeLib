-- SaveManager: JSON snapshots; no arbitrary local file access.
local HttpService = game:GetService("HttpService")
local SaveManager = {}
function SaveManager:SetLibrary(library) self.Library = library end
function SaveManager:CreateSnapshot()
    assert(self.Library, "Call SetLibrary(library) first")
    local data = {Toggles = {}, Options = {}}
    for id, control in pairs(self.Library.Toggles) do data.Toggles[id] = control.Value end
    for id, control in pairs(self.Library.Options) do
        local value = control.Value
        if typeof(value) == "Color3" then
            data.Options[id] = {__type = "Color3", r = value.R, g = value.G, b = value.B}
        elseif type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
            data.Options[id] = value
        end
    end
    return data
end
function SaveManager:Encode()
    return HttpService:JSONEncode(self:CreateSnapshot())
end
function SaveManager:ApplySnapshot(data)
    assert(self.Library, "Call SetLibrary(library) first")
    for id, value in pairs(data.Toggles or {}) do
        local control = self.Library.Toggles[id]
        if control then control:SetValue(value) end
    end
    for id, value in pairs(data.Options or {}) do
        local control = self.Library.Options[id]
        if control then
            if type(value) == "table" and value.__type == "Color3" then
                control:SetValue(Color3.new(value.r, value.g, value.b))
            else
                control:SetValue(value)
            end
        end
    end
end
function SaveManager:Decode(json)
    local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or type(data) ~= "table" then return false, "Invalid config JSON" end
    self:ApplySnapshot(data)
    return true
end
return SaveManager
