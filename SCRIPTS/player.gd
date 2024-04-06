extends CharacterBody3D

@export var playerSpeed = 8.0
@export var playerAcceleration = 5.0
@export var cameraSensitivity = 0.25
@export var cameraAcceleration = 2.0
@export var jumpForce = 8.0
@export var gravity = 10.0

@onready var head = $Head
@onready var camera = $Head/Camera3D

var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _process(delta):
	direction = Input.get_axis("left", "right") * Vector3.RIGHT + Input.get_axis("backward", "forward") * Vector3.FORWARD
	velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jumpForce
	else:
		velocity.y -= gravity * delta
	
	move_and_slide()
