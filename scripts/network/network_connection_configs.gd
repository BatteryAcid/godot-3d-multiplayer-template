extends Resource
class_name NetworkConnectionConfigs

@export var host_ip: String = ""
@export var host_port: int = -1
@export var game_id: String = ""

func _init(host_ip_: String):
	host_ip = host_ip_
