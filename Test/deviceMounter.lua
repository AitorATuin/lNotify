local HOME = os.getenv("HOME")
local LOCALLUAPATH = HOME .. "/.lua/share/?.lua;" .. HOME ..  "/.lua/share/?/?.lua"

package.path = package.path .. ";" .. LOCALLUAPATH

require "luarocks.require"
require "lNotify"
require "lanes"
require "bit"

-- Create a linda object to communicate thread with main process
local linda = lanes.linda()
local Constants = lNotify.Constants
local band = bit.band
local bor = bit.bor

-- function to be executed in the thread
local function _thread ()
	package.path = package.path .. ";" .. LOCALLUAPATH
	pcall(require, "lNotify")
	-- Required to create a new copy of the notify
	local notify = lNotify.NewNotifyFromMemory(linda:get("notify"))
    local DevicesToSearch = linda:get("DevicesToSearch")
	local msg = linda:receive(0.3, "master")
    for i,v in pairs(DevicesToSearch) do
        print(i,v)
    end
	while msg ~= "STOP" do
		notify:read()
		for ev in notify:events() do
			local str = ""
			if not ev:IN_ISDIR() and ev.Name ~= "ptmx" then
                if DevicesToSearch[ev.Name] then
--				str = string.format("file '%s/%s'", notify:pathForWatch(ev.WD), ev.Name)
                   if ev:IN_CREATE() then
                        print(string.format("  - CREATED %s", ev.Name))
                    elseif ev:IN_DELETE() then
                        print(string.format("  - DELETED %s", ev.Name))
                    end
                end
            end
		end
	end
end

DevicesToSearch = {
    sdc1 = true,
    sdc2 = true,
    sdc3 = true
}

local function main (argc, argv)
	print("Creando Notifier")
	local myNotify = lNotify.NewNotify()
	print("\t*Adding Watch: /dev")
	myNotify:addWatch("/dev/", lNotify.IN_ALL_EVENTS)
	linda:set("notify", myNotify)
    linda:set("DevicesToSearch", DevicesToSearch)
	print("Launching events thread")
	lanes.gen("*", _thread)()
	os.execute("sleep 300")
end

main(#arg, arg)
