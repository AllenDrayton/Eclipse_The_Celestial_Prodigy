extends KinematicBody2D

onready var playerAnimation = $AnimatedSprite

signal player_hit_screenshake
signal reptile_hit_screenshake
signal shockwave

# Win Lose COndition
var win = false
var bossWin = false

# Sound Effects
onready var footstep = $Footstep
onready var scream = $Scream
onready var scream2 = $Scream2
onready var scream3 = $Scream3
onready var swing = $SwordSwing
onready var deadScream = $Death
onready var gethit = $GetHit
onready var gethitScream = $GetHitScream
onready var audioPlayer = $AudioStreamPlayer2D
onready var taunting = $Taunting
onready var mock_boss = $MockBoss
onready var releasing_arrow = $ArrowRelease
onready var dash_shuffle = $Shuffle
onready var dash_shuffle_scream = $ShuffleScream

var voiceLines = [
	"RV1",
	"RV2",
	"RV3",
	"RV4",
	"RV5",
	"RV6",
	"RV7",
	"RV8",
	"RV9",
	"RV10",
	"RV11",
	"RV12",
	"RV13",
	"RV14",
	"RV15",
	"RV16"
]

var playedVoiceLines = []
#var remainingVoiceLines = []
var currentIndex: int = -1
var shouldPlayVoiceLines = true

# For Death Emiting Particle
var bloods = preload("res://Scn/Particles2.tscn")

# Teleportation Stats
onready var teleportPosition = $TeleporterSpawner
var teleport = preload("res://Scn/Teleporter.tscn")
var tele_phase_two = preload("res://Scn/Teleporter3.tscn")

onready var hellbeast_HitPoint = $HellBeast_Hit_Point/CollisionShape2D

# Handling Player Death
var player_is_dead = false
onready var player_dead_timer = $Player_Dead_Timer


# Floating Text Variables
var floating_text = preload("res://Scn/FloatingText.tscn")
onready var floating_text_position = $FloatingTextPosition

# Mana Warning Text Variables
var mana_warning_text = preload("res://Scn/Mana_Warning_Text.tscn")
onready var mana_warning_text_position = $Mana_Warning_Text_Position

# Camera Stats
onready var camera = $Camera2D
const CAMERA_BORDER_THRESHOLD = 50
const CAMERA_MOVE_SPEED = 500
const CAMERA_SMOOTHNESS = 10

# For Ability Oriented
var selected_skill
var nova = preload("res://Scn/NovaSkill.tscn")
var supernova = preload("res://Scn/SuperNova.tscn")

# Player Hurtbox
onready var player_hurtbox = $Player_Hurtbox/CollisionShape2D
onready var player_attract = $Attack/CollisionShape2D

# Player Hit Timer
onready var player_hit_timer = $Player_Hit_Timer

# Player Health
var max_hp = 100
var current_hp
var hp_regen = 1

# Player Mana
var max_mana = 100
var current_mana
var mana_regen = 2

# Enemies Damage
var reptile_damage = Global.reptile_attack_damage

# Movement Variables and Directions
var max_speed = 400
var speed = 0
var acceleration = 900
var move_direction = Vector2(0,0)
var anim_mode
var moving = false

var facing = Vector2()

# Sword attacking Stats
var attacking = false
var attack_direction 
onready var sword_range = $SwordPivot/SwordRange/CollisionShape2D
onready var sword_pivot = $SwordPivot
onready var sword_knockback = $SwordPivot/SwordRange


# Dashing Stats
export var dash_speed = 1000
export var dash_duration = 0.2
export var dash_cooldown = 1.0

var dash_timer = 0
var can_dash = true
var dash_direction = Vector2.ZERO

# Bow Shooting Stats
export var projectile_lifetime = 2.0
export var projectile_cooldown = 0.7

var projectile = preload("res://Scn/Arrow.tscn")
var can_shoot = true
var trying_to_shoot = false

var shooting = false
var aim_direction
var shoot_direction
var bow_direction

var shooting_anim = null
var is_aiming = false
#var aiming_frame = 11
onready var bow_knockback = $TurnAxis/CastPoint


