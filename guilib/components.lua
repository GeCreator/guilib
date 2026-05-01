---@param element GuiLibElement
---@return GuiLibElement
local function dragable(element)
  local offset = vmath.vector3(0)
  element.on("pressed", function(action)
    local mouse_pos = vmath.vector3(action.screen_x, action.screen_y, 0)
    offset = mouse_pos - gui.get_screen_position(action.node)
  end)
  element.on("hold", function(action)
    local mouse_pos = vmath.vector3(action.screen_x, action.screen_y, 0)
    gui.set_screen_position(action.node, mouse_pos - offset)
  end)
  return element
end

return {
  dragable = dragable
}
