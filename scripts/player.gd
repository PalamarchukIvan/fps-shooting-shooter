extends CharacterBody3D

# to be exported and managed externaly
@export var look_speed : float = 0.002
@export var move_speed : float = 10
@export var jump_speed : float = 5

@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"

@export var is_debug_enabled : bool = true

# dependencies
@onready var camera: Camera3D = $Camera3D
@onready var colider: CollisionShape3D = $CollisionShape3D

var look_rotation : Vector2
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_rotation = Vector2(camera.rotation.y, camera.rotation.x)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # hiding the mouse


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_character(event.relative)

func rotate_character(rot_input : Vector2) -> void: 
	look_rotation.x -= rot_input.x * look_speed
	look_rotation.y -= rot_input.y * look_speed
	
	# to avoid "backflipping the camera"
	look_rotation.y = clamp(look_rotation.y, deg_to_rad(-89), deg_to_rad(89))
	
	rotation.y = look_rotation.x
	camera.rotation.x = look_rotation.y
	pass

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_speed
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
	if (is_debug_enabled):
		print("DEBUG: velocity: ", velocity)
		print("DEBUG: position: ", global_position)
		print("DEBUG: input: ", input_dir)
