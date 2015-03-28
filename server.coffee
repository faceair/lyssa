lyssa = require './lyssa'

server_1 = lyssa
  target: 'http://www.guanggoo.com'
  forward: 'http://localhost:8000'
server_1.listen 8000

server_2 = lyssa
  target: 'https://www.v2ex.com/'
  forward: 'http://localhost:9000'
server_2.listen 9000