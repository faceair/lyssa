lyssa = require './lyssa'
proxy = require './lib/middleware/proxy'

server = lyssa()

server.use '/toutiao', proxy 'http://toutiao.io'

server.listen 8000