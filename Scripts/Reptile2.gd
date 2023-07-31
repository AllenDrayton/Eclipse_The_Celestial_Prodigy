extends KinematicBody2D


# For Death Emiting Particle
var bloods = preload("res://Scn/Particles.tscn")

# For Sound Effects
onready var get_hit_by_arrow = $ArrowHit
onready var scream = $Scream
onready var dead = $Dead


# Floating Text
var floating_text = preload("res://Scn/FloatingText.tscn")
onready var floating_text_position = $FloatingTextPosition

onready var reptileAnimation = $AnimatedSprite
onready var reptile_hurtbox = $RepHurtbox/CollisionShape2D
onready var sight = $Sight/CollisionShape2D
onready var hit_timer = $Hit_Timer
onready var death_timer = $Death_Timer
onready var attack_timer = $Attack_Timer
onready var reptile_attack_timer = $Reptile_Attack_Timer
onready var position_detector = $PositionDetector/CollisionShape2D

# Attack Area Functions
onready var attack_pivot = $Attack_Pivot
onready var attack_area = $Attack_Pivot/Attack_area
onready var reptile_hitbox = $Attack_Pivot/Attack_area/CollisionShape2D

# Hp related Variables
var max_hp = 150
var current_hp
var percentage_hp
var new_hp
onready var hp_bar = $Reptile_hp
onready var hp_bar_tween = $Reptile_hp/Tween



#var arrowDamage = Global.arrow_damage
#var swordDamage = Global.sword_damage
var facing # Nothing to do
var knockback = Vector2.ZERO

# CoolDown
const cooldown = preload("res://Scripts/cooldown.gd")
onready var first_cooldown = cooldown.new(0.8)

# Reptile Stats
var SPEED = 500
var velocity = Vector2.ZERO
var player_position
var player_Direction 
var get_hit = false
var attack_while_hit = false
#var dead_direction
var not_dead = true
var reptile_attack = false

# Position Detector
var inAttract_area = false
var inAttack_area = false

# Reptile Attack Variables
var can_attack = false
var attack_direction

# Animation Variables
var anim_mode = "Idle"
var face_direction = "1"
var animation = "Idle_1"

# Sight Checker
var player_in_range
var player_in_sight
var player_seen

# Reptile State Machine
enum {
	Rest,
	Approach,
	Attack,
	Dead,
}

var state = Rest

# Making Circle
var randomnum


func _ready():
	Global.reptile = self
	
	# HP
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	
	# Randomizing Circle
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	
	# For Scream
	ReptileScream()

func _exit_tree():
	Global.reptile = null


