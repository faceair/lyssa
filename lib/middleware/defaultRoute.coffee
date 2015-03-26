module.exports = (req, res, next) ->
  unless res.finished and res.writable
    res.statusCode = 404
    res.header 'Content-Type', 'text/html; charset=utf-8'
    res.end "Cannot #{req.method} #{req.url}\n"
  next()