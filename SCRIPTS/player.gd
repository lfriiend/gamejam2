extends CharacterBody3D

@export var playerSpeed = 8.0
@export var playerAcceleration = 5.0

var direction = Vector3.ZERO

func _process(delta):
	direction = Input.get_axis("left", "right") * Vector3.RIGHT + Input.get_axis("backward", "forward") * Vector3.FORWARD
	velocity = velocity.lerp(direction * playerSpeed, playerAcceleration * delta)
	
	move_and_slide()
