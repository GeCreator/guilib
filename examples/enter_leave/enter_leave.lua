---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("box_A", {
    enter = function() log("Enter A") end,
    leave = function() log("Leave A") end,
  })
  guilib.add("box_B", {
    enter = function() log("Enter B") end,
    leave = function() log("Leave B") end,
  })
end
