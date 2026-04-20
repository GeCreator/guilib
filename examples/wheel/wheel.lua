local function zoom(scale)
  return function(e)
    local s = gui.get_scale(e.node)
    s.x = s.x + s.x*scale
    s.y = s.y + s.y*scale
    gui.set_scale(e.node, s)
  end
end

local function rotate(angle)
  return function(e)
    local r = gui.get_euler(e.node)
    r.z = r.z + angle
    gui.set_euler(e.node, r)
  end
end


local function move(step)
  return function(e)
    local p = gui.get_position(e.node)
    p.y = p.y + step
    gui.set_position(e.node, p)
  end
end


---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, _)
  guilib.add("wheel1", {
    [hash('mouse_wheel_up')] = zoom(0.04),
    [hash('mouse_wheel_down')] = zoom(-0.04),
  })
  guilib.add("wheel2", {
    [hash('mouse_wheel_up')] = rotate(3),
    [hash('mouse_wheel_down')] = rotate(-3),
  })
  guilib.add("wheel3", {
    [hash('mouse_wheel_up')] = move(1),
    [hash('mouse_wheel_down')] = move(-1),
  })
  -- guilib.add("wheel3", t)
end
