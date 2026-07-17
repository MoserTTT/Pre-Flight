extends Control
func _ready() -> void:
	$CanvasLayer/Tutorial1.visible = false
	$CanvasLayer/Tutorial2.visible = false
	$CanvasLayer/Tutorial3.visible = false
	$CanvasLayer/Tutorial4.visible = false

func set_healthbar(val):
	$CanvasLayer/Control/Healthbar.value = val

func set_bottle_counter(val):
	$CanvasLayer/Control/BottleCounter.text= str(val) +"/15"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
