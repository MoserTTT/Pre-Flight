extends Node3D

@onready var parent = get_parent() as PathFollow3D
@export var movement_speed = 1.0
var direction = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent.progress_ratio = randf()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if  parent is PathFollow3D:
		parent.set_progress(parent.get_progress() + direction * movement_speed * delta)
	if parent.progress_ratio >= 1.0:
		parent.progress_ratio = 1.0
		direction = -1.0
	elif parent.progress_ratio <= 0.0:
		parent.progress_ratio = 0.0
		direction = 1.0


func _on_hitbox_area_entered(area: Area3D) -> void:
	$AnimationPlayer.play("die")
	pass
