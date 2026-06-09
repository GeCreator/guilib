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
---@param guilib GuiLib
local function create_box(guilib, log)
  guilib.on("pressed",  function() log("Drag Begin") end)
  guilib.on("hold",  function() log("Drag") end)
  guilib.on("released",  function() log("Drag End") end)
  return guilib
end

---@param element GuiLib
---@param log fun(text: string)
return function(element, log)
  local pos = gui.get_position(element.get_node('box2'))

  print(pos)
  -- pprint(get_children(element.node))
  -- components.dragable(create_box(element.add("box1"), log))
  components.dragable(create_box(element.add("box1"), log))
  -- components.dragable(create_box(element.add("box3"), log))
end
