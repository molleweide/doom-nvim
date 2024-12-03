local uv = vim.uv
local luv = vim.loop
local fs = {}

-- TODO: Replace everything here with `fs` utils from rocks-nvim.

if jit ~= nil then
    fs.is_windows = jit.os == "Windows"
else
    fs.is_windows = package.config:sub(1, 1) == "\\"
end

if fs.is_windows and vim.o.shellslash then
    fs.use_shellslash = true
else
    fs.use_shallslash = false
end

fs.get_seperator = function()
    if fs.is_windows and not fs.use_shellslash then
        return "\\"
    end
    return "/"
end

--- Joins a number of strings into a valid path
---@vararg string String segments to convert to file system path
fs.join_paths = function(...)
    return table.concat({ ... }, fs.get_seperator())
end

--- Check if the given file exists
--- @param path string The path of the file
--- @return boolean
fs.file_exists = function(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    if fd then
        vim.loop.fs_close(fd)
        return true
    end

    return false
end

--- Returns the content of the given file
--- @param path string The path of the file
--- @return string
fs.read_file = function(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    local stat = vim.loop.fs_fstat(fd)
    local data = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)

    return data
end

--- write_file writes the given string into given file
--- @param path string The path of the file
--- @param content string The content to be written in the file
--- @param mode string The mode for opening the file, e.g. 'w+'
fs.write_file = function(path, content, mode, cb)
    -- 644 sets read and write permissions for the owner, and it sets read-only
    -- mode for the group and others.
    vim.loop.fs_open(path, mode, tonumber("644", 8), function(err, fd)
        if not err then
            local fpipe = vim.loop.new_pipe(false)
            vim.loop.pipe_open(fpipe, fd)
            vim.loop.write(fpipe, content, cb)
        end
    end)
end

--- Write `contents` to a file asynchronously
---@param location string file path
---@param mode string mode to open the file for
---@param contents string file contents
---@param callback? function
function fs.write_file2(location, mode, contents, callback)
    local dir = vim.fs.dirname(location)
    fs.mkdir_p(dir)
    -- 644 sets read and write permissions for the owner, and it sets read-only
    -- mode for the group and others
    uv.fs_open(location, mode, tonumber("644", 8), function(err, file)
        if file and not err then
            uv.fs_write(file, contents, function(write_err)
                if write_err then
                    local msg = ("Error writing %s: %s"):format(location, err)
                    print("ERROR:", msg)
                    vim.schedule(function()
                        vim.notify(msg, vim.log.levels.ERROR)
                    end)
                end
                if file then
                    uv.fs_close(file)
                end
                if callback then
                    callback()
                end
            end)
        else
            local msg = ("Error opening %s for writing: %s"):format(location, err)
            print("ERROR:", msg)
            vim.schedule(function()
                vim.notify(msg, vim.log.levels.ERROR)
            end)
            if callback then
                callback()
            end
        end
    end)
end

---Get the sync awaiter func
fs.get_write_file_awaiter = function()
    local nio = require("nio")
    if not nio then
        print("ERROR: nio couldnt be required..")
        return false
    end

    --- Write `contents` to a file and wait in an async context
    ---@type async fun(location:string, mode:string, contents:string)
    return nio.create(function(location, mode, contents)
        local future = nio.control.future()
        vim.schedule(function()
            fs.write_file2(location, mode, contents, function()
                print("write file await: set future true")
                future.set(true)
            end)
        end)
        return future.wait()
    end, 3)
end

---Recursively remove a dir.
fs.rm_dir = function(path)
    local handle = luv.fs_scandir(path)

    if type(handle) == "string" then
        return fs.notify.error(handle)
    end

    while true do
        local name, t = luv.fs_scandir_next(handle)
        if not name then
            break
        end

        local new_cwd = fs.join_paths(path, name)
        if t == "directory" then
            local success = fs.rm_dir(new_cwd)
            if not success then
                return false
            end
        else
            local success = luv.fs_unlink(new_cwd)
            if not success then
                return false
            end
        end
    end

    return luv.fs_rmdir(path)
end

---Create directory, including parents
---@param dir string
---@return boolean success
function fs.mkdir_p(dir)
    local mode = 493
    local mod = ""
    local path = dir
    while vim.fn.isdirectory(path) == 0 do
        mod = mod .. ":h"
        path = vim.fn.fnamemodify(dir, mod)
    end
    while mod ~= "" do
        mod = string.sub(mod, 3)
        path = vim.fn.fnamemodify(dir, mod)
        vim.uv.fs_mkdir(path, mode)
    end
    if not vim.uv.fs_stat(dir) then
        print("ERROR fs.mkdir_p: Failed to create directory: " .. dir)
        return false
    end
    return true
end

return fs
