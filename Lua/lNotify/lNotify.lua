module("lNotify", package.seeall)
require "luarocks.require"
require "alien"
require "bit"
require "lNotify.Constants"
require "lNotify.struct"

local SOPATH = os.getenv("lNOTIFYSO_DIR") or "/usr/lib/lua"
local PATHS = {
    os.getenv("LNOTIFYSODIR") or "./",
    os.getenv("HOME") .. "/.lua/lib/",
}
for p in package.cpath:gmatch("[^;]+") do
    PATHS[#PATHS+1] = p:match("(.+)/+[^/]+$")
end

local liblnotify, success
for _, p in ipairs(PATHS) do
    success, liblnotify = pcall(alien.load,
        p.."/liblnotify.0.1.so")
    if success then
        break
    end
end

if not success then
    error("Could not load liblnotify.0.1.so")
end


local libc = alien.default
local band = bit.band

-- Structs
local s_inotifyev = struct.defstruct{
	{"WD", "int"},
	{"Mask", "int"},
	{"Cookie", "int"},
	{"Length", "int"},
	{"Name", "pointer"}
}

libc.inotify_init:types {
	ret = "int",
}
libc.inotify_add_watch:types {
	ret = "int",
	"int",
	"pointer",
	"int"
}
libc.inotify_rm_watch:types{
	ret = "int",
	"int",
	"int"
}

libc.read:types{
	ret = "int",
	"int",
	"pointer",
	"int" 	
}

liblnotify._event_size:types{
	ret = "int"
}
liblnotify._read:types{
	ret = "int",
	"int", "pointer",
}

EVENT_SIZE = liblnotify._event_size()

-- Event methods {{{
local function is_flag_set (event, flag)
	if band(event.Mask, flag) ~= 0 then
		return true
	end
	return false
end
-- }}}
local flags = {
	"IN_ACCESS",
	"IN_ATTRIB",
	"IN_CLOSE_WRITE",
	"IN_CLOSE_NOWRITE",
	"IN_CREATE",
	"IN_DELETE",
	"IN_DELETE_SELF",
	"IN_MODIFY",
	"IN_MOVE_SELF",
	"IN_MOVED_FROM",
	"IN_MOVED_TO",
	"IN_OPEN",
	"IN_ALL_EVENTS",
	"IN_MOVE",
	"IN_CLOSE",
	"IN_IGNORED",
	"IN_ISDIR",
	"IN_Q_OVERFLOW",
	"IN_UNMOUNT"
}

local event_mt = {
}

-- Populate event metatable with flag checkers
for _, name in pairs(flags) do
	event_mt[name] = function (event)
		return is_flag_set(event, lNotify[name])
	end
end

-- NewEvent
-- Wrapper to s_inotifyev struct to get name field
s_inotifyev._new = s_inotifyev.new
s_inotifyev.new = function (s_proto, ptr)
	local t = s_inotifyev:_new(ptr)
	local mt = getmetatable(t)
	mt.___index = mt.__index
	mt.__index = function (tt, key)
		if key == "Name" then
			local str = ""
			if tt.Length > 0 then
				for i=0, tt.Length-1 do
					str = string.format("%s%c",str,
						tt():get(s_proto.offsets[key]+1+i, "char"))
				end
			end
			return str
		elseif event_mt[key] then
			return event_mt[key]
		else
			return mt.___index(tt, key)
		end
	end
	return t
end

-- EventsBuffer

local function events_iterator (events_buffer)
	local offset = 1
	return function ()
		if (offset < events_buffer.Read) then
			local ev = s_inotifyev:new(events_buffer.Buffer:topointer(offset))
			offset = offset + EVENT_SIZE + ev.Length
			return ev
		else
			return nil
		end
	end
end

local eventsbuffer_mt = {
	events = events_iterator
}

NewEventsBuffer = function (n)
	local t = {}
	local size = (EVENT_SIZE + 16) * (n or 1024)
	t.Buffer = alien.buffer(size)
	t.Size = size
	t.N = n
	return setmetatable(t, {
		__index = eventsbuffer_mt
	})
end

local function add_watch (notify, file, mask)
	local wd = libc.inotify_add_watch(notify.fd, file, mask)
	if wd < 0 then
		return nil
	end
	if not notify.Watchs[wd] then
		notify.Watchs[#notify.Watchs+1] = {
			Path = file,
			Wd = wd,
			Mask = mask,
		}
	end
	return wd
end

local function rm_watch (notify, wd)
	if libc.inotify_rm_watch(notify.fd, wd) < 0 then
		return false
	end
	notify.Watchs[wd] = nil
	return true
end

local function path_for_watch (notify, wd)
--	print(notify)
	return notify.Watchs[wd].Path
end

-- TODO, add signature to read
local function read (notify)
 	local read = libc.read(notify.fd, notify.EventsBuffer.Buffer, notify.EventsBuffer.Size)
	notify.EventsBuffer.Read = read
	return read
end

local function get_events (notify)
	return notify.EventsBuffer:events()
end

local kill = function (notify)
	for wd in ipairs(notify.Watchs) do
		notify:rmWatch(wd)
	end
end

local notify_mt = {
	addWatch = add_watch,
	rmWatch = rm_watch,
	pathForWatch = path_for_watch,
	read = read,
	events = get_events,
	kill = kill
}

NewNotify = function (n)
	local t = {
	}
	t.fd = libc.inotify_init()
	t.EventsBuffer = NewEventsBuffer(n)
	t.Watchs = {}

	return setmetatable(t, {
		__index = notify_mt
	})
end

-- Needed to bypass memory restrictions when using in multithreading envs
NewNotifyFromMemory = function(notify, n)
	local t = {
	}
	t.fd = notify.fd
	t.Watchs = {}
	for w, wv in pairs(notify.Watchs) do
		t.Watchs[1] = {}
		for j,k in pairs(wv) do
			t.Watchs[w][j] = k
		end
	end
	t.EventsBuffer = NewEventsBuffer(notify.EventsBuffer.N)
	return setmetatable(t, {
		__index = notify_mt
	})

end

---- vi: set foldmethod=marker foldlevel=0:
