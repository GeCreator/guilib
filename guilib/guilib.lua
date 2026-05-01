 local TOUCH_ACTION = hash('touch')
local pressed_action = {}

local function set_element_first(list, element)
  local pos = 0
  for i, el in ipairs(list) do
    if el == element then
      pos = i
      break
    end
  end
  if pos > 1 then
    table.remove(list, pos)
    table.insert(list, 1, element)
  end
end

local function clear_table(t)
  for k, v in pairs(t) do t[k] = nil end
end

local function remove_from_list(l, value)
  for i, v in ipairs(l) do
    if value == v then
      table.remove(l, i)
      return
    end
  end
end

local call_event = function(element, method, action)
  if method then
    action.node = element.node
    action.element = element
    action.pressed_action = pressed_action
    local result = method(action)
    if result ~= nil then
      return result
    end
    return true
  end
end

return function()
  local catched = nil

  local function create_element(p_node, p_base_namespace)
    local children = {}
    local is_hovered = false
    local is_focused = false
    local is_pressed = false
    local namespace = p_base_namespace
    local enabled = true

    local function __get_node(node)
      if type(node) == "string" then
        return gui.get_node(namespace .. node)
      end
      return node
    end

    if p_node then
      p_node = __get_node(p_node)
    end
    ---@class GuiLibElement
    local element = {
      ---@type node
      node = p_node,
    }
    element.set_namespace = function(set)
      namespace = p_base_namespace .. set
      if not string.match(namespace, "(/)$") then
        namespace = namespace .. "/"
      end
    end

    element.set_enabled = function(set)
      enabled = set
      if p_node then gui.set_enabled(p_node, enabled) end
    end
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
      return element
    end

    element.add = function(node, actions)
      local child = create_element(node, namespace)
      table.insert(children, 1, child)
      if actions then
        for action_id, action in pairs(actions) do
          child.on(action_id, action)
        end
      end
      return child
    end

    element.clear = function()
      namespace = ""
      is_hovered = false
      is_pressed = false
      clear_table(children)
    end

    element.dump = function()
      pprint(children)
    end

    element.on_input = function(action_id, action)
      if not enabled then return end
      if p_node and not gui.is_enabled(element.node, true) then return end

      for _, el in ipairs(children) do
        catched = el.on_input(action_id, action)
      end

      if p_node == nil then return end

      if action_id == nil and action.x and action.y then

        local do_enter = false
        local do_leave = false
        if not catched and gui.pick_node(element.node, action.x, action.y) then
          if not is_hovered then do_enter = true end
          catched = call_event(element, element.hover, action)
        else
          if is_hovered then do_leave = true end
        end

        if do_leave then
          call_event(element, element.leave, action)
          is_hovered = false
        end

        if do_enter then
          is_hovered = true
          call_event(element, element.enter, action)
        end
      elseif action_id == TOUCH_ACTION then
        if is_pressed then
          action.is_picked = gui.pick_node(element.node, action.x, action.y)
          if action.released then
            is_pressed = false
            catched = call_event(element, element.released, action)
          elseif action.pressed == false then
            catched = call_event(element, element.hold, action)
          end
        end
        if not catched and gui.pick_node(element.node, action.x, action.y) then
          if action.pressed then
            is_pressed = true
            is_focused = true
            catched = call_event(element, element.pressed, action)
          end
        else
           if action.pressed then
            call_event(element, element.click_outside, action)
           end
        end
      end
      if element[action_id] then
        if action.x and action.y then
          if gui.pick_node(element.node, action.x, action.y) then
            catched = call_event(element, element[action_id], action)
          end
        else
          call_event(element, element[action_id], action)
        end
      end
      return catched
    end
    return element
  end

  local root_element = create_element(nil, "")
  local g = {}
  g.on_input = function(action_id, action)
    --- store active(pressed) actions in global storage
    if action.pressed then
      pressed_action[action_id] = true
    elseif action.released then
      pressed_action[action_id] = nil
    end
    catched = nil
    root_element.on_input(action_id, action)
  end
  g.add = root_element.add
  return g
end
