extends KinematicBody2D


# Movment vars
var velocity = Vector2()
var MAX_SPEED = Vector2(500, 1000)
var speed = 50

const GRAVITY_MUILTIPLYER = 15
var gravity = 0
var facing = "right"

var state = "default"

# jump vars
var max_jump_strength = -700
var jump_count = 0
var max_jump_count = 1
var jump_strength = 0

# God mode vars
var god_mode_active = false
var god_speed = 400

# gun variables
const GUN_STRENGTH = 1000
# How many frames gun jump will stay active for after activating
const MAX_GUN_LENGTH = 30
var jump_power = 0
var MAX_SHOTS = 1
var ammo = 0
var gun_jumping = false
var gun_jump_direction = Vector2()
var start_with_gun = true
var has_gun = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(rad2deg(Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3)).angle()))
	apply_gravity()
	jump()
	animations()
	movment()
	god_mode()
	change_level()
	clamp_motion()
	die()
	
	# This function needs to be at the end of other function calls
	if has_gun:
		gun()
	else:
		# I have no clue why I need to do this but the gun sprite gets messed up otherwise
		if start_with_gun:
			has_gun = true
	move_and_slide(velocity, Vector2(0, -1))
	velocity.y = 0

func apply_gravity():
	# Apply gravity only when not on floor. Otherwise set gravity to 0
	# Change max speed based on if we are in the air or on the ground
	velocity.y += gravity
	clamp_motion()
	if not is_on_floor():
		gravity += GRAVITY_MUILTIPLYER
		MAX_SPEED.x = 400
	else:
		# Shake the camera after a high fall
		if velocity.y > 2000:
			$Camera2D.shake_camera2d(1000.0, 0.1)
		gravity = 0
		ammo = MAX_SHOTS
		MAX_SPEED.x = 500
		jump_count = max_jump_count
		velocity.y = 1


func movment():
	if Input.is_action_pressed("left"):
		left()
	elif Input.is_action_pressed("right"):
		right()
	else:
		slow_momentum()
	if (not Input.is_action_pressed("right") and not Input.is_action_pressed("left")) or not is_on_floor():
		state = "default"
	elif is_on_floor():
		state = "walking"
		
	if is_on_ceiling():
		velocity.y = 1
		gravity = 1
		

	
		
func left():
	facing = "left"
	if velocity.x > -MAX_SPEED.x:
		velocity.x -= speed
	
func right():
	facing = "right"
	if velocity.x < MAX_SPEED.x:
		velocity.x += speed
	
func slow_momentum(stop_speed=10):
	# Reduce momentum until it reaches 0.
	if velocity.x in range(-stop_speed, stop_speed):
		velocity.x = 0
	elif velocity.x > 0:
		velocity.x -= stop_speed
	elif velocity.x < 0:
		velocity.x += stop_speed

func jump():
	if not gun_jumping:
		if Input.is_action_just_pressed("jump") and jump_count > 0:
			jump_count -= 1
			jump_strength = max_jump_strength
		# Check if we are currently jumping
		
		if jump_count < max_jump_count:
			velocity.y += jump_strength
			if jump_strength < 0:
				jump_strength += 1
		# Stop the jump if we release the jump key
		if not Input.is_action_pressed("jump") and velocity.y < 0: # only stop the jump if we are still going up
			jump_strength = 0
			gravity = 0
	
		
