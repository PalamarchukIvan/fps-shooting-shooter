extends CharacterBody3D

# to be exported and managed externaly
@export var look_speed : float = 0.002
@export var move_speed : float = 10
@export var jump_speed : float = 10

@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"

@export var is_debug_enabled : bool = true

# dependencies
@onready var camera: Camera3D = $Camera3D
@onready var colider: CollisionShape3D = $CollisionShape3D

# properties 
var look_rotation : Vector2
var grav_pow: float = 2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_rotation = Vector2(camera.rotation.y, camera.rotation.x)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # hiding the mouse

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_character(event.relative)

func _physics_process(delta: float) -> void:
	move_character(delta)

func rotate_character(rot_input : Vector2) -> void: 
	look_rotation.x -= rot_input.x * look_speed
	look_rotation.y -= rot_input.y * look_speed
	
	# to avoid "backflipping the camera"
	look_rotation.y = clamp(look_rotation.y, deg_to_rad(-89), deg_to_rad(89))
	
	rotation.y = look_rotation.x  # rotate CharacterBody3D by y-axis > | y  
	camera.rotation.x = look_rotation.y  # rotate Camera by x-axis ^ --- x 
	
func move_character(delta: float) -> void: 
	# movement handling 
	var input_dir_2d := Input.get_vector(
		input_left, input_right, input_forward, input_back
	)
	var input_dir_3d := Vector3(
		input_dir_2d.x, 0.0, input_dir_2d.y 
	)
	var direction = transform.basis * input_dir_3d
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# jump handling 
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_speed
	elif Input.is_action_just_released(input_jump) and velocity.y > 0: 
		velocity.y = 0
		
	# if player is falling => increase grav power
	if velocity.y < 0: 
		grav_pow = 4
	else: 
		grav_pow = 2
		 
	velocity += get_gravity() * grav_pow * delta 
	
	# apply position changes based on velocity 
	move_and_slide()
	
	if (is_debug_enabled):
		print("DEBUG: velocity: ", velocity)
		print("DEBUG: position: ", global_position)
		print("DEBUG: basis: ", basis)
