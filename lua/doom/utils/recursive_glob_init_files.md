# Recursive glob module init.lua files

To find the topmost `init.lua` files in the `modules` directory in Neovim,
while ignoring deeper `init.lua` files within subdirectories, you can use a Lua
script with the following logic:

1. Traverse the `modules` directory recursively.
2. Identify directories containing `init.lua` files.
3. Stop further traversal once an `init.lua` is found in a directory.

Here’s how you can achieve this:

## Example Script in Lua

```lua
local uv = vim.loop

-- Function to get all topmost `init.lua` files
local function find_topmost_init(dir)
    local results = {}
    local dirs_to_check = { dir }

    while #dirs_to_check > 0 do
        local current_dir = table.remove(dirs_to_check)
        local entries = uv.fs_scandir(current_dir)

        if entries then
            local has_init = false

            for entry in function() return uv.fs_scandir_next(entries) end do
                local entry_path = current_dir .. "/" .. entry
                local stat = uv.fs_stat(entry_path)

                if stat.type == "file" and entry == "init.lua" then
                    has_init = true
                    table.insert(results, entry_path)
                elseif stat.type == "directory" then
                    table.insert(dirs_to_check, entry_path)
                end
            end

            -- If `init.lua` exists, ignore subdirectories in this branch
            if has_init then
                dirs_to_check = vim.tbl_filter(function(path)
                    return not vim.startswith(path, current_dir .. "/")
                end, dirs_to_check)
            end
        end
    end

    return results
end

-- Example usage
local init_files = find_topmost_init("modules")
for _, file in ipairs(init_files) do
    print(file)
end
```

## How It Works

1. **Recursive Traversal**:
   - Use `uv.fs_scandir` to iterate through directory entries.
   - Check if an entry is a file named `init.lua`.
2. **Avoid Deeper Traversals**:
   - If an `init.lua` is found in a directory, exclude subdirectories of that
     directory from further checks.
3. **Results**:
   - Gather paths of `init.lua` files that are the topmost in their respective
     branches.

## Run It in Neovim

1. Save the script in your Neovim configuration or as a Lua file.
2. Run the script using `:lua dofile('<path_to_script>.lua')`.
3. It will print the list of topmost `init.lua` files in the `modules` directory.

## Explanation of Key Functions

- `vim.loop.fs_scandir`: Iterates over directory entries.
- `vim.loop.fs_stat`: Retrieves file/directory metadata.
- `vim.tbl_filter`: Filters out paths of subdirectories if `init.lua` exists in
  a parent.

This approach ensures you only collect top-level `init.lua` files without being
affected by deeper files.
