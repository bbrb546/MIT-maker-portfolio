extends Node2D # or node 2d, but leaning towards the former

var mouse_in = false

func _ready():
	$Area2D.connect("mouse_entered", toggle_mouse_in)
	$Area2D.connect("mouse_exited", toggle_mouse_in)

func _process(delta):
	if mouse_in:
		mouse_in = not mouse_in

func toggle_mouse_in():
	mouse_in = not mouse_in
