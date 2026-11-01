extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	fit_content = true
	custom_minimum_size = Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if text.length() > 190:
		fit_content = false
		custom_minimum_size = Vector2(1024,120)
	else:
		fit_content = true
		custom_minimum_size = Vector2(0,0)
