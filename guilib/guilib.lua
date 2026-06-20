local TOUCH_ACTION = hash('touch')
local pressed_action = {}

local call_event = function(element, method, action)
  if method then
    action.node = element.node
    action.pressed_action = pressed_action
    local result = method(action)
    if result ~= nil then
      return result
    end
    return true
  end
end

local function __get_node(node)
  if type(node) == "string" then
    return gui.get_node(node)
  end
  return node
end

local function create_element(p_node)
  local is_hovered = false
  local is_pressed = false

  ---@class GuiLibElement
  local element = {
    ---@type node
    node = p_node,
    actions = {},
  }

  ---Bind action to node
  ---@param action hash|string
  ---@param handler fun(action: table)
  element.on = function(action, handler)
    element.actions[action] = handler
  end

  element.on_input = function(action_id, action, catched)
    if not gui.is_enabled(element.node, true) then return end

    if action_id == nil and action.x and action.y then
      local do_enter = false
      local do_leave = false
      if gui.pick_node(element.node, action.x, action.y) then
        if not is_hovered then do_enter = true end
        catched = call_event(element, element.actions.hover, action)
      else
        if is_hovered then do_leave = true end
      end

      if do_leave then
        call_event(element, element.actions.leave, action)
        is_hovered = false
      end

      if do_enter then
        is_hovered = true
        call_event(element, element.actions.enter, action)
      end
    elseif action_id == TOUCH_ACTION then
      if is_pressed then
        action.is_picked = gui.pick_node(element.node, action.x, action.y)
        if action.released then
          is_pressed = false
          call_event(element, element.actions.released, action)
        elseif action.pressed == false then
          call_event(element, element.actions.hold, action)
        end
      end
      if gui.pick_node(element.node, action.x, action.y) then
        if action.pressed then
          is_pressed = true
          catched = call_event(element, element.actions.pressed, action)
        end
      else
        if action.pressed then
          call_event(element, element.actions.click_outside, action)
        end
      end
    end
    if element.actions[action_id] then
      if action.x and action.y then
        if element.node and gui.pick_node(element.node, action.x, action.y) then
          catched = call_event(element, element.actions[action_id], action)
        end
      else
        catched = call_event(element, element.actions[action_id], action)
      end
    end
    return catched
  end

  return element
end
---@return GuiLib
return function()
  ---@class GuiLib
  local guilib = {}
  local elements = {}
  local registered_elements = {}

  guilib.on = function(id, event, handler)
    local node = __get_node(id)
    local node_id = gui.get_id(node)
    if not registered_elements[node_id] then
      registered_elements[node_id] = create_element(node)
      table.insert(elements, 1, registered_elements[node_id])
    end
    local element = registered_elements[node_id]
    element.on(event, handler)
  end

  guilib.on_input = function(action_id, action)
    --- store active(pressed) actions in global storage
    if action.pressed then
      pressed_action[action_id] = true
    elseif action.released then
      pressed_action[action_id] = nil
    end
    local catched = nil
    for _, el in ipairs(elements) do
      catched = catched or el.on_input(action_id, action, catched)
    end
    return catched
  end

  guilib.dump = function()
    local result = "guilib.dump():\n"
    for _, el in ipairs(elements) do
      result = result .. gui.get_id(el.node) .. ":\n"
      for k, v in pairs(el.actions) do
        result = result .. "\t -> " .. k .. "\n"
      end
    end
    pprint(result)
  end

  return guilib
end
