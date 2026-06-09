local components = require("guilib.components")
---@param guilib GuiLib
local function create_box(guilib, log)
  guilib.on("pressed",  function() log("Drag Begin") end)
  guilib.on("hold",  function() log("Drag") end)
  guilib.on("released",  function() log("Drag End") end)
  return guilib
end
---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  components.dragable(create_box(guilib.add("box1"), log))
  components.dragable(create_box(guilib.add("box2"), log))
  components.dragable(create_box(guilib.add("box3"), log))
end
