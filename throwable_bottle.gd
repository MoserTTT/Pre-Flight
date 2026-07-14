extends RigidBody3D
@export var isSticky: bool = false
var stuck := false

func _ready():
	if isSticky:
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if stuck:
		return
	stuck = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	freeze = true
