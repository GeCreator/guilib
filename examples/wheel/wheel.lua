local FACTOR = 0.04
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
return function(guilib, _)
  guilib.add("wheel1", {
    [hash('mouse_wheel_up')] = zoom(FACTOR),
    [hash('mouse_wheel_down')] = zoom(-FACTOR),
  })
  guilib.add("wheel2", {
    [hash('mouse_wheel_up')] = zoom(FACTOR),
    [hash('mouse_wheel_down')] = zoom(-FACTOR),
  })
  guilib.add("wheel3", {
    [hash('mouse_wheel_up')] = zoom(FACTOR),
    [hash('mouse_wheel_down')] = zoom(-FACTOR),
  })
end
