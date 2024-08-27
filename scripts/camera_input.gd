class_name CameraInput extends Node3D

@export var camera_mount : Node3D
@export var camera_rot : Node3D
@export var camera_3D : Camera3D

const CAMERA_MOUSE_ROTATION_SPEED := 0.001
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)
const CAMERA_UP_DOWN_MOVEMENT = -1

func _ready():
	if multiplayer.get_unique_id() == str(get_parent().name).to_int():
		camera_3D.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		camera_3D.current = false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)

func rotate_camera(move):
	camera_mount.rotate_y(-move.x)
	camera_mount.orthonormalize()
	
	camera_rot.rotation.x = clamp(camera_rot.rotation.x + (CAMERA_UP_DOWN_MOVEMENT * move.y), CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
	
func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis

func get_camera_mount_quaternion() -> Quaternion:
	return camera_mount.global_transform.basis.get_rotation_quaternion()
