--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.3       		   **
**  github.com/IMXNOOBX/ScriptKid  **
**  Original developer: Unknown    **
]]


util.require_natives(1660775568)

-- basic friend list cuz the one ingame sucks, if u add someone as friend this list wont update, restart script to fix yes
local function get_friend_count()
    native_invoker.begin_call();
    native_invoker.end_call("203F1CFD823B27A4");
    return native_invoker.get_return_value_int();
end
local function get_frien_name(friendIndex)
    native_invoker.begin_call();
    native_invoker.push_arg_int(friendIndex);
    native_invoker.end_call("4164F227D052E293");
    return native_invoker.get_return_value_string();
end
local function get_frien_status(friendIndex)
    native_invoker.begin_call();
    native_invoker.push_arg_int(friendIndex);
    native_invoker.end_call("BAD8F2A42B844821");
    return native_invoker.get_return_value_boolean();
end

menu.divider(menu.my_root(), "Frien List :D")
local function gen_frien_funcs(name, nstatus)
    local friend = menu.list(menu.my_root(), nstatus, {"Friend " .. name}, "", function()

    end)
    menu.divider(friend, nstatus)
    menu.action(friend, "Join", {"jf " .. name}, "", function()
        menu.trigger_commands("join " .. name)
    end)
    menu.action(friend, "Spectate", {"sf " .. name}, "", function()
        menu.trigger_commands("namespectate " .. name)
    end)
    menu.action(friend, "Invite", {"if " .. name}, "", function()
        menu.trigger_commands("invite " .. name)
    end)
    menu.action(friend, "Open profile", {"pf " .. name}, "", function()
        menu.trigger_commands("nameprofile " .. name)
    end)
end

for i = 0, get_friend_count() do
    local name = get_frien_name(i)
    if name == "*****" then
        goto yes
    end
    local nstatus = name ..' ['..(NETWORK.NETWORK_IS_FRIEND_IN_MULTIPLAYER(name) == true and "Online" or "Offline")..']'
    gen_frien_funcs(name, nstatus)
    ::yes::
end

while true do
    util.yield()
end
