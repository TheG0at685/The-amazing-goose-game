extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func shake_camera2d(shake_strength: float, shake_duration: float):
	var shake_timer = shake_duration
	var initial_camera_pos = position
	while shake_timer > 0:
		var random_offset = Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))
		position = initial_camera_pos + random_offset
		yield(get_tree(), "idle_frame")
		shake_timer -= get_process_delta_time()
	position = initial_camera_pos
