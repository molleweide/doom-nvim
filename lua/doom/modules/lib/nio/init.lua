local utils = require("doom.utils")
local nio_nvim = {}

-- BUG: It seems that running nio funcs outside of 
-- async context errors?!

nio_nvim.packages = {
    ["nvim-nio"] = { "nvim-neotest/nvim-nio" },
}

local function test_nio(opts)
    local nio = require("nio")

    if not nio then
        return
    end

    opts = opts or {}

    opts.messages = {}

    local build_msg = utils.new_message_builder(opts.messages)

    -- run
    nio.run(function()
        nio.sleep(30)
    end, function()
        print("[NIO] 1. RUN: on run complete")
    end)
    print("[NIO] 1. RUN: last")

    -- WRAP
    --
    -- Creates an async function with a callback style function.
    -- Wrap the vim defer fn in a nio wrapper, which allows for
    -- executing the function within the nio world.
    -- so the defex func is then called. here we specify that our new
    -- async executor should accept two args, ms and then a callback.
    -- sleep 50 will then run our nio executed vim.defer_fn,

    local sleep = nio.wrap(function(ms, cb)
        vim.defer_fn(cb, ms)
    end, 2)

    nio.run(function()
        sleep(50, function()
            -- BUG: This callback is not printing out
            print("[NIO] 2. WRAP: on sleep complete")
        end)
        print("[NIO] 2. WRAP: after sleep")
    end)

    -- CREATE & GATHER
    --
    -- create to actions which I then run with gather to await
    -- them all concurrently, and then notify the user.

    local action1 = nio.create(function()
        local future = nio.control.future()
        local timer = vim.uv.new_timer()
        timer:start(1000, 0, function()
            future.set(true)
        end)
        future.wait()
        print("[NIO] CREATE: after action1 (1000)")
    end)
    local action2 = nio.create(function()
        local future = nio.control.future()
        local timer = vim.uv.new_timer()
        timer:start(5000, 0, function()
            future.set(true)
        end)
        future.wait()
        print("[NIO] CREATE: after action2 (5000)")
    end)
    nio.run(function()
        nio.gather({
            action1,
            action2,
        })
        print("[NIO] CREATE: after gather in run")
    end)

    -- EVENT
    -- Very basic, I create an event and then create nio
    -- runners that await this event. Then I can run a timer
    -- which sometime in the future sets this event, which will
    -- trigger all listeners.
    local event = nio.control.event()
    local trig_count = 0
    local worker = nio.run(function()
        nio.sleep(1000)
        trig_count = trig_count + 1
        event.set()
    end)
    local listeners = {
        nio.run(function()
            event.wait()
            print(("#%s | First listener notified"):format(trig_count))
        end),
        nio.run(function()
            event.wait()
            print(("#%s | Second listener notified"):format(trig_count))
        end),
    }

    -- FUTURE
    local future = nio.control.future()
    nio.run(function()
        print("[NIO] FUTURE: start")
        nio.run(function()
            nio.sleep(100 * math.random(1, 10))
            if not future.is_set() then
                future.set("Success!")
            end
        end)
        nio.run(function()
            nio.sleep(100 * math.random(1, 10))
            if not future.is_set() then
                future.set_error("Failed!")
            end
        end)
        local success, value = pcall(future.wait)
        print(("[NIO] FUTURE: %s: %s"):format(success, value))
    end)

    -- QUEUE
    local queue = nio.control.queue()
    local producer = nio.run(function()
        for i = 1, 10 do
            -- nio.sleep(100)
            nio.sleep(200 * math.random(1, 10))
            queue.put(i)
        end
        queue.put(nil)
    end)
    nio.run(function()
        while true do
            local value = queue.get()
            if value == nil then
                break
            end
            print("queue value:", value)
        end
    end)
    print("[NIO] QUEUE: Done")

    -- semaphore
    local semaphore = nio.control.semaphore(3)

    local value = 0
    for _ = 1, 15 do
        nio.run(function()
            semaphore.with(function()
                value = value + 1

                nio.sleep(10)
                print("semaphore value:", value) -- Never more than 3

                value = value - 1
            end)
        end)
    end
end

local function nio_monitor_tests()
    doom.features.monitoring.spawn_buffer_monitor({
        name = "NioTesting",
        description = "Run output for nio testing",
        pattern = "lua/doom/modules/lib/nio/init.lua",
        command = function()
            return require("doom.modules.lib.nio").test_nio()
        end,
        -- Specify which global variable that hosts the dynamically set
        -- input args to test for.
        -- args = "__monitor_doom_debug_binds",
    })
end

nio_nvim.cmds = {
    -- {
    --     "MonitorNioTesting",
    --     function()
    --         nio_monitor_tests()
    --     end,
    -- },
    {
        "NioTesting",
        function()
            test_nio()
        end,
    },
    {
        "NioTest2",
        function()
            local nio = require("nio")
            local future = nio.control.future()

            -- local timer = vim.uv.new_timer()
            -- timer:start(1000, 0, function()
            --     future.set()
            --     print("nio: inside timer after set")
            -- end)

            nio.run(function()
                nio.sleep(100 * math.random(1, 10))
                if not future.is_set() then
                    future.set("Success!")
                end
            end)

            nio.run(function()
                nio.sleep(100 * math.random(1, 10))
                if not future.is_set() then
                    future.set_error("Failed!")
                end
            end)

            print("nio: before wait")
            -- future.wait()

            local success, value = pcall(future.wait)
            print(("nio test results: %s: %s"):format(success, value))

            print("nio: after wait")
        end,
    },
}

return nio_nvim
