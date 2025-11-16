profiler = {}
profiler.timemap = {}
function profiler.start(label)
    profiler.timemap[label] = SysTime()
end

function profiler.fin(label)
    if not profiler.timemap[label] then
        print(label .. ": no such timer")
        return
    end

    local dt = SysTime() - profiler.timemap[label]
    print(label .. ": " .. dt .. " seconds")
    profiler.timemap[label] = nil
end