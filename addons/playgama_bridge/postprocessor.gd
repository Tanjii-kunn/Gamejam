extends EditorExportPlugin

const INDEX_FILE_NAME = "index.html"
const TMP_JS_EXPORT_INDEX_FILE_NAME = "tmp_js_export.html"
const JS_SDK_FILE_NAME = "playgama-bridge.js"
const JS_SDK_PATH = "res://addons/playgama_bridge/template/" + JS_SDK_FILE_NAME
const SETTINGS_PATH = "addons/playgama_bridge/general/"
const SETTINGS_GAME_DISTRIBUTION_GAME_ID_KEY = "game_distribution_game_id"
const SETTINGS_Y8_GAME_ID_KEY = "y8_game_id"
const SETTINGS_Y8_CHANNEL_ID_KEY = "y8_channel_id"
const SETTINGS_Y8_ADSENSE_ID_KEY = "y8_adsense_id"
const SETTINGS_LAGGED_DEV_ID_KEY = "lagged_dev_id"
const SETTINGS_LAGGED_PUBLISHER_ID_KEY = "lagged_publisher_id"
const SETTINGS_FACEBOOK_PLACEMENT_ID_KEY = "facebook_placement_id"
const SETTINGS_ADSGRAM_BLOCK_ID_KEY = "adsgram_block_id"

var _path = null

func _get_name() -> String:
	return "Bridge"

func _export_begin(features, is_debug, path, flags):
	if features.has("web"):
		_path = path
		
		var file_from = FileAccess.open(JS_SDK_PATH, FileAccess.READ)
		
		var file_to = FileAccess.open(path.get_base_dir() + "/" + JS_SDK_FILE_NAME, FileAccess.WRITE)
		file_to.store_string(file_from.get_as_text())
		
		file_from = null
		file_to = null

func _export_end():
	if _path == null:
		return
	
	var game_distribution_game_id = ""
	var y8_game_id = ""
	var y8_channel_id = ""
	var y8_adsense_id = ""
	var lagged_dev_id = ""
	var lagged_publisher_id = ""
	var facebook_placement_id = ""
	var adsgram_block_id = ""
	
	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_GAME_DISTRIBUTION_GAME_ID_KEY):
		game_distribution_game_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_GAME_DISTRIBUTION_GAME_ID_KEY)
	
	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_Y8_GAME_ID_KEY):
		y8_game_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_Y8_GAME_ID_KEY)
	
	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_Y8_CHANNEL_ID_KEY):
		y8_channel_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_Y8_CHANNEL_ID_KEY)

	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_Y8_ADSENSE_ID_KEY):
		y8_adsense_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_Y8_ADSENSE_ID_KEY)

	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_LAGGED_DEV_ID_KEY):
		lagged_dev_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_LAGGED_DEV_ID_KEY)

	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_LAGGED_PUBLISHER_ID_KEY):
		lagged_publisher_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_LAGGED_PUBLISHER_ID_KEY)

	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_FACEBOOK_PLACEMENT_ID_KEY):
		facebook_placement_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_FACEBOOK_PLACEMENT_ID_KEY)
	
	if ProjectSettings.has_setting(SETTINGS_PATH + SETTINGS_ADSGRAM_BLOCK_ID_KEY):
		adsgram_block_id = ProjectSettings.get(SETTINGS_PATH + SETTINGS_ADSGRAM_BLOCK_ID_KEY)
	
	var index = FileAccess.open(_path.get_base_dir() + "/" + INDEX_FILE_NAME, FileAccess.READ_WRITE)
	if not index:
		index = FileAccess.open(_path.get_base_dir() + "/" + TMP_JS_EXPORT_INDEX_FILE_NAME, FileAccess.READ_WRITE)
	
	var content = index.get_as_text()
	content = content.format({"game_distribution_game_id":game_distribution_game_id})
	content = content.format({"y8_game_id":y8_game_id})
	content = content.format({"y8_channel_id":y8_channel_id})
	content = content.format({"y8_adsense_id":y8_adsense_id})
	content = content.format({"lagged_dev_id":lagged_dev_id})
	content = content.format({"lagged_publisher_id":lagged_publisher_id})
	content = content.format({"facebook_placement_id":facebook_placement_id})
	content = content.format({"adsgram_block_id":adsgram_block_id})
	
	index.store_string(content)
	index = null