func _ready():
	Global.player = self
	anim_mode = "Idle"
	
	current_hp = max_hp
	current_mana = max_mana
	
	# For Creating a knockback effect on Enemy according player face direction
	sword_knockback.knockback_vector = facing
	
	# Connecting Signals
	Signals.connect("player_got_hit", self, "Emit_signal_screenshake")
	#Signals.connect("reptile_got_hit", self, "Reptile_Got_Hit_Screenshake")
	Signals.connect("supernova_screenshake", self, "Activate_Shockwave")
	Signals.connect("reduce_mana_signal", self, "Reduced_Mana_amount")
	Signals.connect("life_steal_signal", self, "Adding_life_steal")
	Signals.connect("boss_life_steal_signal", self, "Adding_boss_life_steal")
	Signals.connect("mana_warning_signal", self, "Mana_warning_function")
	Signals.connect("mana_regeneration", self, "Adding_Mana_Regeneration")
	Signals.connect("boss_mana_regen_emit", self, "Adding_Boss_Mana_Regen")
	Signals.connect("teleportation_ready", self, "Activate_Teleport")
	Signals.connect("teleportation_phasetwo", self, "Activate_Teleport_Phasetwo")
	Signals.connect("youwin", self, "ActivateTaunt")
	Signals.connect("youWinBoss", self, "MockBoss")
	
	# Play Voicelines
	audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	
	shuffleVoiceLines()
	#remainingVoiceLines = voiceLines
	
	$VoiceLineTimer.start()
	#playRandomVoiceLine()

func _exit_tree():
	Global.player = null



# Camera Settings
func update_camera_position(delta):
	# Get the Current camera position
	var camera_position = camera.global_position
	
	# Calculate the desired camera position based on the player's position and cursor position
	var player_position = global_position
	var camera_offset = Vector2(0, -20) # I might Adjust this value to change the camera offset
	
	# Calculate the desired camera position
	var desired_camera_position = player_position + camera_offset
	
	# Interpolate the Camera position to smoothly follow the player
	#camera_position = camera_position.linear_interpolate(desired_camera_position, CAMERA_MOVE_SPEED * delta / CAMERA_SMOOTHNESS)
	camera_position = camera_position.linear_interpolate(desired_camera_position, 0.1)
	
	# Set the camera position
	camera.global_position = camera_position



func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("Dash"):
			dash(move_direction)
			dash_shuffle.play()
			dash_shuffle_scream.play()
	



func _unhandled_input(event):
	if event.is_action_pressed("LeftClick"):
		scream.play()
		swing.play()
		Global.sword_damage = 8
		Global.life_steal = 1
		Global.boss_life_steal = 4
		moving = false
		attacking = true
		sword_pivot.rotation = get_angle_to(get_global_mouse_position())
		attack_direction = rad2deg(get_angle_to(get_global_mouse_position()))
		sword_range.set_deferred("disabled", false)
		set_process_unhandled_input(false)
