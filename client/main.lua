local enet = require("enet")
local address, port = "localhost", 12345
local host = enet.host_create()
local server = host:connect(address..":"..tostring(port))

local messages = {}

local success = host:service(1000) -- sends connection to server, 1000ms timeout
if not success then
  table.insert(messages, "Could not connect to server")
  host = nil
end

love.update = function()
  if host then
    local event = host:service(3) -- 3ms timeout, just put it higher in a thread
    local count, limit = 0, 50 -- Since it isn't threaded, make sure it exits update
    while event and count < limit do
      if event.type == "receive" then
        table.insert(messages, event.data)
      elseif event.type == "disconnect" then
        if event.peer == server then
          table.insert(messages, "Disconnected: "..event.data)
        end
      elseif event.type == "connect" then
        if event.peer ~= server then
          event.peer:disconnect_now() -- Don't want other clients connecting to this client
        end
      end
      event = host:service() -- receive any waiting messages
      count = count + 1
    end
  end
end

local text = ""

local lg = love.graphics
love.draw = function()
  lg.print("> "..text)
  lg.print("\n"..table.concat(messages, "\n"))
end

love.textinput = function(t)
  text = text..t
end

local utf8 = require("utf8")
love.keypressed = function(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(text, -1)
    if byteoffset then
      text = text:sub(1, byteoffset-1)
    end
  elseif key == "return" then
    if text == "disconnect" then
      server:disconnect()
    else
      server:send(text)
      text = ""
    end
  end
end