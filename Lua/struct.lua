--module("struct", package.seeall)

local M = {}

local core = require "alien"

local function get_key (str)
   local t, s = str:match("(%a+)%[*(%d*)%]*")
   return t, tonumber(s)
end

local function get_type (str)
   if type(str) == "table" then -- array
      return str[1], str[2] -- return type and size of array
   else
      return str -- return simple type
   end
end

local function struct_new(s_proto, ptr)
   local _type = type
   local buf = core.buffer(ptr or s_proto.size)
   local newstruct = {}
   local function struct_get(_, key)
      if (key == "offset") then
         return function (field)
            return s_proto.offsets[field] + 1
         end
      end
      if s_proto.offsets[key] then
         return buf:get(s_proto.offsets[key] + 1, s_proto.types[key])
      else
         error("field " .. key .. " does not exist")
      end
   end
   local function struct_set(_, key, val)
      if s_proto.offsets[key] then
         buf:set(s_proto.offsets[key] + 1, val, s_proto.types[key])
      else
         error("field " .. key .. " does not exist")
      end
   end
   local function struct_array_get(arr, key)
      if key < 1 or key > arr.length then
         error("Out of limits")
      end
      return arr.buffer:get(arr.offset - 1 + key, arr.type)
   end
   local function struct_array_set(arr, key, val)
      if key < 1 or key > arr.length then
         error("Out of limits")
      end
      arr.buffer:set(arr.offset -1 + key, string.byte(val), arr.type)
   end
   for field, fieldtype in pairs(s_proto.types) do
      if _type(fieldtype) == "table" then
         newstruct[field] = {
            buffer = buf,
            offset = s_proto.offsets[field]+1,
            topointer = function (t)
               return t.buffer:topointer(s_proto.offsets[field]+1)
            end,
            tostring = function (t)
               -- TODO: Support other array types, not only char
               local str = ""
               for i=1, t.length do
                  if t[i] == 0 then
                            return str
                  end
                  str = str .. string.char(t[i])
               end
            end,
            length = fieldtype[2],
            type = fieldtype[1],
            size = alien.sizeof(fieldtype[1])
         }
         setmetatable(newstruct[field], {
                         __index = struct_array_get,
                         __newindex = struct_array_set,
                         __call = function (t) return t.buffer end,
         })
      end
   end

   return setmetatable(newstruct, {
                          __index = struct_get,
                          __newindex = struct_set,
                          __call = function () return buf end })
end

local function struct_byval(s_proto)
   local types = {}
   local size = s_proto.size
   for i = 0, size - 1, 4 do
      if size - i == 1 then
         types[#types + 1] = "char"
      elseif size - i == 2 then
         types[#types + 1] = "short"
      else
         types[#types + 1] = "int"
      end
   end
   return unpack(types)
end

M.defStruct = function (t)
   local off = 0
   local names, offsets, types = {}, {}, {}
   for _, field in ipairs(t) do
      local size
      local name, type = field[1], field[2]
      type, size = type:match("(%a+)%[*(%d*)%]*")
      size = tonumber(size) or 1
      names[#names + 1] = name
      off = math.ceil(off / core.align(type)) * core.align(type)
      offsets[name] = off
      if size > 1 then
         types[name] = {type,tonumber(size)}
      else
         types[name] = type
      end
      off = off + core.sizeof(type) * size
   end

   return { names = names, offsets = offsets, types = types, size = off, new = struct_new,
            byval = struct_byval }
end

return M
