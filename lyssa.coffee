util = require 'util'
http = require 'http'
_ = require 'underscore'

application = require './lib/application'
response = require './lib/response'

proxy = require './lib/middleware/proxy/index'
rawBody = require './lib/middleware/rawBody'

request =
  __proto__: http.IncomingMessage.prototype
response.__proto__ = http.ServerResponse.prototype

module.exports = (options) ->
  app = (req, res, next) ->
    req.__proto__ = request
    res.__proto__ = response
    req.timestamp = _.now()

    app.handle req, res, next

  _.extend app, application()

  if options and options.limit
    limit = options.limit
  else
    limit = '1mb'
  app.use rawBody limit

  proxy app, options

  app.use (req, res) ->
    unless res.finished and res.writable
      res.send 404, "Cannot #{req.method} #{req.url}\n"

  app.on 'start', ->
    console.log "lyssa is runing ..."

  app.on 'error', (err, req, res) ->
    res.send 500, 'Something blew up!' if res
    console.error err.stack or err.toString()

  app.on 'after', (req, res) ->
    console.log "#{req.method} #{req.url} #{res.statusCode} #{_.now() - req.timestamp}ms"

  app