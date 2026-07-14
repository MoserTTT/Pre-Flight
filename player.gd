extends CharacterBody3D

## --- Movement ---
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 6.0
@export var rotation_speed: float = 10.0  # how fast the model turns to face movement direction
@export var bottle_velocity: float = 10.0
@export var bottle_scene: PackedScene
@export var COYOTE_TIME = 0.10
var coyote_timer = 0.0
@export var jump_buffer_duration = 0.1
var jump_buffer_remaining = 0.0
var movement_halted_on_jump: bool = false  

## --- Camera ---
@export var mouse_sensitivity: float = 0.003
@export var camera_pitch_min: float = -60.0
@export var camera_pitch_max: float = 70.0
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var model: Node3D = $Model  

## --- Abilities ---
@export var shrinkUnlocked : bool = true
@export var StickyBottleUnlocked : bool = true
@export var hoverUnlocked : bool = true
@export var shrinkFactor : float = 0.2
var isShrunk : bool = false
@export var hoverTime : float = 0.65
var hoverTimeRemaining : float = 0.0
var isSticky = false

## --- Other ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var anim_tree: AnimationTree =$Model/AnimationTree
var bottle

# recipients of calls sent from the animation track to sync physics and animation
func apply_jump()->void:
	velocity.y = jump_velocity
	movement_halted_on_jump = false
func end_jump()->void:
	anim_tree.set("parameters/conditions/jump", false)
	
func throw_bottle()->void:
	bottle = bottle_scene.instantiate()
	bottle.isSticky = self.isSticky
	get_tree().current_scene.add_child(bottle)
	bottle.global_position = $Marker3D.global_position
	bottle.global_basis= $Marker3D.global_basis
	var throw_direction := -spring_arm.global_transform.basis.z.normalized()
	bottle.linear_velocity = throw_direction * bottle_velocity
	anim_tree.set("parameters/conditions/throw", false)

## Ability functions
func shrink(factor : float) -> void:
	scale = Vector3(factor,factor,factor)
	jump_velocity *= 0.75
	gravity /= 2
	$CameraPivot/SpringArm3D.spring_length = 3.5
	$CameraPivot.position.y += 1.35
func unShrink() -> void:
	scale = Vector3(1.0,1.0,1.0)
	jump_velocity /= 0.75
	gravity *= 2
	$CameraPivot/SpringArm3D.spring_length = 3.5
	$CameraPivot.position.y -= 1.35


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
		coyote_timer -= delta	
	else:
		coyote_timer = COYOTE_TIME
		hoverTimeRemaining = hoverTime 
	
	#Hover
	if Input.is_action_pressed("hover"):
		if hoverTimeRemaining >0:
			velocity.y += gravity * delta 
			hoverTimeRemaining -= delta
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		jump_buffer_remaining = jump_buffer_duration
	else:
		jump_buffer_remaining -= delta
	if jump_buffer_remaining > 0 and  coyote_timer > 0.0:
		coyote_timer = 0.0
		jump_buffer_remaining = 0.0
		movement_halted_on_jump = true
		anim_tree.set("parameters/conditions/walk", false)
		anim_tree.set("parameters/conditions/idle", false)
		anim_tree.set("parameters/conditions/jump", true)
	
	#Shrink
	if Input.is_action_just_pressed("shrink"): 
		if isShrunk:
			unShrink()
			isShrunk = false
		else: 
			shrink(shrinkFactor)
			isShrunk = true
	
	#Sticky
	if Input.is_action_just_pressed("toggle_sticky"):
		if isSticky:
			isSticky = false
		else:
			isSticky = true

	# Read input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := walk_speed

	# Convert input into a direction relative to the camera's yaw
	var cam_basis := camera_pivot.global_transform.basis
	var direction := cam_basis * Vector3(input_dir.x, 0, input_dir.y)
	direction.y = 0
	direction = direction.normalized()
	
	if Input.is_action_just_pressed("shoot_bottle"):
		anim_tree.set("parameters/conditions/throw", true)
		
	#Handle Walking and Moving according to WASD
	if direction.length() > 0.01 and not movement_halted_on_jump:
		if is_on_floor():
			anim_tree.set("parameters/conditions/idle", false)
			anim_tree.set("parameters/conditions/walk", true)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# Smoothly rotate the character model to face the movement direction
		if model:
			var target_rot := atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rot, rotation_speed * delta)
	else:
		if is_on_floor() and not movement_halted_on_jump:
			anim_tree.set("parameters/conditions/walk",false)
			anim_tree.set("parameters/conditions/idle", true)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
