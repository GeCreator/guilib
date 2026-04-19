---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("Wheel/box_input1", {
    pressed = function() end,
    focus = function() end,
    [hash('text')] = function(e)
      local t = gui.get_text(gui.get_node("input1")) .. e.text
      gui.set_text(gui.get_node("input1"), t)
    end,
    [hash('key_backspace')] = function(e)
      if e.pressed then
        local t = gui.get_text(gui.get_node("input1"))
        gui.set_text(gui.get_node("input1"), string.sub(t, 0, string.len(t)-1))
      end
    end
  })
  guilib.add("Wheel/box_input2", {
    pressed = function() end,
    focus = function() end,
    [hash('text')] = function(e)
      local t = gui.get_text(gui.get_node("input2")) .. e.text
      gui.set_text(gui.get_node("input2"), t)
    end,
    [hash('key_backspace')] = function(e)
      if e.pressed then
        local t = gui.get_text(gui.get_node("input2"))
        gui.set_text(gui.get_node("input2"), string.sub(t, 0, string.len(t)-1))
      end
    end
  })

end
