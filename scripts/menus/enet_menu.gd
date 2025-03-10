extends Control

@export var go_button: Button
@export var back_button: Button
@export var host_ip_input: LineEdit # Defaults to "127.0.0.1" (localhost)
@export var host_port_input: LineEdit # Defaults to "8080"
@export var option_label: RichTextLabel

signal secondary_menu_completed
signal secondary_menu_cancelled

func _on_go_pressed():
	print("On Go pressed")
	if host_ip_input.text && host_ip_input.text != "" && host_port_input.text && host_port_input.text != "":
		
		var network_connection_configs = NetworkConnectionConfigs.new(host_ip_input.text)
		network_connection_configs.host_port = host_port_input.text.to_int()
		
		secondary_menu_completed.emit(network_connection_configs)

func _on_back_pressed():
	print("On Back pressed")
	secondary_menu_cancelled.emit()
