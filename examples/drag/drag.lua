---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, log)
  guilib.add("box_drag", {
    drag = function(action)
      if action.drag_begin then log("Drag Begin")
      elseif action.drag_end then log("Drag End")
      else log("Drag") end
    end,
  })
end
