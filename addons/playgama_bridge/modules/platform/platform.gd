var id : get = _id_getter
var payload : get = _payload_getter
var language : get = _language_getter
var tld : get = _tld_getter


var _js_platform = null
var _get_server_time_callback = null
var _js_get_server_time_then = JavaScriptBridge.create_callback(self._on_js_get_server_time_then)
var _js_get_server_time_catch = JavaScriptBridge.create_callback(self._on_js_get_server_time_catch)

func _id_getter():
	return _js_platform.id

func _payload_getter():
	return _js_platform.payload

func _language_getter():
	return _js_platform.language

func _tld_getter():
	return _js_platform.tld
	
func _init(js_platform):
	_js_platform = js_platform


func send_message(message):
	_js_platform.sendMessage(message)

func get_server_time(callback):
	if _get_server_time_callback != null:
		return
	
	_get_server_time_callback = callback
	_js_platform.getServerTime().then(_js_get_server_time_then).catch(_js_get_server_time_catch)


func _on_js_get_server_time_then(args):
	if _get_server_time_callback != null:
		var data = args[0]
		var data_type = typeof(data)
		match data_type:
			TYPE_INT:
				_get_server_time_callback.call(data)
			_:
				_get_server_time_callback.call(0)
		_get_server_time_callback = null

func _on_js_get_server_time_catch(args):
	if _get_server_time_callback != null:
		_get_server_time_callback.call(0)
		_get_server_time_callback = null
