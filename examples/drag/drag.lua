---@param guilib GuiLib
local function create_draggable_box(guilib, name, log)
  local offset = vmath.vector3(0)
  guilib.add(name, {
    pressed = function(action)
      log("Drag Begin")
      local mouse_pos = vmath.vector3(action.screen_x, action.screen_y, 0)
      offset = mouse_pos - gui.get_screen_position(action.node)
    end,
    hold = function(action)
      log("Drag")
      local mouse_pos = vmath.vector3(action.screen_x, action.screen_y, 0)
      gui.set_screen_position(action.node, mouse_pos - offset)
    end,
    released = function(action)
      log("Drag End")
    end
    })
end
---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  create_draggable_box(guilib, "box1", log)
  create_draggable_box(guilib, "box2", log)
  create_draggable_box(guilib, "box3", log)
end
