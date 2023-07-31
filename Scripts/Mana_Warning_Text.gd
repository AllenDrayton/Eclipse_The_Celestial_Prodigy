extends Position2D

onready var label = $Label
onready var tween = $Tween

var amount = 0

func _ready():
	set_as_toplevel(true)
	label.set_text(str(amount))
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1.5, 1.5), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1.5, 1.5), Vector2(0.1, 0.1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.start()



func _on_Tween_tween_all_completed():
	self.queue_free()
