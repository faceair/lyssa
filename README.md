# lyssa

A simple reverse proxy.

## support

* http
* https
* websocket

## usage

    lyssa = require './lyssa'

    server = lyssa
      target: 'http://lucy.faceair.me'
      forward: 'http://localhost:8000'

    server.listen 8000

## option

`require('lyssa')(option)`

- `option.target` domain of proxy server
- `option.forward` your own domain
- `option.limit` the byte limit of the body, default `1mb`

## todo

* https cert

### License

[MIT](License)
