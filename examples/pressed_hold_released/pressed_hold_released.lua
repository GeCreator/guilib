---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, template, log)
  -----------------------------------------------
  local box1 = guilib.add(template .. "/box1")
  box1.on("pressed", function(e)
    gui.play_flipbook(e.node, "button1")
    log("Pressed")
  end)
  box1.on("released", function(e)
    gui.play_flipbook(e.node, "button0")
    log("Released")
  end)

  box1.on("hold", function() log("Hold") end)

  local box2 = guilib.add(template .. "/box2")
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
  guilib.add(template .. "/box_touch_A").on("pressed", function() log("A Clicked") end )
  guilib.add(template .. "/box_touch_B").on("pressed", function() log("B Clicked") end )
  ---------------------------------------------
end
