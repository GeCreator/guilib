---@param element GuiLibElement
---@return GuiLib
local function dragable(element)
  ---@param e input_action|GuiLib
  element.on("hold", function(e)
    local pos = gui.get_screen_position(e.node)
    pos.x = pos.x + e.screen_dx
    pos.y = pos.y + e.screen_dy
    gui.set_screen_position(e.node, pos)
  end)
  return element
end

return {
  dragable = dragable
}
