#extends CharacterBody3D
#
#@export var playerSpeed = 8.0
#@export var playerAcceleration = 5.0
#@export var cameraSensitivity = 0.25
#@export var cameraAcceleration = 2.0
#@export var jumpForce = 8.0
#@export var gravity = 10.0
#
#@onready var head = $Head
#@onready var camera = $Head/Camera3D
#
#var direction = Vector3.ZERO
#var head_y_axis = 0.0
#var camera_x_axis = 0.0
#
#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
#func _input(event):
	#if event is InputEventMouseMotion:
		#head_y_axis += event.relative.x * cameraSensitivity
		#camera_x_axis += event.relative.y * cameraSensitivity
#
	#if Input.is_key_pressed(KEY_ESCAPE):
		#get_tree().quit()
#
#func _process(delta):
	#direction = Input.get_axis("left", "right") * Vector3.RIGHT + Input.get_axis("backward", "forward") * Vector3.FORWARD
	#velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	#
	#head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	#camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
	#
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y += jumpForce
	#else:
		#velocity.y -= gravity * delta
	#
	#move_and_slide()

extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5

# bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_dir: Vector2
@onready var camera = $Head/Camera3D

@onready var hand = $Hand
@onready var flashlight = $Hand/SpotLight3D
var camera_sens = 50


var capMouse = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity
		camera_x_axis = clamp(camera_x_axis, -90.0, 90)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED


func _process(delta):
	direction = Input.get_axis("left", "right") * head.basis.x + Input.get_axis("forward", "backward") * head.basis.z
	velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
	
	hand.rotation.y = -deg_to_rad(head_y_axis)
	flashlight.rotation = -deg_to_rad(camera_x_axis)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jumpForce

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
			

	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clampled = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clampled
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	_rotate_cammera(delta)
	move_and_slide()

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
func _rotate_cammera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	look_dir += input
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
