extends RigidBody3D
@export var isSticky: bool = false
var stuck := false

func on_grow_anim_finished():
	$CollisionShape3D.scale = Vector3(2.0,2.0,2.0)
	$CollisionShape3D.position.y += 0.5

func _ready():
	$Bottle/BottleYellow_sticky.visible=false
	if isSticky:
		$Bottle/BottleYellow_sticky.visible=true
		$Bottle/BottleBlue_throw.visible=false
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if stuck:
		return
	stuck = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	$AnimationPlayer.play("grow")
