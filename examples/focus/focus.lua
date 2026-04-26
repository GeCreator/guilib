---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("box_focus_A", {
    pressed = function() log("Click A") end,
    focus = function(e) log("Focus A") gui.play_flipbook(e.node, "button2") end,
    blur = function(e) log("Blur A") gui.play_flipbook(e.node, "button0") end
  })
  local b = guilib.add("box_focus_B", {
    pressed = function() log("Click B") end,
    focus = function(e) log("Focus B") gui.play_flipbook(e.node, "button2") end,
    blur = function(e) log("Blur B") gui.play_flipbook(e.node, "button0") end
  })
  local c = guilib.add("box_focus_C", {
    pressed = function() log("Click C") end,
    focus = function(e) log("Focus C") gui.play_flipbook(e.node, "button2") end,
    blur = function(e) log("Blur C") gui.play_flipbook(e.node, "button0") end
  })

  -- focus via node name
  guilib.add("set_focus_A", { pressed = function() guilib.focus("box_focus_A") end } )
  -- focus via node
  guilib.add("set_focus_B", { pressed = function() guilib.focus(b.node) end } )
  -- focus via element
  guilib.add("set_focus_C", { pressed = function() guilib.focus(c) end } )
end
