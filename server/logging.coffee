express = require 'express'
fs = require 'fs'

PORT = 3000
METHODS =
	log: console.log.bind console
	info: console.info.bind console
	warn: console.warn.bind console
	error: console.error.bind console
	debug: console.log.bind console # node has no console.debug

app = express.createServer()
app.configure () ->
	app.use express.bodyParser()
	app.use app.router

app.get '/logging.js', (req, res, next) ->
	timeout = req.param 'timeout', '5000'
	timeout = parseInt timeout, 10

	echo = req.param 'echo', 'true'
	echo = echo == 'true'

	replace = req.param 'replace', 'true'
	replace = replace == 'true'

	host = req.header 'Host'

	config_script = "logging.configure({echo: #{echo}, replace: #{replace}, timeout: #{timeout}, url: 'http://#{host}'});"

	fs.readFile __dirname + '/../client/logging.js', 'utf-8', (err, data) ->
		if err
			next err
		else
			res.header 'Content-Type', 'application/x-javascript'
			res.write data
			res.write config_script
			res.end()

app.post '/', (req, res, next) ->
	data = JSON.parse req.param 'data'
	for entry in data.messages
		method = entry.method
		msg = entry.msg
		m = METHODS[method]
		if not m
			return next new Error "Unknown #{method} method"
		else
			m msg

	res.header 'Content-Type', 'text/plain'
	res.header 'Access-Control-Allow-Origin', '*'
	res.end 'OK'

app.listen PORT
console.log "Include http://localhost:#{PORT}/logging.js"
