return function()
  local guilib = {}
  local TOUCH_ACTION = hash('touch')
  local pressed_actions = {}
  local dragged_node = nil

  local call_event = function(element, method, action)
    if method then
      action.node = element.node
      action.element = element
      action.active_actions = pressed_actions
      method(action)
      return true
    end
  end

  ---@return GuiLib
  guilib.init = function()
    ---@class GuiLib
    local M = {}
    local enabled = true
    local elements_with_touch = {}
    local elements_with_hover = {}
    local elements_with_action = {}
    local overlap_enabled = true
    local focused_element = nil

    local hovered_elements = {}
    local enter_elements = {}
    local leave_elements = {}
    local subprocesses = {}
    local namespace = ""

    local function __blur(action)
      if focused_element then
        call_event(focused_element, focused_element.blur, action)
        focused_element = nil
      end
    end

    local function __focus(element, action)
      --- focus method required
      if not element.focus then return end
      --- skip if already focused
      if focused_element == element then return end
      if focused_element then
        __blur(action)
      end
      focused_element = element
      call_event(focused_element, focused_element.focus, action)
    end

    M.set_namespace = function(set)
      if namespace then
        namespace = set .. "/"
      else
        namespace = ""
      end
    end

    --- Enable/Disable guilib
    ---@param set boolean
    M.set_enabled = function(set)
      enabled = set
    end

    --- Enable/Disable overlap_enabled(true by default)
    ---@param set boolean
    M.set_overlap = function(set)
      overlap_enabled = set
    end

    --- Add instance of guilib as subprocess.
    --- Usable for popup/hidden elements, when required enable/disable guilib for hidden stuff
    M.create_subprocess = function()
      local sub = guilib.init()
      table.insert(subprocesses, 1, sub)
      return sub
    end

    --- Clear GuiLib state
    --- remove all actions and subprocesses
    M.clear = function()
      elements_with_touch = {}
      elements_with_hover = {}
      elements_with_action = {}
      focused_element = nil
      pressed_actions = {}
      hovered_elements = {}
      enter_elements = {}
      leave_elements = {}
      subprocesses = {}
      namespace = ""
    end

    --- Add element actions for node.
    --- Example: self.guilib.add("box", {
    ---   pressed = function(action) print("pressed") end,
    ---   released = function(action) print("released") end,
    ---   hold =  function(action) print("hold") end,
    ---   drag =  function(action) print("drag") end,
    ---   enter = function(action) print("enter") end
    ---   leave = function(action) print("leave") end
    ---   hover = function(action) print("hover") end
    --- })
    ---@generic T
    ---@param name_or_node string|node
    ---@param actions T|table table with event functions
    ---@return T
    M.add = function(name_or_node, actions)
      if type(name_or_node) == "string" then
        actions.node = gui.get_node(namespace .. name_or_node)
      else
        actions.node = name_or_node
      end
      if actions.pressed or actions.released or actions.drag or actions.hold or actions.click_outside then
        table.insert(elements_with_touch, 1,
          actions)
      end
      if actions.hover or actions.enter or actions.leave then table.insert(elements_with_hover, 1, actions) end
      for action_hash, _ in pairs(actions) do
        if type(action_hash) == "userdata" then
          if not elements_with_action[action_hash] then elements_with_action[action_hash] = {} end
          table.insert(elements_with_action[action_hash], 1, actions)
        end
      end
      return actions
    end

    --- Process the input request. This feature is required, nothing will work without it.
    --- Example:
    --- function on_input(self, action_id, action)
    ---   self.guilib.on_input(action_id, action)
    --- end
    ---@return boolean|nil is_catched return true if some registerd event will be called
    M.on_input = function(action_id, action)
      if not enabled then return end
      local catched = nil

      for _, process in ipairs(subprocesses) do
        catched = process.on_input(action_id, action)
        if not catched == nil then return catched end
      end

      if action_id == nil then
        if dragged_node then
          call_event(dragged_node, dragged_node.drag, action)
        end

        for _, element in ipairs(elements_with_hover) do
          if (not catched or not overlap_enabled) and gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
            if not hovered_elements[element.node] then
              table.insert(enter_elements, element)
            end
            call_event(element, element.hover, action)
            catched = true
          else
            if hovered_elements[element.node] then
              table.insert(leave_elements, element)
            end
          end
        end

        for i, element in ipairs(leave_elements) do
          call_event(element, element.leave, action)
          hovered_elements[element.node] = nil
          leave_elements[i] = nil
        end

        for i, element in ipairs(enter_elements) do
          hovered_elements[element.node] = true
          call_event(element, element.enter, action)
          enter_elements[i] = nil
        end
      elseif action_id == TOUCH_ACTION then
        if dragged_node and action.released then
          action.drag_end = true
          call_event(dragged_node, dragged_node.drag, action)
          dragged_node = nil
        end
        if focused_element and action.pressed and focused_element.click_outside then
          if gui.is_enabled(focused_element.node, true) and not gui.pick_node(focused_element.node, action.x, action.y) then
            call_event(focused_element, focused_element.click_outside, action)
            __blur(action)
          end
        end
        for _, element in ipairs(elements_with_touch) do
          if overlap_enabled and catched ~= nil then return catched end
          if gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
            if action.pressed then
              catched = call_event(element, element.pressed, action)
              __focus(element, action)
              if element.drag then
                action.drag_begin = true
                dragged_node = element
                call_event(dragged_node, dragged_node.drag, action)
              end
            elseif action.released then
              catched = call_event(element, element.released, action)
              dragged_node = nil
            else
              catched = call_event(element, element.hold, action)
            end
          end
        end
      elseif elements_with_action[action_id] then
        if action.x and action.y then
          for _, element in pairs(elements_with_action[action_id]) do
            if overlap_enabled and catched ~= nil then return catched end
            if gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
              catched = call_event(element, element[action_id], action)
            end
          end
        else
          if focused_element then
            catched = call_event(focused_element, focused_element[action_id], action)
          end
        end
      else
        --- store active(pressed) actions in global storage
        if action.pressed then
          pressed_actions[action_id] = true
        elseif action.released then
          pressed_actions[action_id] = nil
        end
      end
      return catched
    end
    return M
  end
  return guilib.init()
end
