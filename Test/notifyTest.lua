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
	local msg = linda:receive(0.3, "master")
	while msg ~= "STOP" do
		notify:read()
		for ev in notify:events() do
			local str = ""
			if ev:IN_ISDIR() then
				str = string.format("directory '%s/%s'", notify:pathForWatch(ev.WD), ev.Name)
			else
				str = string.format("file '%s/%s'", notify:pathForWatch(ev.WD), ev.Name)
			end
			if ev:IN_MOVE() then
				print(string.format("  - MOVED %s", str))
			elseif ev:IN_CLOSE() then
				print(string.format("  - CLOSED %s", str))
			elseif ev:IN_CREATE() then
				print(string.format("  - CREATED %s", str))
			elseif ev:IN_DELETE() then
				print(string.format("  - DELETED %s", str))
			elseif ev:IN_MODIFY() then
				print(string.format("  - MODIFIED %s", str))
			elseif ev:IN_OPEN() then
				print(string.format("  - OPENED %s", str))
			elseif band(ev.Mask, bor(lNotify.IN_ACCESS, lNotify.IN_ATTRIB)) then
				print(string.format("  - ACCESSED %s", str))
			else
				print(string.format("  - UNKNOW EVENT %s", str))
			end
		end
	end
end

local function main (argc, argv)
	print("Creando Notifier")
	local myNotify = lNotify.NewNotify()
	print("\t*Adding Watch: /tmp")
	myNotify:addWatch("/tmp", lNotify.IN_ALL_EVENTS)
	linda:set("notify", myNotify)
	print("Launching events thread")
	lanes.gen("*", _thread)()
	os.execute("sleep 300")
end

main(#arg, arg)
