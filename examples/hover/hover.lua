---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, template, log)
  local boxa = guilib.add(template .. "/box_hover_A")
  boxa.on("enter", function(e) gui.play_flipbook(e.node, "button2") end)
  boxa.on("leave", function(e) gui.play_flipbook(e.node, "button0") end)
  boxa.on("hover", function() log("Hover A") end)

  local boxb = guilib.add(template .. "/box_hover_B")
  boxb.on("enter", function(e) gui.play_flipbook(e.node, "button2") end)
  boxb.on("leave", function(e) gui.play_flipbook(e.node, "button0") end)
  boxb.on("hover", function() log("Hover B") end)
  pprint("?")
end
