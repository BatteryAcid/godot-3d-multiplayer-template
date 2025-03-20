extends Node

@export var active_host_label: RichTextLabel
@export var game_id_label: RichTextLabel

func _ready() -> void:
	self.visible = false

func show():

	active_host_label.text = NetworkManager.active_host_ip
	game_id_label.text = NetworkManager.active_game_id
	
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide():
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("in-game-menu"):
		if (self.visible):
			hide()
		else:
			show()

func _on_resume_pressed() -> void:
	hide()
	
func _on_main_menu_pressed():
	NetworkManager.disconnect_from_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_copy_ip_pressed():
	DisplayServer.clipboard_set(NetworkManager.active_host_ip)

func _on_copy_game_id_pressed():
	DisplayServer.clipboard_set(NetworkManager.active_game_id)
