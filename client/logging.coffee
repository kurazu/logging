METHODS = ['log', 'info', 'warn', 'error', 'debug']

orig_console = {}
for method in METHODS
	orig_console[method] = console[method]

merge = (base, overrides) ->
	result = Object.create base
	for own key, value of overrides
		result[key] = value
	result

logging =
	config:
		url: 'http://localhost:3000'
		timeout: 5000
		echo: true
		replace: false
	configure: (settings) ->
		@config = merge @config, settings
		@replace() if @config.replace
		@init()
	buffer: []
	init: () ->
		setTimeout @push.bind(this), @config.timeout
	replace: () ->
		for method in METHODS
			console[method] = this[method].bind this
		undefined
	emit: (method, args) ->
		@buffer.push method: method, msg: Array.prototype.join.call args
		orig_console[method].apply console, args if @config.echo
	push: () ->
		if not @buffer.length
			setTimeout @push.bind this, @config.timeout
			return
		self = this
		req = new XMLHttpRequest
		req.onreadystatechange = () ->
			if req.readyState == 4
				if req.status == 200
					setTimeout self.push.bind(self), self.config.timeout
				else
					throw new Error req.status
		req.open 'POST', @config.url, true
		req.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
		data =
			messages: @buffer
			timestamp: +new Date
		json = JSON.stringify data
		req.send 'data=' + encodeURIComponent json
		@buffer = []

for method in METHODS
	logging[method] = () ->
		@emit method, arguments

multibind = (obj, methods...) ->
	result = {}
	for method in methods
		result[method] = obj[method].bind obj
	result

@logging = multibind logging, METHODS..., 'configure'
