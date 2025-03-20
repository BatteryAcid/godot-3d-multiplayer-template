extends Control

signal secondary_menu_completed
signal secondary_menu_cancelled

const NORAY_CLIENT_PLACEHOLDER_TEXT = "Enter Host's Game ID"
const NORAY_HOSTING_LABEL = "Host Game with Noray!"
const NORAY_CLIENT_CONNECT_LABEL = "Connect to game on Noray!"

@export var go_button: Button
@export var back_button: Button
@export var host_ip_input: LineEdit
@export var host_gameid_input: LineEdit
@export var option_label: RichTextLabel

var menu_config_options: Dictionary = {}
var _is_hosting: bool = false

func _ready():
	host_gameid_input.placeholder_text = NORAY_CLIENT_PLACEHOLDER_TEXT
	host_gameid_input.text = ""

	if menu_config_options.has("is_hosting") && menu_config_options.get("is_hosting") == true:
		_is_hosting = true

	if _is_hosting:
		option_label.text = NORAY_HOSTING_LABEL
		host_gameid_input.visible = false
	else:
		option_label.text = NORAY_CLIENT_CONNECT_LABEL
		host_gameid_input.visible = true

func _on_go_pressed():
	print("On Noray go presssed")
	if _is_hosting:
		# Noray Host IP is required to host game
		if host_ip_input.text && host_ip_input.text != "":
			var network_connection_configs = NetworkConnectionConfigs.new(host_ip_input.text)
			secondary_menu_completed.emit(network_connection_configs)
	else:
		# Host IP AND Game ID required to join Noray as client
		if host_ip_input.text && host_ip_input.text != "" && host_gameid_input.text && host_gameid_input.text != "":
			var network_connection_configs = NetworkConnectionConfigs.new(host_ip_input.text)
			network_connection_configs.game_id = host_gameid_input.text
			secondary_menu_completed.emit(network_connection_configs)

func _on_back_pressed():
	print("On back pressed")
	secondary_menu_cancelled.emit()
