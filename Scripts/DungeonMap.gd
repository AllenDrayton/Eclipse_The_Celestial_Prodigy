extends Node2D

var Reptiles = preload("res://Scn/Reptile.tscn")
var Reptiles2 = preload("res://Scn/Reptile2.tscn")
var Boss = preload("res://Scn/HellBeast.tscn")
var enemySpawner = preload("res://Scn/EnemySpawner.tscn")
onready var enemyYSort = $MainYSort/Enemies

const ENEMY_SPAWN_POSITIONS = [
	Vector2(100, 100),
	Vector2(300, 300),
	Vector2(500, 500),
	Vector2(700, 700),
	Vector2(900, 900),
	Vector2(-100, 100),
	Vector2(-300, 300),
	Vector2(-500, 500),
	Vector2(477, 1750),
	Vector2(2210, 1034)
	
]


var enemyCount = 5
var variantCount = 10
var waveCount = 0
var isVariantDefeated = false

func _ready():
	Global.node_creation_parent = self
	
	Signals.connect("enemy_defeated", self, "onEnemyDefeated")
	Signals.connect("variant_defeated", self, "variantDefeated")
	
	spawnWave()
	
	

func _exit_tree():
	Global.node_creation_parent = null


func spawnWave():
	if isVariantDefeated:
		return
		
	$ReptileSpawntimer.start()

func onEnemyDefeated():
	enemyCount -= 1
	print("Enemy Count", enemyCount)
	if enemyCount == 0:
		spawnVariant()
		


func variantDefeated():
	variantCount -= 1
	if variantCount == 0:
		Signals.connect("variant_all_dead", self, "onVariantDefeated")
		Signals.emit_signal("teleportation_ready")
		Signals.emit_signal("youwin")


func spawnVariant():
	$VariantSpawntimer.start()
	
	

func onVariantDefeated():
	isVariantDefeated = true
	#Signals.emit_signal("teleportation_ready")



func _on_VariantSpawntimer_timeout():
	for i in range(variantCount):
		var variantInstance = Reptiles2.instance()
		var spawnGas = enemySpawner.instance()
		variantInstance.position = ENEMY_SPAWN_POSITIONS[i]
		spawnGas.position = ENEMY_SPAWN_POSITIONS[i]
		
		enemyYSort.add_child(variantInstance)
		enemyYSort.add_child(spawnGas)


func _on_ReptileSpawntimer_timeout():

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


