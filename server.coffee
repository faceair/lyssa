lyssa = require './lyssa'

server = lyssa
  target: 'http://echo.websocket.org'
  forward: 'http://localhost'

server.listen 80
