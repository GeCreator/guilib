---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("Enter/Leave/box_enter_leave_A", {
    enter = function() log("Enter A") end,
    leave = function() log("Leave A") end,
  })
  guilib.add("Enter/Leave/box_enter_leave_B", {
    enter = function() log("Enter B") end,
    leave = function() log("Leave B") end,
  })
end
