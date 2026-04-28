local function clear_table(t)
  for k, v in pairs(t) do t[k] = nil end
end

local function remove_from_list(l, value)
  for i, v in ipairs(l) do
    if value == v then
      table.remove(l, i) return
    end
  end
end

local RESERVED_ACTIONS_TOUCH = {
  pressed = true,
  released = true,
  hold = true,
  click_outside = true,
}

local RESERVED_ACTIONS_HOVER = {
  hover = true,
  enter = true,
  leave = true,
}

return function()
  local guilib = {}
  local TOUCH_ACTION = hash('touch')
  local pressed_actions = {}

  local call_event = function(element, method, action)
    if method then
      action.node = element.node
      action.element = element
      action.pressed_actions = pressed_actions
      method(action)
      return true
    end
  end

  ---@return GuiLib
  guilib.init = function()
    ---@class GuiLib
    local M = {}
    local enabled = true
    local elements = {}
    local elements_with_touch = {}
    local elements_with_hover = {}
    local elements_with_action = {}
    local overlap_enabled = true
    local focused_element = nil
    local pressed_element = nil

    local hovered_elements = {}
    local enter_elements = {}
    local leave_elements = {}
    local subprocesses = {}
    local namespace = ""

    ---@return GuiLibElement
    local function create_element(node)

      ---@class GuiLibElement
      local element = {
        ---@type hash
        id = gui.get_id(node),
        ---@type node
        node = node,
        ---@private
        __hover_element = false,
        ---@private
        __touch_element = false
      }
      ---Bind action to node
      ---@param action hash|string
      ---@param handler fun(action: table)
      element.on = function(action, handler)
        if element[action] then
            local previous_handler = element[action]
          element[action] = function(e)
            previous_handler(e)
            handler(e)
          end
        else
          element[action] = handler
        end
        if RESERVED_ACTIONS_TOUCH[action] and not element.__touch_element then
          element.__touch_element = true
          table.insert(elements_with_touch, 1, element)
        elseif RESERVED_ACTIONS_HOVER[action] and not element.__hover_element then
          element.__hover_element = true
          table.insert(elements_with_hover, 1, element)
        else
          if not elements_with_action[action] then elements_with_action[action] = {} end
          table.insert(elements_with_action[action], 1, element)
        end
      end
            return element
    end

    ---@param element GuiLibElement
    local function __remove_element(element)
      if elements[element.id] then
        remove_from_list(elements_with_touch, element)
        remove_from_list(elements_with_hover, element)
        remove_from_list(elements_with_action, element)
        remove_from_list(hovered_elements, element )
        remove_from_list(enter_elements, element )
        remove_from_list(leave_elements, element )
        elements[element.id] = nil
      end
    end

    local function __get_node(node)
      if type(node)=="string" then
        return gui.get_node(namespace..node)
      end
      return node
    end

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

    ---@param set string
    M.set_namespace = function(set)
      namespace = set
      if namespace ~= "" then
        namespace = namespace .. "/"
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
      clear_table(elements)
      clear_table(elements_with_touch)
      clear_table(elements_with_hover)
      clear_table(elements_with_action)
      clear_table(hovered_elements)
      clear_table(enter_elements)
      clear_table(leave_elements)
      clear_table(subprocesses)
      focused_element = nil
      pressed_element = nil
      namespace = ""
    end

    --- Add element actions for node.
    --- Example: self.guilib.add("box", {
    ---   pressed = function(action) print("pressed") end,
    ---   released = function(action) print("released") end,
    ---   hold =  function(action) print("hold") end,
    ---   enter = function(action) print("enter") end
    ---   leave = function(action) print("leave") end
    ---   hover = function(action) print("hover") end
    --- })
    ---@param node string|node
    ---@param actions? table table with event functions
    ---@return GuiLibElement
    M.add = function(node, actions)
      local element = create_element(__get_node(node))
      --- add actions
      if actions then
        for action, handler in pairs(actions) do
          element.on(action, handler)
        end
      end
      ---Replace already exists element
      if elements[element.id] then __remove_element(elements[element.id]) end
      elements[element.id] = element
      return element
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

      --- store active(pressed) actions in global storage
      if action.pressed then
        pressed_actions[action_id] = true
      elseif action.released then
        pressed_actions[action_id] = nil
      end

      if action_id == nil and action.x and action.y then
        for _, element in ipairs(elements_with_hover) do
          if (not catched or not overlap_enabled) and gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
            if not hovered_elements[element.id] then
              table.insert(enter_elements, element)
            end
            call_event(element, element.hover, action)
            catched = true
          else
            if hovered_elements[element.id] then
              table.insert(leave_elements, element)
            end
          end
        end

        for i, element in ipairs(leave_elements) do
          call_event(element, element.leave, action)
          hovered_elements[element.id] = nil
          leave_elements[i] = nil
        end

        for i, element in ipairs(enter_elements) do
          hovered_elements[element.id] = true
          call_event(element, element.enter, action)
          enter_elements[i] = nil
        end
      elseif action_id == TOUCH_ACTION then
        if focused_element and action.pressed and focused_element.click_outside then
          if gui.is_enabled(focused_element.node, true) and not gui.pick_node(focused_element.node, action.x, action.y) then
            call_event(focused_element, focused_element.click_outside, action)
            __blur(action)
          end
        end
        -- call released even if not pick to node
        if pressed_element then
          action.is_picked = gui.pick_node(pressed_element.node, action.x, action.y)
          if action.released then
            catched = call_event(pressed_element, pressed_element.released, action)
            pressed_element = nil
          elseif action.pressed == false then
            catched = call_event(pressed_element, pressed_element.hold, action)
          end
        end
        for _, element in ipairs(elements_with_touch) do
          if overlap_enabled and catched ~= nil then return catched end
          if gui.is_enabled(element.node, true) and gui.pick_node(element.node, action.x, action.y) then
            if action.pressed then
              catched = call_event(element, element.pressed, action)
              pressed_element = element
              __focus(element, action)
            end
          end
        end
      end

      if elements_with_action[action_id] then
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
      end
      return catched
    end

    M.focus = function(node_or_element)
      if type(node_or_element) == 'table' then
        __focus(node_or_element, {})
      else
        local element = elements[gui.get_id(__get_node(node_or_element))]
        if element then __focus(element, {}) end
      end
    end

    M.dump = function()
      pprint(elements_with_touch)
    end

    return M
  end
  return guilib.init()
end