#		yield(get_tree().create_timer(0.4), "timeout")
#		attacking = false
#		sword_range.set_deferred("disabled", true)
#		set_process_unhandled_input(true)
		
		#Attack()
		# For Ability Oriented
		match selected_skill:
			"Swordaoe":
				if current_mana >= 15:
					scream2.play()
					var skill_instance = nova.instance()
					skill_instance.position = sword_pivot.get_global_position()
					get_parent().add_child(skill_instance)
					Signals.emit_signal("activate_nova")
					sword_range.set_deferred("disabled", true)
					Global.sword_damage = 15
					Global.mana_cost = 15
					Global.mana_regeneration = 15
					Global.boss_mana_regen = 7
					if current_hp > 0 and current_hp < max_hp:
						Global.life_steal = 2
						Global.boss_life_steal = 7
					else:
						Global.life_steal = 0
						Global.boss_life_steal = 0
					Signals.emit_signal("reduce_mana_signal")
				else:
					Global.mana_regeneration = 0
					Global.boss_mana_regen = 0
					Signals.emit_signal("mana_warning_signal")
					Global.mana_insufficient = "Insufficient Mana!!!"
				
			"Ultimate":
				if current_mana >= 30:
					scream3.play()
					var skill_instance = supernova.instance()
					skill_instance.position = get_global_position()
					get_parent().add_child(skill_instance)
					sword_range.set_deferred("disabled", true)
					Global.sword_damage = 30
					Global.mana_cost = 30
					Global.mana_regeneration = 30
					Global.boss_mana_regen = 15
					if current_hp > 0 and current_hp < max_hp:
						Global.life_steal = 2
						Global.boss_life_steal = 7
					else:
						Global.life_steal = 0
						Global.boss_life_steal = 0
					Signals.emit_signal("supernova_screenshake")
					Signals.emit_signal("reduce_mana_signal")
				else:
					Global.mana_regeneration = 0
					Global.boss_mana_regen = 0
					Signals.emit_signal("mana_warning_signal")
					Global.mana_insufficient = "Insufficient Mana!!!"
			
		yield(get_tree().create_timer(0.4), "timeout")
		attacking = false
		sword_range.set_deferred("disabled", true)
		set_process_unhandled_input(true)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			is_aiming = true
			shooting = false
			#trying_to_shoot = true
			aim_direction = rad2deg(get_angle_to(get_global_mouse_position()))
		
		
		elif event.button_index == BUTTON_RIGHT and event.is_action_released("RightClick"):
			if can_shoot:
				is_aiming = false
				shooting = true
				shoot_direction = rad2deg(get_angle_to(get_global_mouse_position()))
				shoot_Bow()
				can_shoot = false
				set_process_unhandled_input(false)
				# Start a timer to reset the shooting cooldown
				yield(get_tree().create_timer(projectile_cooldown), "timeout")
				can_shoot = true
				set_process_unhandled_input(true)
				#is_aiming = false
				# Calculate the direction from the player to the mouse position
				#var direction = get_global_mouse_position() 
			
		elif event.button_index == BUTTON_RIGHT:
			is_aiming = true
			shooting = false
			yield(get_tree().create_timer(0.67), "timeout")
			if can_shoot:
				is_aiming = false
				shooting = true
				shoot_direction = rad2deg(get_angle_to(get_global_mouse_position()))
				shoot_Bow()
				can_shoot = false
				set_process_unhandled_input(false)
				# Start a timer to reset the shooting cooldown
				yield(get_tree().create_timer(projectile_cooldown), "timeout")
				can_shoot = true
				set_process_unhandled_input(true)
		else:
			is_aiming = false
			shooting = false



func _physics_process(delta):
	MovementLoop(delta)
	dashingAbility(delta)
	
	# For Health Regeneration
	if current_hp < max_hp:
		HpRegen(delta)
	

func _process(delta):
	AnimationLoop(delta)
	update_camera_position(delta)
	
	# For Mana Regeneration
	if current_mana < max_mana:
		ManaRegen(delta)

func MovementLoop(delta):
	var Right = Input.is_action_pressed("Right")
	var Left = Input.is_action_pressed("Left")
	var Up = Input.is_action_pressed("Up")
	var Down = Input.is_action_pressed("Down")
	move_direction.x = int(Right) - int(Left)
	move_direction.y = (int(Down) - int(Up)) / float(2)
	if Left || Right || Up || Down:
		facing = move_direction
		
		# For Creating a knockback effect on Enemy according player face direction
		sword_knockback.knockback_vector = facing
		Global.enemy_sword_knockback_vector = sword_knockback.knockback_vector
	
	if move_direction == Vector2(0,0) || Input.is_action_pressed("LeftClick") || attacking == true || is_aiming == true || shooting == true || player_is_dead == true:
		moving = false
		speed = 0
	else:
		moving = true
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		var motion = move_direction.normalized() * speed
		move_and_slide(motion)
		
	
	if moving == true:
		if not footstep.playing:
			footstep.play()
	else:
		footstep.stop()

# Sword Attack
#func Attack():
#	set_process_input(false)
#	yield(get_tree().create_timer(1), "timeout")
#	attacking = false
#	set_process_input(true)
	#anim_mode = "Idle"

