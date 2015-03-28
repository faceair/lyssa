url = require 'url'
zlib = require 'zlib'
http = require 'http'
https = require 'https'
_ = require 'underscore'
iconv = require 'iconv-lite'
chardet = require 'chardet'
charsetParser = require 'charset-parser'
BufferHelper = require 'bufferhelper'

module.exports = (options) ->
  return (req, res, next) ->
    {domain, self_domain} = options
    unless domain and self_domain
      throw new Error 'domain should not be empty.'

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
      bufferHelper = new BufferHelper
      bufferHelper.load httpRes, (err, buffer) ->
        return next err if err

        res.status httpRes.statusCode
        for key, value of httpRes.headers
          if _.isString value
            value = value.replace host, self_host
          res.set key, value

        if /text\//i.test httpRes.headers['content-type']
          encoding = httpRes.headers['content-encoding']

          buffer = zlib.gunzipSync buffer if encoding is 'gzip'

          charset = charsetParser(httpRes.headers['content-type']) or chardet.detect(buffer)
          buffer = iconv.encode(iconv.decode(buffer, charset).replace(new RegExp(domain, 'ig'), self_domain), charset)

          buffer = zlib.gzipSync buffer if encoding is 'gzip'

        res.send buffer

    httpReq.on 'error', (err) ->
      next err

    if req.bodyContent
      httpReq.write req.bodyContent

    httpReq.end()
