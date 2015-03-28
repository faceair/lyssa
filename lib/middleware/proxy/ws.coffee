module.exports = (req, socket, head) ->
  socket.write 'HTTP/1.1 101 Web Socket Protocol Handshake\n' + 'Upgrade: WebSocket\n' + 'Connection: Upgrade\n' + '\n'
  socket.pipe socket