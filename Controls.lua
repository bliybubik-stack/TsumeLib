-- Optional control helpers for your own Roblox experience.
local Controls = {}
function Controls.BindWalkSpeed(toggle, player, speed)
 speed = speed or 24
 local original
 local function apply(enabled)
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid then return end
  if enabled then original = original or humanoid.WalkSpeed; humanoid.WalkSpeed = speed
  elseif original then humanoid.WalkSpeed = original; original = nil end
 end
 toggle:OnChanged(apply)
 player.CharacterAdded:Connect(function() task.wait(.4); if toggle.Value then apply(true) end end)
 apply(toggle.Value)
end
function Controls.BindPrint(toggle, name)
 toggle:OnChanged(function(value) print((name or "Toggle") .. " changed to " .. tostring(value)) end)
end
return Controls
