lyssa = require './lyssa'

app = lyssa
  target: 'http://www.baidu.com'
  forward: 'http://localhost:8000'
app.listen 8000
