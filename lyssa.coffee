http = require 'http'
_ = require 'underscore'

application = require './lib/application'
request = require './lib/request'
response = require './lib/response'

middleware = {}
for middleware_name in ['proxy', 'defaultRoute', 'logger']
  middleware[middleware_name] = require './lib/middleware/' + middleware_name

request.__proto__ = http.IncomingMessage.prototype
response.__proto__ = http.ServerResponse.prototype

module.exports = (domain) ->
  app = (req, res, next) ->
    req.__proto__ = request
    res.__proto__ = response
    req.timestamp = _.now()

    app.handle req, res, next

  _.extend app, application

  app.use '/lyssa', (req, res) ->
    res.send 'Hello, I am lyssa.'

  app.use middleware.proxy domain
  app.use middleware.defaultRoute

  return app