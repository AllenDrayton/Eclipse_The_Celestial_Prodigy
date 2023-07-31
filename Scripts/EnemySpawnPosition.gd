extends Node2D

var Reptiles = preload("res://Scn/Reptile.tscn")
var Boss = preload("res://Scn/HellBeast.tscn")

onready var position1 = $Position1
onready var position2 = $Position2
onready var position3 = $Position3
onready var position4 = $Position4

const ENEMY_SPAWN_POSITIONS = [
	Vector2(100, 100),
	Vector2(300, 300),
	Vector2(500, 500),
	Vector2(700, 700),
	Vector2(900, 900)
]

onready var spawnTimer = $SpawnTimer

var enemyCount = 4
var waveCount = 0
var isBossDefeated = false

func _ready():
	Signals.connect("enemy_defeated", self, "onEnemyDefeated")
	
	spawnWave()


func _physics_process(delta):
	position1.global_position = Global.player.global_position + Vector2(-819, -537)
	position2.global_position = Global.player.global_position + Vector2(-839, 588)
	position3.global_position = Global.player.global_position + Vector2(914, 647)
	position4.global_position = Global.player.global_position + Vector2(782, -579)
	


func spawnWave():
	if isBossDefeated:
		return
		
	yield(get_tree().create_timer(2.0), "timeout")
	for i in range(enemyCount):
		var enemyInstance = Reptiles.instance()
		enemyInstance.position = ENEMY_SPAWN_POSITIONS[i]
		#enemyInstance.z_index = enemyInstance.position.y # Set the z_index based on y-position
#		var nodes = get_tree().get_nodes_in_group("Spawn")
#		var node = nodes[randi() % nodes.size()]
#		var nodePosition = node.global_position
#		enemyInstance.position = nodePosition 
		
		add_child(enemyInstance)
		
	waveCount += 1
	print("Wave Count", waveCount)


func onEnemyDefeated():
	enemyCount -= 1
	print("Enemy Count", enemyCount)
	if enemyCount == 0:
		if waveCount < 2:
			enemyCount = 4
			spawnWave()
		else:
			spawnBoss()
			

func spawnBoss():
	yield(get_tree().create_timer(2.0), "timeout")
	var bossInstance = Boss.instance()
	#bossInstance.z_index = bossInstance.position.y # Set the z_index based on y-position
	bossInstance.position = position3.position
	Signals.connect("boss_defeated", self, "onBossDefeated")
	
	
#	var nodes = get_tree().get_nodes_in_group("Spawn")
#	var node = nodes[randi() % nodes.size()]
#	var nodePosition = node.global_position
#	bossInstance = nodePosition 
	
	get_parent().add_child(bossInstance)

func onBossDefeated():
	isBossDefeated = true
