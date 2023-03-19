extends CharacterBody3D

# Speed in m/s
@export var speed = 3
# Add speed limit
@export var speed_cap = Vector3(65, 25, 65)
# Friction
@export var friction = 0.06
@export var air_friction = 0.03
@export var friction_threshold = 0.01
# Gravity
@export var fall_acceleration = 55
# Jumping velocity
@export var jump_impulse = 22
# Support for multi jumps
@export var jump_count = 2
# Support for wall jumps
@export var wall_touched = false
# Support for power swapping
var power_choice = "fire"

var target_velocity = Vector3.ZERO

@onready var camera = $CameraOrbit

func _physics_process(delta):
	# Store input direction
	var direction = Vector3()
	var d_button_pressed = false
	
	# Check for power change
	if Input.is_action_pressed("power_1"):
		power_choice = "fire"
	if Input.is_action_pressed("power_2"):
		power_choice = "ice"
	if Input.is_action_pressed("power_3"):
		power_choice = "web"
	if Input.is_action_pressed("power_4"):
		power_choice = "slime"
		
	match power_choice:
		"fire":
			print("fire")
		"ice":
			print("ice")
		"web":
			print("web")
		"slime":
			print("slime")
	
	# Check for movement input
	if Input.is_action_pressed("move_right"):
		direction.x -= 1
		d_button_pressed = true
	if Input.is_action_pressed("move_left"):
		direction.x += 1
		d_button_pressed = true
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
		d_button_pressed = true
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		d_button_pressed = true
	if Input.is_action_pressed("rizz"):
		direction.y += -0.5
	

	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
	
	var facing = (transform.basis.x * direction.x + transform.basis.z * direction.z)
	
	# Check to see if horizontal movement button is pressed
	if (d_button_pressed): 
		# Check to see if velocity is under speed cap
		if (abs(target_velocity.x) != 0 and abs(target_velocity.x) > speed_cap.x
		and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))):
			# Set velocity to speed cap if it's over
			if (target_velocity.x > 0):
				target_velocity.x = speed_cap.x
			if (target_velocity.x < 0):
				target_velocity.x = -speed_cap.x
		elif (abs(target_velocity.x) < speed_cap.x):
			target_velocity.x += facing.x * (speed)
		
		if (abs(target_velocity.z) != 0 and abs(target_velocity.z) > speed_cap.z 
		and (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back"))):
			# Set velocity to speed cap if it's over
			if (target_velocity.z > 0):
				target_velocity.z = speed_cap.z
			if (target_velocity.z < 0):
				target_velocity.z = -speed_cap.z
		elif (abs(target_velocity.z) < speed_cap.z):
			target_velocity.z += facing.z * (speed)
			
	
	# Apply friction if on the ground, not pressing a horizontal movement key
	if (is_on_floor() and ((target_velocity.x != 0) or (target_velocity.z != 0))):
		if (target_velocity.x > friction_threshold or target_velocity.x < -friction_threshold):
			target_velocity.x -= target_velocity.x * friction
		else:
			target_velocity.x = 0
		if (target_velocity.z > friction_threshold or target_velocity.z < -friction_threshold):
			target_velocity.z -= target_velocity.z * friction
		else:
			target_velocity.z = 0
	elif (not is_on_floor() and ((target_velocity.x != 0) or (target_velocity.z != 0))):
		if (target_velocity.x > friction_threshold or target_velocity.x < -friction_threshold):
			target_velocity.x -= target_velocity.x * air_friction
		else:
			target_velocity.x = 0
		if (target_velocity.z > friction_threshold or target_velocity.z < -friction_threshold):
			target_velocity.z -= target_velocity.z * air_friction
		else:
			target_velocity.z = 0
	
	if(target_velocity == Vector3.ZERO):
		direction = Vector3.ZERO
	
	# Jump handler
	if is_on_floor():
		jump_count = 2
		
	if is_on_wall():
		wall_touched = true
		
	if (not is_on_wall() and wall_touched == true):
		jump_count += 1
		wall_touched = false
	
	if jump_count > 0 and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse 
		jump_count -= 1
	
		
	if is_on_wall_only() and Input.is_action_pressed("jump"):
		var wall_direction = get_wall_normal()
		target_velocity.y = target_velocity.y - ((fall_acceleration / 2.0) * delta)
		
		if wall_direction.x != 0:
			target_velocity.x = 0
		if wall_direction.z != 0:
			target_velocity.z = 0
		
		
	elif not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	elif (is_on_floor() and not Input.is_action_pressed("jump")):
		target_velocity.y = 0
	
		
	velocity = target_velocity
	move_and_slide()
