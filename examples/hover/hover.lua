---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("box_hover_A", {
    enter = function(e) gui.play_flipbook(e.node, "button2") end,
    leave = function(e) gui.play_flipbook(e.node, "button0") end,
    hover = function() log("Hover A") end
  })
  guilib.add("box_hover_B", {
    enter = function(e) gui.play_flipbook(e.node, "button2") end,
    leave = function(e) gui.play_flipbook(e.node, "button0") end,
    hover = function() log("Hover B") end,
  })
end
