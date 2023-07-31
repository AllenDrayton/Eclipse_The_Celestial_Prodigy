extends KinematicBody2D


# For Death Emiting Particle
var bloods = preload("res://Scn/Particles.tscn")


# For Sound Effects
onready var bow_hit = $BowHit
onready var dragon_dead = $Dead
onready var audioPlayer = $AudioStreamPlayer2D

var voiceLines = [
	"DragonRoar1",
	"DragonRoar2",
	"DragonRoar3",
	"DragonRoar4",
	"DragonRoar5",
	"DragonRoar6",
	"DragonRoar7",
	"DragonRoar8"
]

var currentIndex: int = -1
var shouldPlayVoiceLines = true

# For Floating Text
var floating_text = preload("res://Scn/FloatingText.tscn")
onready var floating_text_position = $Floating_Text_Position

onready var hellbeast_animation = $AnimatedSprite
onready var turn_axis = $TurnAxis
onready var cast_point1 = $TurnAxis/CastPoint1
onready var rotation_point = $Node2D/Position2D
onready var hit_timer = $Hit_Timer
onready var death_timer = $Death_Timer
onready var hellBeast_hurtbox = $HellBeast_Hurtbox/CollisionShape2D
onready var position_detector = $Position_Detector/CollisionShape2D

var player_Direction
var SPEED = 600
var velocity = Vector2.ZERO

var can_attack = true
var attack_direction

# Animation Variables
var anim_mode = "Idle"
var face_direction = "1"
var animation = "Idle_1"

# HellBeast Stats
var not_dead = true
var get_hit = false
var attack_while_hit = false
var in_range = false

# HellBeast Hp
var max_hp = 650
var current_hp
var new_hp
onready var hp_bar = $HellBeast_Hp_Bar
onready var hp_bar_tween = $HellBeast_Hp_Bar/Tween
onready var hp_label = $HP_Label



# CoolDown
const cooldown = preload("res://Scripts/cooldown.gd")
onready var first_cooldown = cooldown.new(0.8)

enum BossState {
	FOLLOWING_PLAYER,
	ATTACKING_PLAYER,
	TAKING_DAMAGE,
	DODGING,
	DEATH
}

var currentState = BossState.FOLLOWING_PLAYER
var targetPosition: Vector2 = Vector2.ZERO
var dodgeDuration: float = 1.0
var dodgeTimer: float = 0.0

func _ready():
	Global.hellbeast = self
	
	# HP
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	
	
	# For sound effect
	# Play Voicelines
	audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	
	shuffleVoiceLines()
	
	playRandomVoiceLine()
	
	
	
func _exit_tree():
	Global.hellbeast = null


func _physics_process(delta):
	
	# Cooldown Timer
	first_cooldown.tick(delta)


func _process(delta):
	
	Hp_Bar_Update()
	hp_label.set_text(str(int(current_hp)))
	
	if Global.player != null:
		player_Direction = rad2deg(get_angle_to(Global.player.global_position))
		
		Animationloop()
	
	
	match currentState:
		BossState.FOLLOWING_PLAYER:
			followPlayer(Global.player.global_position, delta)
			SPEED = 600
			anim_mode = "Run"
			dodgeTimer += delta
			if dodgeTimer >= dodgeDuration:
				dodgeTimer = 0.0
				randomlyDodge()
		
		BossState.ATTACKING_PLAYER:
			anim_mode = "Attack2"
			attackPlayer()
		
		BossState.TAKING_DAMAGE:
			# Handle taking damage logic
			if get_hit == true:
				anim_mode = "Hit"
			else:
				if in_range == true:
					currentState = BossState.ATTACKING_PLAYER
				elif in_range == false:
					currentState = BossState.FOLLOWING_PLAYER
		
		BossState.DODGING:
			dodgeTimer += delta
			if dodgeTimer >= dodgeDuration:
				dodgeTimer = 0.0
				currentState = BossState.FOLLOWING_PLAYER
		
		BossState.DEATH:
			# Handle death logic
			anim_mode = "Death"
			SPEED = 0
			

