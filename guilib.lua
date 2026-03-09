local guilib = {}
local TOUCH_ACTION = hash('touch')

local call_event = function(element, method, action)
  if method then
    action.node = element.node
    local result = method(action, element)
    if result==nil then return true else return result end
  end
end

---@return GuiLib
guilib.create = function()
  msg.post(".", "acquire_input_focus")
  ---@class GuiLib
  local M = {}
  local dragged_node = nil
  local elements_with_touch = {}
  local elements_with_hover = {}
  local hovered_elements = {}
  local overlap_enabled = true

  M.set_overlap = function(enabled)
    overlap_enabled = enabled
  end

  --- Add element actions for node.
  --- Example: guilib.add("box", {
  ---   touch = function(action) print("touch") end,
  ---   release = function(action) print("release") end,
  ---   drag = function(action) print("drag") end,
  ---   enter = function(action) print("enter") end
  ---   leave = function(action) print("leave") end
  ---   hover = function(action) print("hover") end
  --- })
  ---@param name string
  ---@param element table table with event functions
  M.add = function(name, element)
    element.node = gui.get_node(name)
    if element.touch or element.release or element.drag then table.insert(elements_with_touch, 1, element) end
    if element.hover or element.enter or element.leave then table.insert(elements_with_hover, 1, element) end
    return element
  end

  --- Process the input request. This feature is required, nothing will work without it.
  --- ``` lua
  --- function on_input(self, action_id, action)
  ---   self.guilib.on_input(action_id, action)
  --- end
  --- ```
  M.on_input = function(action_id, action)
    local catched = nil
    if action_id == TOUCH_ACTION then
      if dragged_node and action.released then
        call_event(dragged_node, dragged_node.release, action)
        dragged_node = nil
      end
      for _, element in ipairs(elements_with_touch) do
        if overlap_enabled and catched~=nil then return catched end
        if gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
          if action.pressed then
            catched = call_event(element, element.touch, action)
          elseif action.released then
            catched = call_event(element, element.release, action)
            dragged_node = nil
          elseif not dragged_node and element.drag then
            dragged_node = element
          end
        end
      end
    elseif action_id == nil then
      if dragged_node then
        call_event(dragged_node, dragged_node.drag, action)
      end
      for _, element in ipairs(elements_with_hover) do
        if overlap_enabled and catched~=nil then return catched end
        if gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
          if not hovered_elements[element.node] then
            hovered_elements[element.node] = true
            call_event(element, element.enter, action)
          end
          call_event(element, element.hover, action)
          catched = true
        else
          if hovered_elements[element.node] then
            hovered_elements[element.node] = nil
            call_event(element, element.leave, action)
          end
        end
      end
    end
    return catched
  end
  return M
end


return guilib
