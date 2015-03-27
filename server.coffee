lyssa = require './lyssa'

server = lyssa
  domain: 'http://www.w3school.com.cn'
  charset: 'gbk'
  self_domain: 'http://localhost:8000'

server.listen 8000