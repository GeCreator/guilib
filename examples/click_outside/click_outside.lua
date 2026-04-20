---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  -----------------------------------------------
  guilib.add("A", {
    focus = function()  end,
    click_outside = function() log("Click outside A") end
  })
  guilib.add("B", {
    focus = function()  end,
    click_outside = function() log("Click outside B") end
  })
end
