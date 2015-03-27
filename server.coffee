lyssa = require './lyssa'

server = lyssa
  domain: 'http://www.guanggoo.com'
  self_domain: 'http://localhost:8000'

server.listen 8000