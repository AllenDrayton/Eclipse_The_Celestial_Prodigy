extends CanvasLayer

onready var health_globe = get_node("Player_Health_Globe/GlobeFull/TextureProgress")
onready var health_globe_tween = get_node("Player_Health_Globe/GlobeFull/TextureProgress/Tween")
onready var health_label = get_node("Player_Health_Globe/Health_Label/Label")

onready var mana_globe = get_node("Player_Mana_Globe/GlobeFull/TextureProgress")
onready var mana_globe_tween = get_node("Player_Mana_Globe/GlobeFull/TextureProgress/Tween")
onready var mana_label = get_node("Player_Mana_Globe/Mana_Label/Label")

# For Ability Oriented
onready var shortcuts_path = "SkillBar/Skill_UI_Two/HBoxContainer/"
onready var selected_skill_path = "SkillBar/Skill_UI_One/HBoxContainer/TextureRect"

var loaded_skills = {"Shortcut1" : "Taoe", "Shortcut2" : "Swordaoe", "Shortcut3" : "Fireball", "Shortcut4" : "Ultimate"}

func _ready():
	# For Health
	health_globe.max_value = Global.player.max_hp
	health_globe.value = Global.player.max_hp
	
	# For Mana
	mana_globe.max_value = Global.player.max_mana
	mana_globe.value = Global.player.max_mana
	
	# For Ability Oriented
	LoadShortcuts()
	for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
		shortcut.connect("pressed", self, "SelectedShortcut", [shortcut.get_parent().get_name()])


func LoadShortcuts():
	for shortcut in loaded_skills.keys():
		var skill_icon = load("res://Assets/Skills/" + loaded_skills[shortcut] + "_icon.png")
		get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(skill_icon)

func SelectedShortcut(shortcut):
	var skill_icon = load("res://Assets/Skills/" + loaded_skills[shortcut] + "_icon.png")
	get_node(selected_skill_path).set_texture(skill_icon)
	Global.player.selected_skill = loaded_skills[shortcut]


func _process(delta):
	UpdateGlobes()
	health_label.set_text(str(int(Global.player.current_hp)))
	
	UpdateManaGlobes()
	mana_label.set_text(str(int(Global.player.current_mana)))
	
func UpdateGlobes():
	var new_hp = Global.player.current_hp
	health_globe_tween.interpolate_property(health_globe, 'value', health_globe.value, new_hp, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	health_globe_tween.start()
	

func UpdateManaGlobes():
	var new_mana = Global.player.current_mana
	mana_globe_tween.interpolate_property(mana_globe, 'value', mana_globe.value, new_mana, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	mana_globe_tween.start()
