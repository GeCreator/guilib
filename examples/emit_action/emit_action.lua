
---@param guilib GuiLib
local function create_box(guilib, name)
  local el = guilib.add(name)
  el.on(hash('my_action'), function(action) gui.set_color(el.node, vmath.vector4(math.random(),math.random(),math.random(), 1)) end)
  return el
end

---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  local b = create_box(guilib, "box")
  b = create_box(b, "box1")
  create_box(b, "box2")

  guilib.on(hash("key_space"), function(e)
    if e.released then
      guilib.emit_action(hash("my_action"))
    end
  end)
end
