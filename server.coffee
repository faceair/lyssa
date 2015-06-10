lyssa = require './lyssa'

app = lyssa
  target: 'http://lucy.faceair.me'
  forward: 'http://localhost:8000'

app.listen 8000
