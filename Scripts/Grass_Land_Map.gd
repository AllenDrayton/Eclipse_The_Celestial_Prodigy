extends Node2D


onready var playerPosition = $MainYSort/Player/Player
onready var enemyYSort  = $MainYSort/Enemies

var Reptiles = preload("res://Scn/Reptile.tscn")
var Reptiles2 = preload("res://Scn/Reptile2.tscn")
var Boss = preload("res://Scn/HellBeast.tscn")
var enemySpawner = preload("res://Scn/EnemySpawner.tscn")

onready var position1 = $Position1
onready var position2 = $Position2
onready var position3 = $Position3
onready var position4 = $Position4

const ENEMY_SPAWN_POSITIONS = [
	Vector2(100, 100),
	Vector2(300, 300),
	Vector2(500, 500),
	Vector2(700, 700),
	Vector2(900, 900),
	Vector2(-100, 100),
	Vector2(-300, 300),
	Vector2(-500, 500),
	Vector2(-700, 700),
	Vector2(-900, 900)
	
]


var enemyCount = 5
var waveCount = 0
var variantCount = 10
var isBossDefeated = false


func _ready():
	Global.node_creation_parent = self
	
	Signals.connect("enemy_defeated", self, "onEnemyDefeated")
	Signals.connect("variant_defeated", self, "variantDefeated")
	
	spawnWave()
	

func _exit_tree():
	Global.node_creation_parent = null

func _physics_process(delta):
	position1.global_position = Global.player.global_position + Vector2(-819, -537)
	position2.global_position = Global.player.global_position + Vector2(-839, 588)
	position3.global_position = Global.player.global_position + Vector2(914, 647)
	position4.global_position = Global.player.global_position + Vector2(782, -579)
	


func spawnWave():
	if isBossDefeated:
		return
		
	$ReptileSpawnTimer.start()
	


func onEnemyDefeated():
	enemyCount -= 1
	print("Enemy Count", enemyCount)
	if enemyCount == 0:
		spawnVariant()


func variantDefeated():
	variantCount -= 1
	if variantCount == 0:
		spawnBoss()


func spawnVariant():
	
	$VariantSpawnTimer.start()
	
#	for i in range(variantCount):
#		var variantInstance = Reptiles2.instance()
#		variantInstance.position = ENEMY_SPAWN_POSITIONS[i]
#
#		enemyYSort.add_child(variantInstance)
	


func spawnBoss():
	#yield(get_tree().create_timer(2.0), "timeout")
	$BossSpawnTimer.start()
	
#	var bossInstance = Boss.instance()
#
#	Signals.connect("boss_defeated", self, "onBossDefeated")
#
#	enemyYSort.add_child(bossInstance)

func onBossDefeated():
	isBossDefeated = true
	Signals.emit_signal("youWinBoss")
	Signals.emit_signal("teleportation_phasetwo")


func _on_VariantSpawnTimer_timeout():
	for i in range(variantCount):
		var variantInstance = Reptiles2.instance()
		var spawnGas = enemySpawner.instance()
		variantInstance.position = ENEMY_SPAWN_POSITIONS[i]
		spawnGas.position = ENEMY_SPAWN_POSITIONS[i]
		
		enemyYSort.add_child(variantInstance)
		enemyYSort.add_child(spawnGas)


func _on_BossSpawnTimer_timeout():
	var bossInstance = Boss.instance()
	
	Signals.connect("boss_defeated", self, "onBossDefeated")
	
	enemyYSort.add_child(bossInstance)


func _on_ReptileSpawnTimer_timeout():
	
	for i in range(enemyCount):
		var enemyInstance = Reptiles.instance()
		var spawnGas = enemySpawner.instance()
		enemyInstance.position = ENEMY_SPAWN_POSITIONS[i]
		spawnGas.position = ENEMY_SPAWN_POSITIONS[i]
		
		enemyYSort.add_child(enemyInstance)
		enemyYSort.add_child(spawnGas)
		
	waveCount += 1
	#print("Wave Count", waveCount)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ExitFullScreen"):
		OS.set_window_fullscreen(false)


