local PADDING = 2

---@param guilib GuiLib
---@param template_name string
---
---@return guilib_dropdown_component
return function(guilib, template_name)
  local main = guilib.add(template_name .. "/root")
  local choices = {}
  local opened = false
  local NODE_CHOICE_BOX_TEMPLATE = gui.get_node(template_name .. "/choice_box_template")
  local NODE_CHOICE_BOX_CONTAINER = gui.get_node(template_name .. "/choice_container")
  local NODE_TEXT = gui.get_node(template_name .. "/text")
  local HASH_CHOICE_BOX = hash(template_name .. "/choice_box_template")
  local HASH_CHOICE_TEXT = hash(template_name .. "/choice_text_template")
  local on_select_function = function(selection) pprint(selection.. " selected") end
  local sub = main.add(NODE_CHOICE_BOX_CONTAINER)

  local function refresh()
    gui.set_enabled(NODE_CHOICE_BOX_CONTAINER, opened)
    sub.set_enabled(opened)
  end
  refresh()

  local function select(name)
    gui.set_text(NODE_TEXT, name)
    on_select_function(name)
    opened = false
    refresh()
  end

  main.on("click_outside", function()
    opened = false
    refresh()
  end)
  main.on("pressed", function()
    opened = not opened
    refresh()
  end)
  main.on(hash('key_esc'), function(a)
    if a.pressed then
      opened = false
      refresh()
    end
  end)

  ---@class guilib_dropdown_component
  local dropdown = {
    add = function(name)
      local clone = gui.clone_tree(NODE_CHOICE_BOX_TEMPLATE)
      local size = gui.get_size(clone[HASH_CHOICE_BOX])
      local position = gui.get_position(clone[HASH_CHOICE_BOX])
      position.y = size.y * -#choices - PADDING
      gui.set_text(clone[HASH_CHOICE_TEXT], name)
      gui.set_position(clone[HASH_CHOICE_BOX], position)
      gui.set_enabled(clone[HASH_CHOICE_BOX], true)

      table.insert(choices, name)
      local container_size = gui.get_size(NODE_CHOICE_BOX_CONTAINER)
      container_size.y = size.y * #choices + PADDING * 2
      gui.set_size(NODE_CHOICE_BOX_CONTAINER, container_size)
      local base_color = gui.get_color(clone[HASH_CHOICE_BOX])
      local hover_color = vmath.vector4(base_color.x*1.1, base_color.y*1.1, base_color.z*1.1, 1.0)
      sub.add(clone[HASH_CHOICE_BOX], {
        pressed = function()
          select(name)
        end,
        enter = function(e)
          gui.set_color(clone[HASH_CHOICE_BOX], hover_color)
        end,
        leave = function(e)
          gui.set_color(clone[HASH_CHOICE_BOX], base_color)
        end
      })
    end,
    ---@param fun fun(selection: string)
    on_select = function(fun)
      on_select_function = fun
    end,
    ---@param selection string
    set_selected = function(selection)
      select(selection)
    end,
  }
  return dropdown
end
