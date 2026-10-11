-- Optional helpers for your own Roblox experience.
local Controls = {}

function Controls.BindWalkSpeed(toggle, player, enabledSpeed)
    enabledSpeed = enabledSpeed or 24
    local originalSpeed
    local function apply(enabled)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        if enabled then
            originalSpeed = originalSpeed or humanoid.WalkSpeed
            humanoid.WalkSpeed = enabledSpeed
        elseif originalSpeed then
            humanoid.WalkSpeed = originalSpeed
            originalSpeed = nil
        end
    end
    toggle:OnChanged(apply)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if toggle.Value then apply(true) end
    end)
    apply(toggle.Value)
end

function Controls.BindPrint(toggle, label)
    toggle:OnChanged(function(value)
        print((label or "Setting") .. " = " .. tostring(value))
    end)
end

return Controls
