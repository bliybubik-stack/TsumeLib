# Glassline UI Library

Original Roblox Studio-compatible UI framework with a compact, dark liquid-glass aesthetic and an Obsidian/Linoria-inspired API. Use it in experiences you own.

## Five Lua scripts
1. `Library.lua` — windows, tabs, groupboxes, toggles, buttons, sliders, text inputs, dropdowns, notifications, dragging, and Right Ctrl visibility toggle.
2. `Controls.lua` — optional helpers for controls in your own game.
3. `ThemeManager.lua` — Glass, Mono, and Slate palettes.
4. `SaveManager.lua` — JSON configuration snapshots and loading from a JSON string.
5. `Example.client.lua` — demo interface.

## Install in Studio
Create this structure:

```text
ReplicatedStorage
└── Glassline (Folder)
    ├── Library (ModuleScript)       <- Library.lua
    ├── Controls (ModuleScript)      <- Controls.lua
    ├── ThemeManager (ModuleScript)  <- ThemeManager.lua
    └── SaveManager (ModuleScript)   <- SaveManager.lua
StarterPlayer
└── StarterPlayerScripts
    └── Example (LocalScript)        <- Example.client.lua
```

Run the game. Press Right Ctrl to hide or show the menu.

## GitHub hosting
Create a public repository and upload these files. GitHub Pages is not required for source hosting. In normal Roblox games, use `require()` with ModuleScripts; a raw GitHub URL is not a drop-in replacement for an in-game ModuleScript. Roblox's `HttpService` requests are not available from LocalScripts, and downloading arbitrary source to execute is not the recommended in-game pattern.

## Notes
- This starter uses translucent UI surfaces, subtle borders, and tween animations. Standard Roblox GUI does not support arbitrary backdrop blur on ScreenGui panels.
- Theme changes update the palette for newly created controls; this starter does not recolor every existing UI object live.
- SaveManager makes JSON snapshots, but does not write files to the user's computer. Use a server-side DataStore with validation if your own experience needs persistent settings.
