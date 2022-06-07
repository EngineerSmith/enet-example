local enet = require("enet")
local address, port = "*", 12345
local host = enet.host_create(address..":"..tostring(port))

if not host then -- may fail to start if port is already in use
  love.draw = function() love.graphics.print("Could not start server on port "..port) end
else
  love.draw = function() love.graphics.print("Server is running on port "..port) end
end

love.update = function()
  if host then
    local event = host:service(3) -- 3ms timeout, recommended to put it higher in a thread
    local count, limit = 0, 50 -- Since it isn't threaded, make sure it exits update after a reasonable number of cycles 
    while event and count < limit do -- (love.event funcs in love.run still needs to run for server)
      if event.type == "receive" then
        host:broadcast(tostring(event.peer)..": "..event.data) -- do tostring(peer) to get ip and port it is coming from
        -- event.peer:send(data) to send data to just that client
      elseif event.type == "connect" then
        host:broadcast(tostring(event.peer).." has joined the server!") -- Tell everyone someone has joined
      elseif event.type == "disconnect" then
        host:broadcast(tostring(event.peer).." has left the server!") -- Tell everyone someone has left
      end
      event = host:check_events() -- get the next event in queue - no waiting
      count = count + 1
    end
  end
end