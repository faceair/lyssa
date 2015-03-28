url = require 'url'
http = require 'http'
https = require 'https'
_ = require 'underscore'

module.exports = (options) ->
  {domain, self_domain} = options
  unless domain and self_domain
    throw new Error 'domain should not be empty.'

  bufferHelper = require('./bufferHelper')(options)

  return (req, res, next) ->
    self_host = url.parse(self_domain).host
    {protocol, host, port, hostname} = url.parse domain

    headers = _.mapObject req.headers, (value) ->
      value.replace self_host, host

    switch protocol
      when 'https:'
        httpLib = https
        port = 443
      else
        httpLib = http

    option =
      hostname: hostname
      port: port or 80
      path: req.url
      method: req.method
      bodyContent: req.bodyContent or null
      headers: headers

    httpReq = httpLib.request option, (httpRes) ->
      bufferHelper httpRes, (err, buffer) ->
        return next err if err

        res.status httpRes.statusCode
        for key, value of httpRes.headers
          if _.isString value
            value = value.replace host, self_host
          res.set key, value

        res.send buffer

    httpReq.on 'error', (err) ->
      next err

    if req.bodyContent
      httpReq.write req.bodyContent

    httpReq.end()