func followPlayer(target, delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	velocity = move_and_slide(velocity)
	
func attackPlayer():
	# Randomly select an attack pattern
	var attackPattern = randi() % 4
	
	match attackPattern:
		0: # Auto-attack
			autoAttack()
	
		1: # Shot Gun Effect
			shot_gun_effect()
	
		2: # Auto Aim
			autoAim()
	
		3: # Splash
			Splash()

func autoAttack():
	# Implement auto-attack logic
	if first_cooldown.is_ready():
		#print("pew pewwwwww")
		Global.hellbeast_damage = 3
		can_attack = false
		attack_direction = (get_angle_to(Global.player.global_position)/3.14)*180
		turn_axis.rotation = get_angle_to(Global.player.global_position)
		var skill = load("res://Scn/Fire_Attack.tscn")
		var skill_instance = skill.instance()
		skill_instance.attack_direction = attack_direction
		skill_instance.rotation = get_angle_to(Global.player.global_position)
		skill_instance.position = cast_point1.get_global_position()
		get_parent().add_child(skill_instance)
		yield(get_tree().create_timer(0.6), "timeout")
		can_attack = true

func shot_gun_effect():
	# Implement volcano eruption logic
	if first_cooldown.is_ready():
		#print("Bam Bammmmmmm")
		Global.hellbeast_damage = 6
		var array = [null, null, null]
		var times = 4
		can_attack = false
		attack_direction = (get_angle_to(Global.player.global_position)/3.14)*180
		turn_axis.rotation = get_angle_to(Global.player.global_position)
		var skill = load("res://Scn/Fire_Attack2.tscn")
		
		for i in range(1, times):
			array[i-1] = skill.instance()
			array[i-1].attack_direction = attack_direction
			array[i-1].rotation = get_angle_to(Global.player.global_position)
			array[i-1].position = get_node("TurnAxis/CastPoint" + str(i)).get_global_position()
			get_parent().add_child(array[i-1])
		
		
		yield(get_tree().create_timer(0.6), "timeout")
		can_attack = true

func autoAim():
	# Implement Galio's style ultimate spell logic
	if first_cooldown.is_ready():
		#print("Slammmm Slammmmmmm")
		Global.hellbeast_damage = 10
		can_attack = false
		attack_direction = (get_angle_to(Global.player.global_position)/3.14)*180
		turn_axis.rotation = get_angle_to(Global.player.global_position)
		var skill = load("res://Scn/Laser.tscn")
		var skill_instance = skill.instance()
		#skill_instance.attack_direction = attack_direction
		skill_instance.rotation = get_angle_to(Global.player.global_position)
		skill_instance.position = cast_point1.get_global_position()
		get_parent().add_child(skill_instance)
		yield(get_tree().create_timer(0.6), "timeout")
		can_attack = true

func Splash():
	if first_cooldown.is_ready():
		#print("Splashhhhhhhh")
		Global.hellbeast_damage = 15
		can_attack = false
		var skill = load("res://Scn/Fire_Effects.tscn")
		var skill_instance = skill.instance()
		skill_instance.position = Global.player.get_global_position()
		get_parent().add_child(skill_instance)
		yield(get_tree().create_timer(0.6), "timeout")
		can_attack = true

func randomlyDodge():
	var dodgeDirection: Vector2 = Vector2.ZERO
	var dodgeRange: float = 100.0

	# Calculate a random dodge direction within the specified range
	dodgeDirection.x = rand_range(-dodgeRange, dodgeRange)
	dodgeDirection.y = rand_range(-dodgeRange, dodgeRange)
	dodgeDirection = dodgeDirection.normalized()

	# Calculate the target position to dodge to
	targetPosition = global_position + dodgeDirection * dodgeRange

	currentState = BossState.DODGING


func _on_Position_Detector_area_entered(area):
	if area.is_in_group("HellBeast_HitPoint"):
		currentState = BossState.ATTACKING_PLAYER
		can_attack = true
		in_range = true


func _on_Position_Detector_area_exited(area):
	if area.is_in_group("HellBeast_HitPoint"):
		currentState = BossState.FOLLOWING_PLAYER
		can_attack = false
		in_range = false


func Animationloop():
	
	if not_dead == false:
		anim_mode = "Death"
		SPEED = 0
	
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
	hellbeast_animation.play(animation)


func SwordHit():
	current_hp -= Global.sword_damage
	
	Signals.emit_signal("boss_life_steal_signal")
	Signals.emit_signal("boss_mana_regen_emit")
	
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = Global.sword_damage
	text.type = "Damage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		Signals.emit_signal("boss_defeated")
		#state = Dead
		OnDeath()


func ArrowHit():
	current_hp -= Global.arrow_damage
	
	Signals.emit_signal("boss_life_steal_signal")
	Signals.emit_signal("boss_mana_regen_emit")
	
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = Global.arrow_damage
	text.type = "Damage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		Signals.emit_signal("boss_defeated")
		#state = Dead
		OnDeath()


func _on_HellBeast_Hurtbox_area_entered(area):
	currentState = BossState.TAKING_DAMAGE
	if area.is_in_group("ArrowDamager"):
		bow_hit.play()
		area.get_parent().queue_free()
		ArrowHit()
		get_hit = true
		hit_timer.start()
		
	elif area.is_in_group("SwordDamager"):
		bow_hit.play()
		SwordHit()
		get_hit = true
		attack_while_hit = true
		hit_timer.start()
		
	
	print(current_hp)

func OnDeath():
	SPEED = 0
	dragon_dead.play()
	hellBeast_hurtbox.set_deferred("disabled", true)
	position_detector.set_deferred("disabled", true)
	first_cooldown = cooldown.new(0.0)
	not_dead = false
	can_attack = false
	currentState = BossState.DEATH
	anim_mode = "Death"
	death_timer.start()
	


func _on_Hit_Timer_timeout():
	get_hit = false
	attack_while_hit = false


func _on_Death_Timer_timeout():
	
	var particle = bloods.instance()
	particle.position = global_position
	particle.rotation = global_rotation
	get_parent().add_child(particle)
	
	queue_free()



# HP Bar Function
func Hp_Bar_Update():
	#percentage_hp = int((float(current_hp) / max_hp) * 100)
	new_hp = current_hp
	hp_bar_tween.interpolate_property(hp_bar, 'value', hp_bar.value, new_hp, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	hp_bar_tween.start()

# Play RandomVoiceline
func playRandomVoiceLine():
	
	currentIndex += 1
	
	if currentIndex >= voiceLines.size():
		currentIndex = 0
	
	if !shouldPlayVoiceLines:
		return
	
	var voiceLine = voiceLines[currentIndex]
	#print("Playing voice line: ", voiceLine)
	
	if not_dead == false:
		shouldPlayVoiceLines = false
		return
	
	# Play the voice line using your audio system
	# For example, using AudioStreamPlayer2D:
	audioPlayer.stream = load("res://Assets/SFX/MonsterSounds/Dragon/" + voiceLine + ".ogg")
	audioPlayer.play()
	
	
#	var delay = rand_range(3.0, 5.0)  # Adjust the delay range as needed
#	yield(get_tree().create_timer(delay), "timeout")
	$YieldDelay.start()


func shuffleVoiceLines():
	voiceLines.shuffle()


func _on_YieldDelay_timeout():
	playRandomVoiceLine()
