---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  -----------------------------------------------
  local el = guilib.add("box1", {
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

  local box2 = guilib.add("box2")
  box2.on(hash("touch"), function(e)
    if e.pressed then
      gui.play_flipbook(e.node, "button1")
      log("Pressed")
    elseif e.released then
      gui.play_flipbook(e.node, "button0")
      log("Released")
    else log("Hold") end
  end)
  ---------------------------------------------
  guilib.add("box_touch_A", { pressed = function() log("A Clicked") end, })
  guilib.add("box_touch_B", { pressed = function() log("B Clicked") end, })
  ---------------------------------------------
end
