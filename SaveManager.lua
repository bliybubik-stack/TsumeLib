-- SaveManager: JSON snapshots. Does not write files to a player's device.
local HttpService = game:GetService("HttpService")
local SaveManager = {}
function SaveManager:SetLibrary(library) self.Library=library end
function SaveManager:CreateSnapshot()
 assert(self.Library,"Call SetLibrary first")
 local data={Toggles={},Options={}}
 for id,obj in pairs(self.Library.Toggles) do data.Toggles[id]=obj.Value end
 for id,obj in pairs(self.Library.Options) do
  local v=obj.Value
  if typeof(v)=="Color3" then data.Options[id]={__type="Color3",r=v.R,g=v.G,b=v.B}
  elseif type(v)=="string" or type(v)=="number" or type(v)=="boolean" then data.Options[id]=v end
 end
 return data
end
function SaveManager:Encode() return HttpService:JSONEncode(self:CreateSnapshot()) end
function SaveManager:ApplySnapshot(data)
 assert(self.Library,"Call SetLibrary first")
 for id,v in pairs(data.Toggles or {}) do local o=self.Library.Toggles[id]; if o then o:SetValue(v) end end
 for id,v in pairs(data.Options or {}) do local o=self.Library.Options[id]; if o then if type(v)=="table" and v.__type=="Color3" then o:SetValue(Color3.new(v.r,v.g,v.b)) else o:SetValue(v) end end end
end
function SaveManager:Decode(json)
 local ok,data=pcall(function() return HttpService:JSONDecode(json) end)
 if not ok or type(data)~="table" then return false,"Invalid config JSON" end
 self:ApplySnapshot(data); return true
end
return SaveManager
