local components = require("guilib.components")

local function get_children(node)
  local tree = gui.get_tree(node)
  tree[gui.get_id(node)] = nil
  for k, c in pairs(tree) do
    if gui.get_parent(c) ~= node then
      tree[k] = nil
    end
  end
  return tree
end
---@param box GuiLibElement
local function create_box(box, log)
  box.on("pressed",  function() log("Drag Begin") end)
  box.on("hold",  function() log("Drag") end)
  box.on("released",  function() log("Drag End") end)
  return box
end

---@param guilib GuiLib
---@param log fun(text: string)
return function(guilib, template, log)

  -- pprint(get_children(element.node))
  -- components.dragable(create_box(element.add("box1"), log))
  components.dragable(create_box(guilib.add(template .. "/box1"), log))
  -- components.dragable(create_box(element.add("box3"), log))
end