func animations():
	# Play animations
	if state == "walking":
		$AnimatedSprite.play("walk")
	elif state == "default":
		$AnimatedSprite.play("default")
	elif state == "wall slide":
		$AnimatedSprite.play("wall slide")
	# Flip the sprite
	if facing == "right":
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
		
	# adjust the Gun sprite
	# This might be some of the worst code I've ever written so I just hide it in this "if true"
	# it's ugly but it works so please don't touch it
	if true:
		if has_gun:
			$"Gun rotation point/AnimatedSprite".animation = "gun"
		else:
			$"Gun rotation point/AnimatedSprite".animation = "hand"
		if not $AnimatedSprite.flip_h:
			$"Gun rotation point".position = Vector2(52, 0)
			if not has_gun:
				$"Gun rotation point/AnimatedSprite".scale.x = 1
				$"Gun rotation point/AnimatedSprite".position = Vector2(32, 0)
				$"Gun rotation point/AnimatedSprite".flip_v = false
				$"Gun rotation point/AnimatedSprite".flip_h = false
				$"Gun rotation point/AnimatedSprite".scale.x = 1
				$"Gun rotation point/AnimatedSprite".scale.y = 1
			else:
				$"Gun rotation point/AnimatedSprite".scale.x = 1
				$"Gun rotation point/AnimatedSprite".scale.y = 1
				$"Gun rotation point/AnimatedSprite".position = Vector2(0, -36)
				$"Gun rotation point/AnimatedSprite".flip_v = false
		else: 
			$"Gun rotation point".position = Vector2(-52, 0)
			if not has_gun:
				$"Gun rotation point/AnimatedSprite".position = Vector2(32, 0)
				$"Gun rotation point/AnimatedSprite".flip_v = true
				$"Gun rotation point/AnimatedSprite".flip_h = false
				$"Gun rotation point/AnimatedSprite".scale.x = 1
				$"Gun rotation point/AnimatedSprite".scale.y = 1
			else:
				$"Gun rotation point/AnimatedSprite".scale.x = 1
				$"Gun rotation point/AnimatedSprite".scale.y = -1
				$"Gun rotation point/AnimatedSprite".position = Vector2(0, 36)
		if "Xbox One Controller" == Input.get_joy_name(0):
			$"Gun rotation point".rotation_degrees = rad2deg(Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3)).angle())
		else:
			$"Gun rotation point".look_at(get_global_mouse_position())
	
func god_mode():
	if Input.is_action_just_pressed("god_mode"):
		if not god_mode_active:
			god_mode_active = true
		else:
			god_mode_active = false
	if god_mode_active:
		has_gun = true
		velocity.x = Input.get_axis("left", "right") * god_speed
		velocity.y = Input.get_axis("jump", "down") * god_speed
		gravity = 0
		ammo = 100

		
func clamp_motion():
	# Make sure that speed limits aren't broken
	if velocity.x < -MAX_SPEED.x:
		velocity.x += speed/5
	if velocity.x > MAX_SPEED.x:
		velocity.x -= speed/5
	if velocity.x < -MAX_SPEED.y:
		velocity.x = -MAX_SPEED.y
	if velocity.x > MAX_SPEED.y:
		velocity.x = MAX_SPEED.y


func gun():
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		ammo -= 1
		gun_jump_direction = get_mouse_direction(position)
		jump_power = MAX_GUN_LENGTH
		gun_jumping = true
		# Create a bullet
		var bullet = load("res://bullet.tscn").instance()
		get_parent().add_child(bullet)
		bullet.position = position
		bullet.rotation = $"Gun rotation point".rotation
		
	if gun_jumping:
		jump_power -= 1
		velocity = -gun_jump_direction * GUN_STRENGTH
		gravity = 0
		if jump_power < 1:
			gun_jumping = false
			gravity = velocity.y
		jump_strength = 0

			
			
	
	
func get_mouse_direction(player_pos: Vector2) -> Vector2:
	if not "Xbox One Controller" == Input.get_joy_name(0):
		var mouse_pos = get_global_mouse_position()
		var delta = mouse_pos - player_pos
		var direction = delta.normalized()
		return direction
	else:
		var direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3)).normalized()
		return direction

func change_level():
	# Cycle through level portals
	for portal in get_tree().get_nodes_in_group("level portals"):
		# if we're touching a portal generate a new level and change player position based on the portals "level_trans_data"
		if portal.overlaps_body(self):
			get_parent().generate_level(portal.level_trans_data["level"])
			velocity = Vector2()
			position = portal.level_trans_data["position"]

func die():
	# All the ways we can die. Yay!
	for danger in get_tree().get_nodes_in_group("dangers"):
		if $Collision.overlaps_body(danger):
			get_parent().generate_level(get_parent().current_level)
			velocity = Vector2()
			position = Vector2()
