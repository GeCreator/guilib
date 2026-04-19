---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  -----------------------------------------------
  guilib.add("Touch/box_touch", {
    pressed = function(e)
      gui.play_flipbook(e.node, "button1")
      log("Pressed")
    end,
    released = function(e)
      gui.play_flipbook(e.node, "button0")
      log("Released")
    end,
    hold = function() log("Hold") end,
  })
  -----------------------------------------------
  guilib.add("Touch/box_touch_A", { pressed = function() log("A Clicked") end, })
  guilib.add("Touch/box_touch_B", { pressed = function() log("B Clicked") end, })
  -----------------------------------------------
end
