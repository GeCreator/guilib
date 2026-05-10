local TOUCH_ACTION = hash('touch')
local pressed_action = {}

local function make_fake_node(id)
  local node = gui.new_box_node(vmath.vector3(0), vmath.vector3(0))
  gui.set_id(node, id)
  gui.set_visible(node, false)
  return node
end

local function set_element_first(list, element)
  local pos = 0
  for i, el in ipairs(list) do
    if el == element then
      pos = i
      break
    end
  end
  if pos>1 then
    table.remove(list, pos)
    table.insert(list, 1, element)
  end
end

---@param el GuiLibBase
local function dump_tree(el, level)
  local disabled_status = ""
  if not gui.is_enabled(el.node) then disabled_status = " (Disabled)" end
  local result = "\n" .. string.rep("  ", level) .. tostring(gui.get_id(el.node)) .. disabled_status
  for i, e in ipairs(el.get_children()) do
    result = result .. dump_tree(e, level + 1)
  end
  return result
end

local function clear_table(t)
  for k, v in pairs(t) do t[k] = nil end
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

  local function create_element(p_node, p_namespace)
    local children = {}
    local is_hovered = false
    local is_pressed = false
    local namespace = p_namespace

    local function __get_node(node)
      if type(node) == "string" then
        return gui.get_node(namespace .. node)
      end
      return node
    end
    ---@class GuiLibBase
    local element = {
      ---@type node
      node = __get_node(p_node),
      actions = {},
    }

    ---Return node from current namespace
    ---@param name string
    ---@return node
    element.get_node = function(name)
      return gui.get_node(namespace .. name)
    end

    ---@param set string
    ---@param append? boolean
    element.set_namespace = function(set, append)
      if append then
        namespace = namespace .. set
      else
        namespace = set
      end
      if not string.match(namespace, "(/)$") then
        namespace = namespace .. "/"
      end
    end

    ---@return string
    element.get_namespace = function()
      return namespace
    end

    ---@param set bool
    element.set_enabled = function(set)
      gui.set_enabled(element.node, set)
    end
    ---Bind action to node
    ---@param action hash|string
    ---@param handler fun(action: table)
    element.on = function(action, handler)
      if element.actions[action] then
        local previous_handler = element.actions[action]
        element.actions[action] = function(e)
          previous_handler(e)
          handler(e)
        end
      else
        element.actions[action] = handler
      end
      return element
    end

    ---@param node string|userdata
    ---@param actions? table
    ---@return GuiLibElement
    element.add = function(node, actions)
      ---@class GuiLibElement: GuiLibBase
      local child = create_element(node, namespace)
      table.insert(children, 1, child)
      if actions then
        for action_id, action in pairs(actions) do
          child.on(action_id, action)
        end
      end

      ---@param update_index? boolean
      child.move_to_top = function(update_index)
        set_element_first(children, child)
        if update_index then
          local parent = gui.get_parent(child.node)
          gui.set_parent(child.node, nil)
          gui.set_parent(child.node, parent)
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

    element.emit_action = function(action_id, action_data, recursive)
      call_event(element, element.actions[action_id], action_data or {})
      if recursive == nil or recursive == true then
        for _, c in ipairs(children) do
          c.emit_action(action_id, action_data, recursive)
        end
      end
    end

    element.on_input = function(action_id, action)
      if not gui.is_enabled(element.node, true) then return end

      for _, el in ipairs(children) do
        catched = el.on_input(action_id, action)
      end

      if action_id == nil and action.x and action.y then
        local do_enter = false
        local do_leave = false
        if not catched and gui.pick_node(element.node, action.x, action.y) then
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
            catched = call_event(element, element.actions.released, action)
          elseif action.pressed == false then
            catched = call_event(element, element.actions.hold, action)
          end
        end
        if not catched and gui.pick_node(element.node, action.x, action.y) then
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
          call_event(element, element.actions[action_id], action)
        end
      end
      return catched
    end

    ---@return table<GuiLibElement>
    element.get_children = function()
      return children
    end

    element.dump_tree = function()
      pprint(dump_tree(element, 0))
    end

    return element
  end

  ---- Make root element
  ---@class GuiLibRoot : GuiLibElement
  local root_element = create_element(make_fake_node(hash("guilib:root")), "")
  local on_input = root_element.on_input
  root_element.on_input = function(action_id, action)
      --- store active(pressed) actions in global storage
      if action.pressed then
        pressed_action[action_id] = true
      elseif action.released then
        pressed_action[action_id] = nil
      end
      catched = nil
      on_input(action_id, action)
  end

  return root_element
end
