describe 'application', ->
  lyssa = require '../index'

  describe 'use', ->
    it 'global middleware', (done) ->
      app = lyssa()

      app.use (req, res) ->
        res.end 'response content'

      app.listen 8000

      supertest('http://localhost:8000')
      .get '/'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        app.close()
        done err


    it 'route middleware ', (done) ->
      app = lyssa()

      app.use '/hello', (req, res) ->
        res.end 'response content'

      app.listen 8000

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.text.should.be.equal 'response content'
        app.close()
        done err

    it 'no middleware', (done) ->
      app = lyssa()
      app.listen 8000

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 404
        res.text.should.be.equal 'Cannot GET /hello\n'
        app.close()
        done()

    it 'next error', (done) ->
      app = lyssa()

      app.use (req, res, next) ->
        next 'next error'

      app.listen 8000

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 500
        res.text.should.be.equal 'Internal Server Error'
        app.close()
        done()

    it 'show logger', (done) ->
      process.env.COV_TEST = 'false'
      app = lyssa()
      app.listen 8000

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 404
        res.text.should.be.equal 'Cannot GET /hello\n'
        app.close()
        done()

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

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 201
        res.text.should.be.equal 'miao'
        app.close()
        done err


    it 'send status', (done) ->
      app = lyssa()

      app.use (req, res, next) ->
        res.send 'miao'
        next()

      app.listen 8000

      supertest('http://localhost:8000')
      .get '/hello'
      .end (err, res) ->
        res.status.should.be.equal 200
        res.text.should.be.equal 'miao'
        app.close()
        done err

  describe 'http proxy', ->
    it 'success', (done) ->
      app = lyssa
        target: 'http://baike.baidu.com'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest('http://localhost:8000')
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 200
        app.close()
        done err

    it 'failed', (done) ->
      app = lyssa
        target: 'http://localhost:1234'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest('http://localhost:8000')
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 500
        app.close()
        done()

  describe 'https proxy', ->
    it 'success', (done) ->
      app = lyssa
        target: 'https://www.baidu.com'
        forward: 'http://localhost:8000'
      app.listen 8000

      supertest('http://localhost:8000')
      .get '/'
      .end (err, res) ->
        res.status.should.be.equal 200
        app.close()
        done err

  describe 'websocket proxy', ->
    it 'success', (done) ->
      @timeout 20000

      ws.createServer((conn) ->
        conn.on 'text', (str) ->
          conn.sendText str
      ).listen(8001)

      app = lyssa
        target: 'ws://127.0.0.1:8001'
        forward: 'http://localhost:8080'
      app.listen 8080

      conn = ws.connect 'ws://localhost:8080', ->
        conn.sendText 'miao'
        conn.on 'text', (str) ->
          str.should.be.equal 'miao'
          done()
