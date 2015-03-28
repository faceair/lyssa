zlib = require 'zlib'
iconv = require 'iconv-lite'
chardet = require 'chardet'
charsetParser = require 'charset-parser'
BufferHelper = require 'bufferhelper'

module.exports = (options) ->
  {domain, self_domain} = options

  return (httpRes, callback) ->
    bufferHelper = new BufferHelper
    bufferHelper.load httpRes, (err, buffer) ->
      return callback err if err

      if /text\//i.test httpRes.headers['content-type']
        encoding = httpRes.headers['content-encoding']
        buffer = zlib.gunzipSync buffer if encoding is 'gzip'

        charset = charsetParser(httpRes.headers['content-type']) or chardet.detect(buffer)
        buffer = iconv.encode(iconv.decode(buffer, charset).replace(new RegExp(domain, 'ig'), self_domain), charset)

        buffer = zlib.gzipSync buffer if encoding is 'gzip'

      callback null, buffer