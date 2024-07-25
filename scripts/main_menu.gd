extends Control

const GAME_SCENE = "res://scenes/game.tscn"

func ready():
	if OS.has_feature("dedicated_server"):
		print("Calling host game...")
		NetworkManager.host_game()
		get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func host_game():
	print("Host game pressed")
	NetworkManager.host_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
func join_game():
	print("Join game pressed")
	NetworkManager.join_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
func exit_game():
	get_tree().quit(0)
