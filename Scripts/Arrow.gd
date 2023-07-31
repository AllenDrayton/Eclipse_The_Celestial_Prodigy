extends RigidBody2D

var skill_name
var projectile_speed = Vector2(1600, 0)
var angle = null
export var life_time = 3

onready var audioPlayer = $AudioStreamPlayer2D

func _ready():
	
	# For Ability Oriented
	match skill_name:
		"Fireball":
			if Global.player.current_mana >= 20:
				audioPlayer.play()
				projectile_speed = Vector2(2000, 0)
				Global.arrow_damage = 20
				Global.mana_cost = 20
				Global.mana_regeneration = 20
				Global.boss_mana_regen = 10
				if Global.player.current_hp > 0 and Global.player.current_hp < Global.player.max_hp:
					Global.life_steal = 2
					Global.boss_life_steal = 20
				else:
					Global.life_steal = 0
					Global.boss_life_steal = 0
				Signals.emit_signal("reduce_mana_signal")
				var skill_texture = load("res://Assets/Skills/" + skill_name + ".png")
				get_node("Sprite").set_texture(skill_texture)
			else:
				Global.mana_regeneration = 0
				Global.boss_mana_regen = 0
				Signals.emit_signal("mana_warning_signal")
				Global.mana_insufficient = "Insufficient Mana!!!"
		"Taoe":
			Global.arrow_damage = 10
			if Global.player.current_hp > 0 and Global.player.current_hp < Global.player.max_hp:
					Global.life_steal = 2
					Global.boss_life_steal = 10
			else:
					Global.life_steal = 0
					Global.boss_life_steal = 0
			projectile_speed = Vector2(2400, 0)
			var skill_texture = load("res://Assets/Skills/" + skill_name + ".png")
			get_node("Sprite").set_texture(skill_texture)
	
	set_as_toplevel(true)
	apply_impulse(Vector2(), Vector2(projectile_speed).rotated(rotation))
	
	angle = Vector2(projectile_speed).rotated(rotation)



func _on_ArrowLifeTime_timeout():
	queue_free()


func _on_ArrowHitbox_area_entered(area):
	$ArrowLifeTime.start()
	if area.is_in_group("Objects"):
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func _on_Arrow_body_entered(body):
	if body.is_in_group("Objects"):
		self.hide()