# Shoot Bow
func shoot_Bow():
	#if can_shoot:
	releasing_arrow.play()
	get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
	# Create a new Projectile instance and add it to the scene
	var proj = projectile.instance()
		
	proj.position = get_node("TurnAxis/CastPoint").get_global_position()
	proj.rotation = get_angle_to(get_global_mouse_position())
	
	var angle_radians = deg2rad(proj.rotation)
	bow_direction = Vector2(cos(angle_radians), sin(angle_radians))
	
	# For Ability Oriented
	proj.skill_name = selected_skill
	
	Global.enemy_bow_knockback_vector = bow_direction
	
	#proj.velocity = direction.normalized() * projectile_speed
	get_parent().add_child(proj)
	# Start a timer to destroy the projectile after its lifetime expires
	#yield(get_tree().create_timer(projectile_lifetime), "timeout")
	#proj.queue_free()
	# Start a timer to reset the shooting cooldown
	#yield(get_tree().create_timer(projectile_cooldown), "timeout")
		
	#can_shoot = true
	#is_aiming = false
	yield(get_tree().create_timer(0.67), "timeout")
	shooting = false
	#trying_to_shoot = false
		



func AnimationLoop(delta):
	
	var animation
	anim_mode = "Idle"
	#var direction = direction2str(facing)
	var direction
	var attack_face_direction = Vector2()
	var aim_face_direction = Vector2()
	var shoot_face_direction = Vector2()
	
	if moving == true:
		anim_mode = "RunEmpty"
	elif moving == false:
		anim_mode = "Idle"
	if attacking:
		if attack_direction <= 15 and attack_direction >= -15:
			#attack_face_direction = "0"
			attack_face_direction = Vector2(1,0)
		elif attack_direction <= 60 and attack_direction >= 15:
			#attack_face_direction = "1"
			attack_face_direction = Vector2(1,0.5)
		elif attack_direction <= 120 and attack_direction >= 60:
			#attack_face_direction = "2"
			attack_face_direction = Vector2(0,0.5)
		elif attack_direction <= 165 and attack_direction >= 120:
			#attack_face_direction = "3"
			attack_face_direction = Vector2(-1,0.5)
		elif attack_direction >= -60 and attack_direction <= -15:
			#attack_face_direction = "7"
			attack_face_direction = Vector2(1,-0.5)
		elif attack_direction >= -120 and attack_direction <= -60:
			#attack_face_direction = "6"
			attack_face_direction = Vector2(0,-0.5)
		elif attack_direction >= -165 and attack_direction <= -120:
			#attack_face_direction = "5"
			attack_face_direction = Vector2(-1,-0.5)
		elif attack_direction <= -165 or attack_direction >= 165:
			#attack_face_direction = "4"
			attack_face_direction = Vector2(-1,0)
		
		facing = attack_face_direction
		
		anim_mode = "AttackSword"
		
	if is_aiming:
		if aim_direction <= 15 and aim_direction >= -15:
			#attack_face_direction = "0"
			aim_face_direction = Vector2(1,0)
		elif aim_direction <= 60 and aim_direction >= 15:
			#attack_face_direction = "1"
			aim_face_direction = Vector2(1,0.5)
		elif aim_direction <= 120 and aim_direction >= 60:
			#attack_face_direction = "2"
			aim_face_direction = Vector2(0,0.5)
		elif aim_direction <= 165 and aim_direction >= 120:
			#attack_face_direction = "3"
			aim_face_direction = Vector2(-1,0.5)
		elif aim_direction >= -60 and aim_direction <= -15:
			#attack_face_direction = "7"
			aim_face_direction = Vector2(1,-0.5)
		elif aim_direction >= -120 and aim_direction <= -60:
			#attack_face_direction = "6"
			aim_face_direction = Vector2(0,-0.5)
		elif aim_direction >= -165 and aim_direction <= -120:
			#attack_face_direction = "5"
			aim_face_direction = Vector2(-1,-0.5)
		elif aim_direction <= -165 or aim_direction >= 165:
			#attack_face_direction = "4"
			aim_face_direction = Vector2(-1,0)
		
		facing = aim_face_direction
		
		anim_mode = "AimBow"
		
		
		
		
	if shooting:
		if shoot_direction <= 15 and shoot_direction >= -15:
			#attack_face_direction = "0"
			shoot_face_direction = Vector2(1,0)
		elif shoot_direction <= 60 and shoot_direction >= 15:
			#attack_face_direction = "1"
			shoot_face_direction = Vector2(1,0.5)
		elif shoot_direction <= 120 and shoot_direction >= 60:
			#attack_face_direction = "2"
			shoot_face_direction = Vector2(0,0.5)
		elif shoot_direction <= 165 and shoot_direction >= 120:
			#attack_face_direction = "3"
			shoot_face_direction = Vector2(-1,0.5)
		elif shoot_direction >= -60 and shoot_direction <= -15:
			#attack_face_direction = "7"
			shoot_face_direction = Vector2(1,-0.5)
		elif shoot_direction >= -120 and shoot_direction <= -60:
			#attack_face_direction = "6"
			shoot_face_direction = Vector2(0,-0.5)
		elif shoot_direction >= -165 and shoot_direction <= -120:
			#attack_face_direction = "5"
			shoot_face_direction = Vector2(-1,-0.5)
		elif shoot_direction <= -165 or shoot_direction >= 165:
			#attack_face_direction = "4"
			shoot_face_direction = Vector2(-1,0)
		
		facing = shoot_face_direction
		
		anim_mode = "ShootBow"
	
	
	if player_is_dead:
		anim_mode = "Death"
	
	
	direction = direction2str(facing)
			
	animation = anim_mode + "_" + direction
	playerAnimation.play(animation)
	
	
	

