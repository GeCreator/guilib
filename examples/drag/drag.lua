---@param guilib GuiLib
local function create_draggable_box(guilib, name, log)
  local offset = vmath.vector3(0)
  guilib.add(name, {
    drag = function(action)
      local mouse_pos = vmath.vector3(action.screen_x, action.screen_y, 0)
      if action.drag_begin then
        log("Drag Begin")
        offset = mouse_pos - gui.get_screen_position(action.node)
      elseif action.drag_end then
        log("Drag End")
      else
        gui.set_screen_position(action.node, mouse_pos - offset)
        log("Drag")
      end
    end,
  })
end
---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  create_draggable_box(guilib, "box3", log)
  create_draggable_box(guilib, "box2", log)
  create_draggable_box(guilib, "box1", log)
end
