 extends Position2D


onready var label = $Label
onready var tween = $Tween
var amount = 0
var type = ""

var velocity = Vector2(0, 0)

func _ready():
	set_as_toplevel(true)
	label.set_text(str(amount))
	
	match type:
		"Heal":
			label.set("custom_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("custom_colors/font_color", Color("ff3131"))
		"PlayerTakeDamage":
			label.set("custom_colors/font_color", Color("ffa500"))
		"ManaRegen":
			label.set("custom_colors/font_color", Color("0000ff"))
	
	randomize()
	var side_movement = randi() % 81 - 40
	velocity = Vector2(side_movement, 50)
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1.5, 1.5), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1.5, 1.5), Vector2(0.1, 0.1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	tween.start()


func _on_Tween_tween_all_completed():
	self.queue_free()


func _process(delta):
	position -= velocity * delta
