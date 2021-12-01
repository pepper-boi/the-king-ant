extends Area2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(_delta):
	if overlaps_body(player):
		ui.change_ui("EnemyTxtI'm Dead")
		ui.change_ui("Text")
		ui.change_ui("Ending")
		get_tree().paused = true
		queue_free()
