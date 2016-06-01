#
# # SimpleServer
#
# A simple chat server using Socket.IO, Express, and Async.
#
http = require('http')
path = require('path')

async = require('async')
socketio = require('socket.io')
express = require('express')

#
# ## SimpleServer `SimpleServer(obj)`
#
# Creates a new instance of SimpleServer with the following options:
#  * `port` - The HTTP port to listen on. If `process.env.PORT` is set, _it overrides this value_.
#
router = express()
server = http.createServer(router)
io = socketio.listen(server)

router.use(express.static(path.resolve(__dirname, 'client')))
messages = []
sockets = []

updateRoster = () ->
  async.map sockets, 
    (socket, callback) ->
      socket.get('name', callback)
    ,
    (err, names) ->
      broadcast('roster', names)

broadcast = (event, data) ->
  sockets.forEach (socket) ->
    socket.emit(event, data)


io.on 'connection', (socket) ->
    messages.forEach (data) ->
      socket.emit('message', data)
    sockets.push(socket)
    socket.on 'disconnect', () ->
      sockets.splice(sockets.indexOf(socket), 1)
      updateRoster()
    socket.on 'message', (msg) ->
      text = String(msg || '')
      return if (!text)
      socket.get 'name', (err, name) ->
        data = {
          name: name,
          text: text
        }
        broadcast('message', data)
        messages.push(data)
    socket.on 'identify', (name) ->
      socket.set 'name', String(name || 'Anonymous'), (err) ->
        updateRoster()



server.listen process.env.PORT || 3000, process.env.IP || "0.0.0.0", () ->
  addr = server.address()
  console.log("Chat server listening at", addr.address + ":" + addr.port)
