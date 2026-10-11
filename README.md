# Glassline UI Library

An original Roblox Studio UI framework with an Obsidian/Linoria-inspired API and a dark, liquid-glass look. Intended for experiences you develop; it does not use executor APIs or load remote Lua code.

## Five Lua scripts
1. `Library.lua` — window, tabs, groupboxes, toggles, checkboxes, buttons, labels, sliders, text inputs, dropdowns, notifications.
2. `Controls.lua` — optional helpers for wiring controls to game logic.
3. `Addons/ThemeManager.lua` — Glass, Slate, and Mono theme palettes.
4. `Addons/SaveManager.lua` — encode/decode runtime configuration snapshots as JSON.
5. `Example.client.lua` — demonstration LocalScript.

## Install in Roblox Studio
Create this hierarchy:

```text
ReplicatedStorage
└── Glassline (Folder)
    ├── Library (ModuleScript)          <- Library.lua
    ├── Controls (ModuleScript)         <- Controls.lua
    └── Addons (Folder)
        ├── ThemeManager (ModuleScript) <- Addons/ThemeManager.lua
        └── SaveManager (ModuleScript)  <- Addons/SaveManager.lua

StarterPlayer
└── StarterPlayerScripts
    └── Example (LocalScript)           <- Example.client.lua
```

Copy each file's contents into its matching script. Play-test, then press **Right Ctrl** to hide/show the window.

## GitHub hosting
Create a public GitHub repository and upload the five scripts plus this README. Roblox Studio projects should use `require()` with ModuleScripts. A public GitHub raw URL is useful for sharing source code, but ordinary Roblox game scripts should not use executor-style `loadstring(game:HttpGet(...))` loaders.

## Notes
- The GUI uses translucent surfaces, fine outlines, and tweens. Roblox's regular GUI objects do not offer arbitrary backdrop blur, so the glass effect is simulated through layered transparency and contrast.
- SaveManager prints/reads JSON snapshots but does not write files to the player's device. For cross-session settings, implement a server-side DataStore and validate data on the server.
- ThemeManager updates the palette for newly created controls; existing controls in this starter version are not recolored live.
