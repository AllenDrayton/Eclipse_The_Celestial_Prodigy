extends Node

var node_creation_parent = null
var player = null
var reptile = null
var hellbeast = null
var enemy_sword_knockback_vector = Vector2.ZERO
var enemy_bow_knockback_vector = Vector2.ZERO

var arrow_damage = 10
var sword_damage = 8
export var reptile_attack_damage = 5
var hellbeast_damage = 5
var mana_cost
var mana_regeneration
var boss_mana_regen
var life_steal = 2
var boss_life_steal
var mana_insufficient = "Insufficient Mana!!!"

func instance_node(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance

