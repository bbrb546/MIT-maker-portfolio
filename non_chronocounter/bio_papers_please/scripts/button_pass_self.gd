extends TextureButton

signal down(myself)
signal up(myself)

# Called when the node enters the scene tree for the first time.
func _ready():
	button_down.connect(downd)
	button_up.connect(upd)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func downd():
	emit_signal("down", self)
func upd():
	emit_signal("up", self)
