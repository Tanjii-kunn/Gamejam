@tool
extends EditorPlugin

const SINGLETON_NAME = "Bridge"
const SINGLETON_PATH = "res://addons/playgama_bridge/bridge.gd"
const POSTPROCESSOR_PLUGIN_PATH = "res://addons/playgama_bridge/postprocessor.gd"
const SETTINGS_PATH = "addons/playgama_bridge/general/"
const SETTINGS_GAME_DISTRIBUTION_GAME_ID_KEY = "game_distribution_game_id"
const SETTINGS_Y8_GAME_ID_KEY = "y8_game_id"
const SETTINGS_Y8_CHANNEL_ID_KEY = "y8_channel_id"
const SETTINGS_Y8_ADSENSE_ID_KEY = "y8_adsense_id"
const SETTINGS_LAGGED_DEV_ID_KEY = "lagged_dev_id"
const SETTINGS_LAGGED_PUBLISHER_ID_KEY = "lagged_publisher_id"
const SETTINGS_FACEBOOK_PLACEMENT_ID_KEY = "facebook_placement_id"
const SETTINGS_ADSGRAM_BLOCK_ID_KEY = "adsgram_block_id"

func _enter_tree():
	_add_project_settings(SETTINGS_PATH + SETTINGS_GAME_DISTRIBUTION_GAME_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_Y8_GAME_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_Y8_CHANNEL_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_Y8_ADSENSE_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_LAGGED_DEV_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_LAGGED_PUBLISHER_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_FACEBOOK_PLACEMENT_ID_KEY, TYPE_STRING, "")
	_add_project_settings(SETTINGS_PATH + SETTINGS_ADSGRAM_BLOCK_ID_KEY, TYPE_STRING, "")
	add_autoload_singleton(SINGLETON_NAME, SINGLETON_PATH)
	add_export_plugin(load(POSTPROCESSOR_PLUGIN_PATH).new())

func _exit_tree():
	remove_autoload_singleton(SINGLETON_NAME)

func _add_project_settings(name, type, default_value, hint = PROPERTY_HINT_NONE, hint_string = ""):
	if ProjectSettings.has_setting(name): 
		return
	
	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info({
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	})
