_ = require 'underscore'

module.exports = (req, res) ->
  time = _.now() - req.timestamp
  size = res._headers['content-length'] ? 0
  console.info "#{req.method} #{req.url} #{res.statusCode} #{time}ms - #{size}"