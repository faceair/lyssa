util = require 'util'
http = require 'http'
_ = require 'underscore'

application = require './lib/application'
request = require './lib/request'
response = require './lib/response'

request.__proto__ = http.IncomingMessage.prototype
response.__proto__ = http.ServerResponse.prototype

module.exports = ->
  app = (req, res, next) ->
    req.__proto__ = request
    res.__proto__ = response
    req.timestamp = _.now()

    app.handle req, res, next

  _.extend app, application

  app.on 'start', ->
    console.info "lyssa is runing ..."

  app.on 'error', (err, req, res) ->
    res.send 500, 'Something blew up!'
    console.error err.stack or err.toString()

  app.on 'after', (req, res) ->
    console.info "#{req.method} #{req.url} #{res.statusCode} #{_.now() - req.timestamp}ms"

  app