func direction2str(direction):
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var a = round(angle / PI * 4)
	return str(a)


# Dashing ability Function
func dashingAbility(delta):
	var velocity = Vector2.ZERO
	
	# Check if the player is dashing and update velocity accordingly
	if dash_timer > 0:
		velocity = dash_direction.normalized() * dash_speed
		
	# Move the player using the updated velocity
	move_and_slide(velocity)
	
	# Update the dash timer and check if it has expired
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			dash_timer = 0
			can_dash = false
			$CollisionPolygon2D.set_deferred("disabled", false)
			set_process_input(false)
			#yield(get_tree().create_timer(dash_cooldown), "timeout")
			$DashingTimer.start()
#			can_dash = true
#			set_process_input(true)
			

# Dash Direction
func dash(direction):
	if can_dash:
		$CollisionPolygon2D.set_deferred("disabled", true)
		dash_timer = dash_duration
		dash_direction = direction
		set_process_input(true)
		
		
func reptile_hit():
	current_hp -= reptile_damage
	
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = reptile_damage
	text.type = "PlayerTakeDamage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		hp_regen = 0
		Global.life_steal = 0
		onPlayerDead()
		print("Player is Dead")
		

func hellbeast_hit():
	current_hp -= Global.hellbeast_damage
	
	# For floating text
	var text = floating_text.instance()
	text.position = floating_text_position.get_global_position()
	text.amount = Global.hellbeast_damage
	text.type = "PlayerTakeDamage"
	get_parent().add_child(text)
	
	if current_hp <= 0:
		current_hp = 0
		hp_regen = 0
		Global.boss_life_steal = 0
		onPlayerDead()
		print("Player is Dead")


func _on_Player_Hurtbox_area_entered(area):
	if area.is_in_group("RepAttack"):
		
		gethit.play()
		gethitScream.play()
		
		reptile_hit()
		#print("Player is Hit")
		Signals.emit_signal("player_got_hit")
		modulate = Color(1,0,0,1)
		player_hit_timer.start()
	#print(current_hp)
	
	if area.is_in_group("HellBeast_Damager"):
		
		gethit.play()
		gethitScream.play()
		
		hellbeast_hit()
		#print("Player is Hit")
		Signals.emit_signal("player_got_hit")
		modulate = Color(1,0,0,1)
		player_hit_timer.start()


func _on_Player_Hit_Timer_timeout():
	modulate = Color(1,1,1,1)
	
func Emit_signal_screenshake():
	emit_signal("player_hit_screenshake")
	

func HpRegen(delta):
	current_hp += hp_regen * delta
	
	if current_hp >= max_hp:
		current_hp = max_hp
	#print(current_hp)

# Ultimate Spell screenshake
func Activate_Shockwave():
	emit_signal("shockwave") 
	
# Reptile Got hit ScreenShake
func Reptile_Got_Hit_Screenshake():
	emit_signal("reptile_hit_screenshake")
	

# Mana Cost for Each Ability being used
func Reduced_Mana_amount():
	current_mana -= Global.mana_cost
	if current_mana <= 0:
		current_mana = 0

func ManaRegen(delta):
	current_mana += mana_regen * delta
	if current_mana >= max_mana:
		current_mana = max_mana
	

