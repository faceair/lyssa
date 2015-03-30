http = require 'http'
util = require 'util'
Pluggable = require 'node-pluggable'

module.exports = ->
  pluggable = new Pluggable()

  return {
    use: pluggable.use
    on: pluggable.bind
    emit: pluggable.emit

    handle: (req, res) ->
      pluggable.run req.url, req, res, (err) ->
        pluggable.emit 'error', err, req, res if err
        unless res.finished and res.writable
          res.send 404, "Cannot #{req.method} #{req.url}\n"

      res.on 'finish', ->
        pluggable.emit 'after', req, res

    listen: (port, callback) ->
      server = http.createServer @
      server.listen.apply server, [port,
        ->
          pluggable.emit 'start'
          callback() if callback
      ]
      server.on 'upgrade', (req, socket, head) ->
        pluggable.emit 'upgrade', req, socket, head
  }