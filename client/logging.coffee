@logging = (() ->

	merge = (defaults, custom) ->
		# merges two (flat) objects, returns a new one
		result = Object.create defaults
		for own k, v of custom
			result[k] = v
		result

	LEVELS =
		NOTSET: 0
		DEBUG: 10
		INFO: 20
		WARN: 30
		WARNING: 30
		ERROR: 40
		FATAL: 50
		CRITICAL: 50

	class Logger
		constructor: (@name) ->
		log: (level, msg) ->
			if LEVELS[level] >= config.level
				formatted = config.formatter @name, level, msg
				config.handler.emit formatted
		debug: (msg) ->
			@log 'DEBUG', msg
		info: (msg) ->
			@log 'INFO', msg
		warn: (msg) ->
			@log 'WARN', msg
		error: (msg) ->
			@log 'ERROR', msg

	class ConsoleHandler
		emit: (msg) ->
			console.log msg

	class AJAXHandler
		constructor: (@url, @timeout=5000, @echo=false) ->
			@buffer = []
			@init()
		emit: (msg) ->
			@buffer.push msg
			console.log msg if @echo
		init: () ->
			@bound_push = @push.bind this
			setTimeout @bound_push, @timeout
		push: () ->
			bound_push = @bound_push
			timeout = @timeout
			if not @buffer.length
				setTimeout bound_push, timeout
				return
			req = new XMLHttpRequest
			req.onreadystatechange = () ->
				if req.readyState == 4
					if req.status == 200
						setTimeout bound_push, timeout
					else
						throw new Error req.status
			req.open 'POST', @url, true
			req.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
			req.send 'msg=' + encodeURIComponent @buffer.join '\n'
			@buffer = []

	DEFAULT_LOGGER_CONFIG =
		formatter: (name, severity, msg) -> "#{new Date} [#{severity}] [#{name}] #{msg}"
		handler: new AJAXHandler('SELF_URL', 5000, false)
		#handler: new ConsoleHandler
		level: LEVELS.NOTSET

	config = DEFAULT_LOGGER_CONFIG
	rootLogger = new Logger ''
	root_debug = rootLogger.debug.bind rootLogger
	root_info = rootLogger.info.bind rootLogger
	root_warn = rootLogger.warn.bind rootLogger
	root_error = rootLogger.error.bind rootLogger

	attach = () ->
		console.log = root_info
		console.debug = root_debug

	loggers =
		'': rootLogger

	logging = merge LEVELS,
		basicConfig: (custom_config) ->
			config = merge config, custom_config
		getLogger: (name='') ->
			loggers[name] = new Logger name if not loggers.hasOwnProperty name
			loggers[name]
		debug: root_debug
		info: root_info
		warn: root_warn
		error: root_error
		ConsoleHandler: ConsoleHandler
		AJAXHandler: AJAXHandler
		attach: attach
)()
