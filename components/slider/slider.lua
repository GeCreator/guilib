
local clamp = function(value, min, max)
  value = math.max(value, min)
  value = math.min(value, max)
  return value
end

---Return real scale(with parents nodes)
local function get_scale(node)
  local scale = gui.get_scale(node)
  local parent = gui.get_parent(node)
  if parent then
    scale = vmath.mul_per_elem(scale, get_scale(parent))
  end
  return scale
end


---@param guilib GuiLibElement
---@param namespace string
---@return guilib_slider_component
return function(guilib, namespace, min_value, max_value)
  ---@class guilib_slider_component
  local slider = {}
  guilib.set_namespace(namespace)

  local pin = guilib.add("pin")
  local pin_position = gui.get_screen_position(pin.node)
  local background = guilib.add("background")
  local size = gui.get_size(background.node)
  local pin_size = gui.get_size(pin.node)
  -----
  background.on("pressed", function(action)
    pin_position = gui.get_screen_position(pin.node)
  end)

  background.on("hold", function(e)
    local scale = 1/get_scale(e.node).x
    local screen_pos = gui.screen_to_local(e.node, vmath.vector3(e.screen_x, pin_position.y, 0))
    local left_border = -size.x/scale/2 + pin_size.x/scale/2
    local right_border = size.x/scale/2 - pin_size.x/scale/2
    screen_pos.x = clamp(screen_pos.x, left_border, right_border)
    gui.set_position(pin.node, screen_pos*scale)
  end)


  slider.on_change = function(fun)
  end
  return slider
end
