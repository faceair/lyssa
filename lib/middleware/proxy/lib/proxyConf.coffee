url = require 'url'
http = require 'http'
https = require 'https'
_ = require 'underscore'

module.exports = (options) ->
  {target, forward} = options

  return (req, callback) ->
    self_host = url.parse(forward).host
    {protocol, host, port, hostname} = url.parse target

    headers = _.mapObject req.headers, (value, key) ->
      if key is 'host'
        host
      else
        value.replace self_host, host

    switch protocol
      when 'https:' or 'wss:'
        httpLib = https
        port = 443
      else
        httpLib = http

    callback httpLib, {
      hostname: hostname
      port: port or 80
      path: req.url
      method: req.method
      bodyContent: req.bodyContent or null
      headers: headers
    }, {
      host: host
      self_host: self_host
    }
