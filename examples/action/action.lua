local function zoom(node, scale)
  local s = gui.get_scale(node)
  s.x = s.x + s.x*scale
  s.y = s.y + s.y*scale
  gui.set_scale(node, s)
end

local function rotate(node, angle)
  local r = gui.get_euler(node)
  r.z = r.z + angle
  gui.set_euler(node, r)
end

local function move(node, step)
  local p = gui.get_position(node)
  p.y = p.y + step
  gui.set_position(node, p)
end

function wheel_action(action, factor)
  if action.pressed_action[hash("key_lctrl")] then
    move(action.node, factor * 2)
  elseif action.pressed_action[hash("key_lshift")] then
    rotate(action.node, factor * 1)
  else
    zoom(action.node, factor * 0.04)
  end
end

---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("box", {
    [hash('mouse_wheel_up')] = function(action) wheel_action(action, 1) end,
    [hash('mouse_wheel_down')] = function(action) wheel_action(action, -1) end,
  })
end
