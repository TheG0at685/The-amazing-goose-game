extends KinematicBody2D


var speed = 500
var velocity = Vector2()
var kill_distance = 5000
onready var player = get_tree().current_scene.get_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.distance_to(player.position) > kill_distance:
		queue_free()
	velocity += transform.x * speed
	move_and_slide(velocity)


func _on_Area2D_body_entered(body):
	if not body == player:
		queue_free()
