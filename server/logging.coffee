express = require 'express'

PORT = 3000

app = express.createServer()
app.configure () ->
	app.use express.static __dirname + '/../client'
	app.use express.bodyParser()
	app.use app.router

app.post '/', (req, res, next) ->
	msg = req.param 'msg'
	console.log msg
	res.header 'Access-Control-Allow-Origin', '*'
	res.send 'OK'

app.listen PORT
console.log "Include http://localhost:#{PORT}/logging.js"
