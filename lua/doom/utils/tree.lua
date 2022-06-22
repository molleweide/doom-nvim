-- put generalized functions for managing recursive trees
-- in doom here.
--
--
-- see if I can refactor `dui/make_results` and `core/config` to here.
--
--
--
--
--
--
--
--  - be_recursive        bool (treat like a regular array??)
--  - cb_leaf             fn
--  - return_flattened    bool
--  - branch_signifiers   string
--  - ignore_empty?
--  - ??
--
--
--
--
--
-- todo: copy paste all recursive functions I have to here!


--
-- CHECK IF WE SHOULD RECURSE DOWN?
--

--
-- CHECK IF WE SHOULD RECURSE DOWN?

M.we_can_recurse = function(a, b)

  if type(a) == "number" then
     return false
   end

   if type(b) ~= "table" then
     -- print(":: number:", b)
     return false
   end

   local cnt = 0
   for k, v in pairs(b) do
     cnt = cnt + 1
     if type(k) == "number" then
       -- print("IS_SUB; sub table has number",  a)
       return false
     end
   end
   if cnt == 0 then
     return false
   end

   return true
end



--
-- GENERALIZED DOOM TREE RECURSOR
--

---@param tree
---@param stack
local function traverse_tree(tree, stack)
  local flattened = flattened or {}
  local stack = stack or {}

   for k, v in pairs(tree) do

     -- BRANCH
     if type(v) == "table" then
       table.insert(stack, k)
       -- table.insert(flattened, entry)
       traverse_tree(v, stack)

     -- LEAF
     else
       local pc = { v }
       if #stack > 0 then
         pc = vim.deepcopy(stack)
         table.insert(pc, v)
       end
       require_modules(pc)

       -- table.insert(flattened, entry)
     end
   end

   table.remove(stack, #stack)
   return
end


--
-- CORE CONFIG RECURSE
--

--- Recursively crawl the modules tree and require each leaf module.
---@param modules_tree  enabled modules table
---@param stack         stack to keep track of each module path
local function recurse_modules(modules_tree, stack)
 local stack = stack or {}
 for k, v in pairs(modules_tree) do
   if type(v) == "table" then
     table.insert(stack, k)
     recurse_modules(v, stack)
   else
     local pc = { v }
     if #stack > 0 then
       pc = vim.deepcopy(stack)
       table.insert(pc, v)
     end
     require_modules(pc)
   end
 end
 table.remove(stack, #stack)
 return
end
