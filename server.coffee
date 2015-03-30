lyssa = require './lyssa'

server = lyssa
  target: 'http://lucy.faceair.me'
  forward: 'http://localhost:8000'

server.listen 8000