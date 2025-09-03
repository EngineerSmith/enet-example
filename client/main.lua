local enet = require("enet")
local address, port = "localhost", 12345
local host = enet.host_create(nil, 1) -- Tell the client it can only have 1 peer, the server to ensure nobody else tries to connect
local server = host:connect(address..":"..tostring(port)) -- Connects on the next :service call

local messages = {} -- table to hold all our returned messages from the server

local success = host:service(5000) -- sends connection to server, 5sec timeout
if not success then -- failed to reach server
  table.insert(messages, "Could not connect to server at "..address..":"..port)
  host = nil
end

love.update = function()
  if host then
    local event = host:service(3) -- 3ms timeout, just put it higher in a thread
    local count, limit = 0, 50 -- Since it isn't threaded, make sure it exits update
    while event do
      if event.type == "receive" then
        table.insert(messages, event.data)
      elseif event.type == "disconnect" then
        if event.peer == server then -- This should always be true due to the next statement about inbound connections
          table.insert(messages, "Disconnected: "..event.data)
        end
      elseif event.type == "connect" then
        if event.peer ~= server then
          event.peer:disconnect_now() -- Don't want other clients connecting to this client
        end
      end
      count = count + 1
      if count < limit then
        break
      end
      event = host:check_events() -- receive any waiting messages
    end
  end
end

local text = "" -- holds current unsent message

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
  if key == "backspace" then -- Simple utf8 backspace func taken from the love wiki
    local byteoffset = utf8.offset(text, -1)
    if byteoffset then
      text = text:sub(1, byteoffset-1)
    end
  elseif key == "return" then
    if text == "disconnect" then
      server:disconnect() -- If "disconnect" is typed and return has been pressed disconnect from the server
    else
      server:send(text) -- otherwise send the current message
      text = ""
    end
  end

end
