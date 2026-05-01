local components = require("guilib.components")
---@param element GuiLibElement
local function create_box(element, log)
  element.on("pressed",  function() log("Drag Begin") end)
  element.on("hold",  function() log("Drag") end)
  element.on("released",  function() log("Drag End") end)
  return element
end
---@param element GuiLibElement
---@param log fun(text: string)
return function(element, log)
  components.dragable(create_box(element.add("box1"), log))
  components.dragable(create_box(element.add("box2"), log))
  components.dragable(create_box(element.add("box3"), log))
end
