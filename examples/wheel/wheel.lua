 local function zoom(scale)
  return function(e)
    local s = gui.get_scale(e.node)
    s.x = s.x + s.x*scale
    s.y = s.y + s.y*scale
    gui.set_scale(e.node, s)
  end
end

---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("Wheel/box_wheel", {
    [hash('mouse_wheel_up')] = zoom(0.04),
    [hash('mouse_wheel_down')] = zoom(-0.04),
  })
  guilib.add("Wheel/box_wheel_A1", {
    [hash('mouse_wheel_up')] = zoom(0.04),
    [hash('mouse_wheel_down')] = zoom(-0.04),
  })
  guilib.add("Wheel/box_wheel_B1", {
    [hash('mouse_wheel_up')] = zoom(0.04),
    [hash('mouse_wheel_down')] = zoom(-0.04),
  })
end
