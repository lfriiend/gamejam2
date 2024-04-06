extends CharacterBody3D

@onready var head = $Head
@onready var head_x = $Head/HeadXRotation

var sensitivity = -0.1

const SPEED = 2.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		head.rotation_degrees.y += sensitivity * event.relative.x
		head_x.rotation_degrees.x += sensitivity * event.relative.y
		head_x.rotation_degrees.x = clamp(head_x.rotation_degrees.x, -89, 89)
		
func _process(delta):
	var head_basis = head.get_global_transform().basis
	var direction = Vector3.ZERO

	if Input.is_action_just_pressed("up"):
		direction -= head.basis.z
	elif Input.is_action_just_pressed("down"):
		direction += head_basis.z
	if Input.is_action_just_pressed("left"):
		direction -= head.basis.x
	elif Input.is_action_just_pressed("right"):
		direction += head_basis.x
		
	direction = direction.normalized()
	var direspeed = direction * SPEED
	move_and_slide(direspeed)
