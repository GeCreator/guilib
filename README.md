# GuiLib

Simple lib for Defold that add some behaviour to gui elements.

The library will help you quickly add various events to gui elements.
Supported events: pressed/hold/released/enter/leave/hover/click_outside/hash('action_id')

## Example of using the touch event
```lua
-- file: my_gui.gui_script

local guilib = require("guilib.guilib")

function init(self)
  self.guilib = guilib.create()
  self.guilib.on("box", hash('touch'), function() print("touch: box") end)
  self.guilib.on("box", 'enter', function() print("mouse entered") end)
end

function on_input(self, action_id, action)
  self.guilib.on_input(action_id, action)
end
```
