http = require 'http'
util = require 'util'

Pluggable = require 'node-pluggable'
_ = require 'underscore'

response = require './response'

module.exports = class Application extends Pluggable
  handle: (req, res) ->
    @run req.url, req, res, (err) =>
      @emit 'error', err, req, res if err
      unless res.finished and res.writable
        res.send 404, "Cannot #{req.method} #{req.url}\n"

    res.on 'finish', =>
      @emit 'after', req, res

  listen: (port, callback) ->
    server = http.createServer (req, res) =>
      _.extend req,
        timestamp: _.now()
      _.extend res, response

      @handle req, res

    server.listen port, =>
      @emit 'start'
      callback() if callback

    server.on 'upgrade', (req, socket, head) =>
      @emit 'upgrade', req, socket, head

    @on 'close', ->
      server.close()
