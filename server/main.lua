local enet = require("enet")
local address, port = "*", 12345
local host = enet.host_create(address..":"..tostring(port))

love.update = function()
  if host then
    local event = host:service(3) -- 3ms timeout, just put it higher in a thread
    local count, limit = 0, 50 -- Since it isn't threaded, make sure it exits update
    while event and count < limit do
      if event.type == "receive" then
        host:broadcast(tostring(event.peer)..": "..event.data) -- do tostring(peer) to get ip and port it is coming from
        -- event.peer:send(data) to send data to just that client
      elseif event.type == "connect" then
        host:broadcast(tostring(event.peer).." has joined the server!")
      elseif event.type == "disconnect" then
        host:broadcast(tostring(event.peer).." has left the server!")
      end
      event = host:service()
      count = count + 1
    end
  end
end