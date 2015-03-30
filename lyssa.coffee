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

  app.use rawBody options?.limit or '1mb'

  proxy app, options if options

  app.on 'start', ->
    unless process.env.COV_TEST is 'true'
      console.log "lyssa is runing ..."

  app.on 'error', (err, req, res) ->
    res.send 500, 'Something blew up!' if res
    unless process.env.COV_TEST is 'true'
      console.error err.stack or err.toString()

  app.on 'after', (req, res) ->
    unless process.env.COV_TEST is 'true'
      console.log "#{req.method} #{req.url} #{res.statusCode} #{_.now() - req.timestamp}ms"

  app