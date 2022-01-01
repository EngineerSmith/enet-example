-- Quick script to switch between client and server main.lua
-- Run with argument `-server` to start server, otherwise it will launch a client
love.load = function(args)
  for _, arg in ipairs(args) do
    if arg == "-server" then
      require("server.main")
      return
    end
  end
  require("client.main")
  return
end