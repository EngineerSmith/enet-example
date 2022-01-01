# Love2D ENet code example : Client-Server chat
The code shows off a simple implementation using ENet of a chat using the client-server architecture model. This code doesn't show off multithreaded to keep the focus simple and on enet. You can learn more about multithreading from [love's wiki](https://love2d.org/wiki/love.thread).

The code includes comments - but this document goes into a more high level overview of the code.
# Getting it running
You can run either of the bat files or the shell scripts provided. Run the server before starting any clients. Otherwise you can run any of the `main.lua` within their self-containing folders. 

`main.lua` on the top level is used as a basic switch between client and server to have a single entry point for the code base. Using the argument `-server`, see the bat or shell files to see this in action.
# Server
**NOTE**, this code can be access through the network (E.g. LAN/WAN (web)) if port `12345` is open. You can change this behaviour to run **only** on localhost if you change the address variable within the server's `main.lua` to `localhost` or `127.0.0.1` from the original value of `*`
## How does the sever work?
The server is where the magic of networking starts. First with ENet you must create a host.
```lua
local host = enet.host_create(address..":"..port)
``` 
The above is how the address shall be formatted. The address can be of 4 values.
`*` or `0.0.0.0` allows the server to run open to the network
`localhost` or `127.0.0.1` allows the server to only run on the machine - not accessible from outside that machine. (Do note that localhost's value can be changed on the machine - by default it will direct to 127.0.0.1)

Now that you've created the host, you need to start the server. To start the server you need to run the `:service()` function. If the server starts it will return an event, otherwise it will not return an event. This usually means the port has been taken by another program - and ports cannot be shared.

Lastly we get to the main loop of the server.
```lua
local event = host:service(50) -- 50ms timeout
while event do
  log("Event received. Type: "..event.type..", from:"..tostring(event.client).." containing": "..tostring(event.data))
  event = host:service() -- get next event in queue
end
```
There are 3 types of events, the table below contains what variables are available and their type. You can learn more from [love own wiki](https://love2d.org/wiki/enet.event).
| event.type | event.peer | event.data |
|--|--|--|
| "receive" | peer | string |
| "disconnect" | peer | number |
| "connect" | peer | number |
# Client
The client contains about the same amount of code as the server does - it has a few extra functions to capture and send messages however.

## How does the client work?
It works almost the same as the server, except it doesn't ask for a variable when creating the host - and requires you to call the connect function on the host. Similarly, it doesn't connect to the server until `:service()` is called
```lua
local host = enet.host_create()
local server = host:connect(address..":"..port) -- server is peer object
local event = host:service(5000) -- connection messages sent here
```
Do note that the address to the server will depend which network it is on compared to the client machine.  If running on the same machine then `localhost` will work even if the server uses either `*` or `0.0.0.0`. If the machine is connected on the a different router then you would need to use the public IP, and have port forwarding(NAT) involved on the server's router. If you're running on the same router network then you can use the private IP - but you can use the public IP if the port has been port forwarded (NAT). Sometimes a router is old, and cannot connect to machines within it's own network - then you would need to use public IP with port forwarding. Check out [Cannot connect to server](#Cannot-connect-to-server?) if you're having connection issues.

Once the client has connected to the server the network loop is practically the same as the server's. However, to send a message to the server you have to use the server's peer object created when running the connect function.

In the client example you can see the chat program sending the message within the `love.keypressed` call-back function when `return` is pressed.

# Cannot connect to server?
If you cannot connect to the machine - but can ping it using the ping command in a terminal using the same ip address. Then usually the issue lies with the client or server's firewall blocking the connection. Ensure that love.exe has access through the firewall (If you fuse your game, then that program must also be let through). 
If you're using a private IP that worked one day but doesn't anymore - check that machine still has the same one as router usually refresh the connected devices IPs every 24 hours or so by default.