_ = require 'underscore'

module.exports = (options) ->
  return (req, res, next) ->
    bufferHelper = require('./lib/bufferHelper')(options)
    proxyConf = require('./lib/proxyConf')(options)

    proxyConf req, (httpLib, httpConf, {host, self_host}) ->
      httpReq = httpLib.request httpConf, (httpRes) ->
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
