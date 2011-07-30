express = require 'express'
fs = require 'fs'

PORT = 3000

app = express.createServer()
app.configure () ->
	app.use express.bodyParser()
	app.use app.router

app.get '/logging.js', (req, res, next) ->
	host = req.header 'Host'
	fs.readFile __dirname + '/../client/logging.js', 'utf-8', (err, data) ->
		if err
			next err
		else
			res.header 'Content-Type', 'application/x-javascript'
			data = data.replace 'SELF_URL', "http://#{host}"
			res.send data
	res.send 
app.post '/', (req, res, next) ->
	msg = req.param 'msg'
	console.log msg
	res.header 'Access-Control-Allow-Origin', '*'
	res.send 'OK'

app.listen PORT
console.log "Include http://localhost:#{PORT}/logging.js"
