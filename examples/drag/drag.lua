local components = require("guilib.components")
---@param guilib GuiLib
local function create_box(element, log)
  element.on("pressed",  function() log("Drag Begin") end)
  element.on("hold",  function() log("Drag") end)
  element.on("released",  function() log("Drag End") end)
  return element
end
---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  components.draggable(create_box(guilib.add("box1"), log))
  components.draggable(create_box(guilib.add("box2"), log))
  components.draggable(create_box(guilib.add("box3"), log))
end
