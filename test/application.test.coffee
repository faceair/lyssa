describe 'application', ->
  lyssa = require '../index'

  describe 'use', ->
    it 'global middleware', (done) ->
      app = lyssa()

      app.use (req, res) ->
        res.end 'response content'

      app.listen 8000

      supertest app
      .get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        app.emit 'close'
        done err


    it 'route middleware ', (done) ->
      app = lyssa()

      app.use '/hello', (req, res) ->
        res.end 'response content'

      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        app.emit 'close'
        done err

    it 'no middleware', (done) ->
      app = lyssa()
      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 404
        res.text.should.be.equal "Cannot GET /hello\n"
        app.emit 'close'
        done err

    it 'next error', (done) ->
      app = lyssa()

      app.use (req, res, next) ->
        next 'next error'

      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 500
        res.text.should.be.equal "Something blew up!"
        app.emit 'close'
        done err

    it 'show logger', (done) ->
      process.env.COV_TEST = 'false'
      app = lyssa()
      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 404
        res.text.should.be.equal "Cannot GET /hello\n"
        app.emit 'close'
        done err

    it 'domain should not be empty', (done) ->
      (->
        lyssa
          limit: '2mb'
      ).should.throw('domain should not be empty.')
      done()

  describe 'response status', ->
    it 'set status', (done) ->
      app = lyssa()

      app.use (req, res, next) ->
        res.status 201
        res.send 'miao'
        next()

      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 201
        res.text.should.be.equal "miao"
        app.emit 'close'
        done err


    it 'send status', (done) ->
      app = lyssa()

      app.use (req, res, next) ->
        res.send 'miao'
        next()

      app.listen 8000

      supertest app
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 200
        res.text.should.be.equal "miao"
        app.emit 'close'
        done err

  describe 'http proxy', ->
    it 'success', (done) ->
      app = lyssa
        target: 'http://www.baidu.com'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest app
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 200
        app.emit 'close'
        done err

    it 'failed', (done) ->
      app = lyssa
        target: 'http://localhost:1234'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest app
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 500
        app.emit 'close'
        done err

  describe 'https proxy', ->
    it 'success', (done) ->
      app = lyssa
        target: 'https://www.baidu.com'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest app
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 200
        app.emit 'close'
        done err

  describe 'websocket proxy', ->
    it 'success', (done) ->
      @timeout 20000

      ws.createServer((conn) ->
        conn.on 'text', (str) ->
          conn.sendText str
      ).listen(80)

      app = lyssa
        target: 'http://127.0.0.1'
        forward: 'http://localhost:8080'
      app.listen 8080

      conn = ws.connect 'ws://localhost:8080', ->
        conn.sendText 'miao'
        conn.on 'text', (str) ->
          str.should.be.equal 'miao'
          done()



