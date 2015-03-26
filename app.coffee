lyssa = require './lyssa'

server = lyssa()

server.use '/i', (req, res) ->
  res.send 'i'

server.listen 8000