func Adding_life_steal():
	if current_hp < max_hp:
		current_hp += Global.life_steal
		
		# For floating text
		var text = floating_text.instance()
		text.position = floating_text_position.get_global_position()
		text.amount = Global.life_steal
		text.type = "Heal"
		get_parent().add_child(text)
		
		if current_hp >= max_hp:
			current_hp = max_hp
	#print(current_hp)


func Adding_boss_life_steal():
	if current_hp < max_hp:
		current_hp += Global.boss_life_steal
		
		# For floating text
		var text = floating_text.instance()
		text.position = floating_text_position.get_global_position()
		text.amount = Global.boss_life_steal
		text.type = "Heal"
		get_parent().add_child(text)
		
		if current_hp >= max_hp:
			current_hp = max_hp



func Mana_warning_function():
	var mana_text = mana_warning_text.instance()
	mana_text.position = mana_warning_text_position.get_global_position()
	mana_text.amount = Global.mana_insufficient
	get_parent().add_child(mana_text)


func Adding_Mana_Regeneration():
	if current_mana < max_mana:
		current_mana += Global.mana_regeneration
		
		# For floating text
		var text = floating_text.instance()
		text.position = floating_text_position.get_global_position()
		text.amount = Global.mana_regeneration
		text.type = "ManaRegen"
		get_parent().add_child(text)
		
		if current_mana >= max_mana:
			current_mana = max_mana


func Adding_Boss_Mana_Regen():
	if current_mana < max_mana:
		current_mana += Global.boss_mana_regen
		
		# For floating text
		var text = floating_text.instance()
		text.position = floating_text_position.get_global_position()
		text.amount = Global.boss_mana_regen
		text.type = "ManaRegen"
		get_parent().add_child(text)
		
		if current_mana >= max_mana:
			current_mana = max_mana


func onPlayerDead():
	player_is_dead = true
	deadScream.play()
	set_process_unhandled_input(false)
	#playerAnimation.play("Death_0")
	sword_range.set_deferred("disabled", true)
	player_attract.set_deferred("disabled", true)
	player_hurtbox.set_deferred("disabled", true)
	hellbeast_HitPoint.set_deferred("disabled", true)
	
	# For Particles
	var particle = bloods.instance()
	particle.position = global_position
	particle.rotation = global_rotation
	get_parent().add_child(particle)
	
	player_dead_timer.start()
	


func _on_Player_Dead_Timer_timeout():
	get_tree().change_scene("res://Scn/GameOver.tscn")


func _on_DashingTimer_timeout():
	can_dash = true
	set_process_input(true)

func Activate_Teleport():
	$TeleportTimer.start()


func _on_TeleportTimer_timeout():
	var teleporter = teleport.instance()
	teleporter.position = teleportPosition.get_global_position()
	get_parent().add_child(teleporter)

# Play RandomVoiceline
func playRandomVoiceLine():
	
	currentIndex += 1
	
	if currentIndex >= voiceLines.size():
		currentIndex = 0
	
	if !shouldPlayVoiceLines:
		return
	
	var voiceLine = voiceLines[currentIndex]
	print("Playing voice line: ", voiceLine)
	
	if player_is_dead == true or win == true or bossWin == true:
		shouldPlayVoiceLines = false
		return
	
	# Play the voice line using your audio system
	# For example, using AudioStreamPlayer2D:
	audioPlayer.stream = load("res://Assets/SFX/Voicelines/" + voiceLine + ".ogg")
	audioPlayer.play()
	
	
#	var delay = rand_range(3.0, 5.0)  # Adjust the delay range as needed
#	yield(get_tree().create_timer(delay), "timeout")
	$YieldDelay.start()


func shuffleVoiceLines():
	voiceLines.shuffle()



func _on_VoiceLineTimer_timeout():
	playRandomVoiceLine()


func _on_YieldDelay_timeout():
	playRandomVoiceLine()

func ActivateTaunt():
	win = true
	taunting.play()

func MockBoss():
	bossWin = true
	mock_boss.play()

func Activate_Teleport_Phasetwo():
	$TeleportPhasetwoTimer.start()
	print("teleportTImerStart")


func _on_TeleportPhasetwoTimer_timeout():
	print("Teleporting")
	var teleporter = tele_phase_two.instance()
	teleporter.position = teleportPosition.get_global_position()
	get_parent().add_child(teleporter)
