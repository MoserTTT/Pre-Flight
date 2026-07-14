extends Node3D

func apply_jump():
	get_parent().apply_jump()

func end_jump():
	get_parent().end_jump()

func throw_bottle():
	get_parent().throw_bottle()