func _physics_process(delta):
	
	# Cooldown Timer
	first_cooldown.tick(delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	SightCheck()
	
	if can_attack == true:
		SPEED = 0
		if first_cooldown.is_ready():
			attack_pivot.rotation = get_angle_to(Global.player.global_position)
			reptile_hitbox.set_deferred("disabled", false)
		else:
			reptile_hitbox.set_deferred("disabled", true)
	elif can_attack == false:
		reptile_hitbox.set_deferred("disabled", true)


func _process(delta):
	
	Hp_Bar_Update()
	
	reptileAnimation.play(animation)
	if Global.player != null and player_seen:
		player_Direction = rad2deg(get_angle_to(Global.player.global_position))
		#print(player_Direction)
		reptileAnimation_loop(delta)
		
	match state:
		Rest:
			SPEED = 0
		Approach:
			#print("Go go go goooo")
			#move(get_circle_position(randomnum), delta)
			move(Global.player.global_position, delta)
			SPEED = 300
		Attack:
			#print("Imma Kill You!")
			move(Global.player.global_position, delta)
			SPEED = 0
			can_attack = true
			#Reptile_Attack_logic()
		Dead:
			SPEED = 0
			#OnDeath()
	#print(can_attack)


func reptileAnimation_loop(delta):
	
	#var direction = direction2str(facing)
	if get_hit == true:
		anim_mode = "BodyHit"
	elif get_hit == false:
		if not_dead == true:
			if SPEED != 0:
				anim_mode = "Run"
			elif SPEED == 0:
				if can_attack == true:
					anim_mode = "Attack3"
				else:
					anim_mode = "Idle"
		elif not_dead == false:
			anim_mode = "Dead"
			
	
#	if anim_mode == "Attack3":
#		if attack_direction <= 15 and attack_direction >= -15:
#			face_direction = "0"
#		elif attack_direction <= 60 and attack_direction >= 15:
#			face_direction = "1"
#		elif attack_direction <= 120 and attack_direction >= 60:
#			face_direction = "2"
#		elif attack_direction <= 165 and attack_direction >= 120:
#			face_direction = "3"
#		elif attack_direction >= -60 and attack_direction <= -15:
#			face_direction = "7"
#		elif attack_direction >= -120 and attack_direction <= -60:
#			face_direction = "6"
#		elif attack_direction >= -165 and attack_direction <= -120:
#			face_direction = "5"
#		elif attack_direction <= -165 or attack_direction >= 165:
#			face_direction = "4"

		#anim_mode = "Attack3"
		
	#if (anim_mode == "BodyHit" || anim_mode == "Run" || anim_mode == "Idle" || anim_mode == "Dead") and attacking == false:
	if player_Direction <= 15 and player_Direction >= -15 and not_dead:
		face_direction = "0"
		#face_direction = Vector2(1,0)
	elif player_Direction <= 60 and player_Direction >= 15 and not_dead:
		face_direction = "1"
		#face_direction = Vector2(1,0.5)
	elif player_Direction <= 120 and player_Direction >= 60 and not_dead:
		face_direction = "2"
		#face_direction = Vector2(0,0.5)
	elif player_Direction <= 165 and player_Direction >= 120 and not_dead:
		face_direction = "3"
		#face_direction = Vector2(-1,0.5)
	elif player_Direction >= -60 and player_Direction <= -15 and not_dead:
		face_direction = "7"
		#face_direction = Vector2(1,-0.5)
	elif player_Direction >= -120 and player_Direction <= -60 and not_dead:
		face_direction = "6"
		#face_direction = Vector2(0,-0.5)
	elif player_Direction >= -165 and player_Direction <= -120 and not_dead:
		face_direction = "5"
		#face_direction = Vector2(-1,-0.5)
	elif (player_Direction <= -165 and not_dead) or (player_Direction >= 165 and not_dead):
		face_direction = "4"
		#face_direction = Vector2(-1,0)
	
	animation = anim_mode + "_" + face_direction
	#print(animation)
	reptileAnimation.play(animation)

func Reptile_Attack_logic():
	print("PlayerHit!!!")
	anim_mode = "Attack3"
	attack_direction = rad2deg(get_angle_to(Global.player.global_position))
	animation = anim_mode + "_" + face_direction
	reptileAnimation.play(animation)
	
	

#func direction2str(direction):
#	var angle = direction.angle()
#	if angle < 0:
#		angle += 2 * PI
#	var a = round(angle / PI * 4)
#	return str(a)

func move(target,delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	velocity = move_and_slide(velocity)


func SwordHit():
	current_hp -= Global.sword_damage
	Signals.emit_signal("life_steal_signal")
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = Global.sword_damage
	text.type = "Damage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		Signals.emit_signal("mana_regeneration")
		#state = Dead
		Signals.emit_signal("variant_defeated")
		OnDeath()


func ArrowHit():
	current_hp -= Global.arrow_damage
	Signals.emit_signal("life_steal_signal")
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = Global.arrow_damage
	text.type = "Damage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		Signals.emit_signal("mana_regeneration")
		#state = Dead
		Signals.emit_signal("variant_defeated")
		OnDeath()
	
func OnDeath():
	
	SPEED = 0
	dead.play()
	reptile_hurtbox.set_deferred("disabled", true)
	position_detector.set_deferred("disabled", true)
	reptile_hitbox.set_deferred("disabled", true)
	first_cooldown = cooldown.new(0.0)
	not_dead = false
	can_attack = false
	anim_mode = "Dead"
	print(face_direction)
	
	animation = anim_mode + "_" + face_direction
	reptileAnimation.play(animation)
	#print("Reptile is Dead")
	death_timer.start()


func _on_RepHurtbox_area_entered(area):
	
	Signals.emit_signal("reptile_got_hit")
	
	if area.is_in_group("ArrowDamager"):
		get_hit_by_arrow.play()
		area.get_parent().queue_free()
		ArrowHit()
		Hp_Bar_Update()
		get_hit = true
		#print("Hit !")
		knockback = Global.enemy_bow_knockback_vector * 200
		hit_timer.start()

	elif area.is_in_group("SwordDamager"):
		SwordHit()
		Hp_Bar_Update()
		get_hit = true
		attack_while_hit = true
		#if attack_while_hit == true:
			#can_attack = false
		#print("Hit !")
		knockback = Global.enemy_sword_knockback_vector * 120
		hit_timer.start()
		reptile_attack_timer.start()
	
	#print(current_hp)


func _on_Hit_Timer_timeout():
	get_hit = false
	attack_while_hit = false


func _on_Sight_body_entered(body):
	if body == Global.player:
		player_in_range = true


func _on_Sight_body_exited(body):
	if body == Global.player:
		player_in_range = false
		if player_seen == true:
			if not_dead == false:
				state = Dead
			else:
				if can_attack == true:
					state = Attack
				else:
					state = Approach
		#print(state)

func SightCheck():
	if player_in_range == true:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, Global.player.position, [self], collision_mask)
		if sight_check:
			if sight_check.collider.name == "Player":
				player_in_sight = true
				player_seen = true
				if not_dead == false:
					state = Dead
				else:
					if can_attack == true:
						state = Attack
					else:
						state = Approach
			else:
				player_in_sight = false
				if player_seen == true:
					if not_dead == false:
						state = Dead
					else: 
						if can_attack == true:
							state = Attack
						else:
							state = Approach
				else:
					state = Rest
		#print(state)


func _on_Death_Timer_timeout():
	
	var particle = bloods.instance()
	particle.position = global_position
	particle.rotation = global_rotation
	get_parent().add_child(particle)
	
	queue_free()
	

# Circular Position for Enemies but I Don't use it yet
func get_circle_position(random):
	var kill_circle_center = Global.player.global_position
	var radius = 170 # Distance from center to circumference of circle
	var angle = random * PI * 2
	var x = kill_circle_center.x + cos(angle) * radius
	var y = kill_circle_center.y + sin(angle) * radius
	
	return Vector2(x, y)


func _on_Reptile_Attack_Timer_timeout():
	#can_attack = true
	pass


func _on_PositionDetector_area_entered(area):
	if area.is_in_group("Attack"):
		state = Attack
		can_attack = true
#		if can_attack == true and first_cooldown.is_ready():
#			Reptile_Attack_logic()


func _on_PositionDetector_area_exited(area):
	if area.is_in_group("Attack"):
		state = Approach
		can_attack = false


# HP Bar Function
func Hp_Bar_Update():
	#percentage_hp = int((float(current_hp) / max_hp) * 100)
	new_hp = current_hp
	hp_bar_tween.interpolate_property(hp_bar, 'value', hp_bar.value, new_hp, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	hp_bar_tween.start()
	

func ReptileScream():
	scream.play()
