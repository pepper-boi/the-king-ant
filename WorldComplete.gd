#WorldComplete.gd
extends Area2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

onready var sprite = $Sprite
onready var e = $Label

export(String) var next_scene = ""
export(Vector2) var next_scene_pos = Vector2.ZERO

var on = false

func _physics_process(_delta):
	if overlaps_body(player):
		player.lever = true
		if Input.is_action_just_pressed("Use"):
			ui.next_scene_pos = next_scene_pos
			ui.change_ui("NewScene" + "res://" + next_scene + ".tscn")
		else:
			e.modulate.a = lerp(e.modulate.a,1,0.1)
	else:
		e.modulate.a = lerp(e.modulate.a,0,0.1)
		player.lever = false
