extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("mouse_entered", scale_up)
	get_parent().connect("mouse_exited", scale_down)
	

func scale_up():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(.08, .08), 0.05)

func scale_down():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(.07, .07), 0.05)
