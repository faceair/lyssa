lyssa = require './lyssa'

server = lyssa
  domain: 'http://lucy.faceair.me'
  self_domain: 'http://localhost:8000'

server.listen 8000