extends Area2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(_delta):
	if overlaps_body(player):
		player.ladder = true
	else:
		player.ladder = false
