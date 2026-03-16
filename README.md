# GuiLib

Simple lib for Defold that add some behaviour to gui elements.

The library will help you quickly add various events to gui elements.
Supported events: touch/release/hold/drag/enter/leave/hover

## Example of using the touch event
```lua
-- file: my_gui.gui_script

local guilib = require("guilib")

function init(self)
  self.guilib = guilib.create()
  self.guilib.add("box", {
    touch = function() print("touch: box") end
  })
end

function on_input(self, action_id, action)
  self.guilib.on_input(action_id, action)
end
```

Examples:
- [x] button
- [ ] slider
- [ ] input
- [x] drag
- [ ] panel
