lyssa = require './lyssa'

server = lyssa
  domain: 'https://www.v2ex.com'
  self_domain: 'http://localhost:8000'

server.listen 8000