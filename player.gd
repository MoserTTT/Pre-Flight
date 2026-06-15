extends CharacterBody3D

## --- Movement ---
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 10.0  # how fast the model turns to face movement direction
@export var ball_velocity: float = 10.0
@export var ball_scene: PackedScene

## --- Camera ---
@export var mouse_sensitivity: float = 0.003
@export var camera_pitch_min: float = -60.0
@export var camera_pitch_max: float = 70.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var model: Node3D = $Model  # the visible mesh/character that should rotate to face movement

var ball
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x,
			deg_to_rad(camera_pitch_min),
			deg_to_rad(camera_pitch_max)
		)

	# Toggle mouse capture (handy for testing)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Read input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	# Convert input into a direction relative to the camera's yaw
	var cam_basis := camera_pivot.global_transform.basis
	var direction := cam_basis * Vector3(input_dir.x, 0, input_dir.y)
	direction.y = 0
	direction = direction.normalized()
	
	if Input.is_action_just_pressed("shoot_ball") and not ball:
		ball = ball_scene.instantiate()
		get_tree().current_scene.add_child(ball)
		ball.global_position = $Marker3D.global_position
		ball.global_basis= $Marker3D.global_basis
		var throw_direction := -spring_arm.global_transform.basis.z.normalized()
		ball.linear_velocity = throw_direction * ball_velocity
	elif Input.is_action_just_pressed("shoot_ball") and ball:
		global_position = ball.global_position
		velocity = Vector3.ZERO
		ball.queue_free()
		ball=null
		
	
	if direction.length() > 0.01:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# Smoothly rotate the character model to face the movement direction
		if model:
			var target_rot := atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rot, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
