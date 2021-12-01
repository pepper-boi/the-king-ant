extends Sprite

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var e = $TextBox

var used = false

func _physics_process(_delta):
#	if position.distance_to(player.position) < 60:
#
	if position.distance_to(player.position) < 80 and Input.is_action_just_pressed("Use") and not player.lever and not player.hurt and not player.dead and not used:
		e.modulate.a = lerp(e.modulate.a,1,0.1)
		used = true
		ui.change_ui("Text")
		ui.change_ui("Queen")
		get_tree().paused = true
	elif position.distance_to(player.position) < 80 and not player.lever and not player.lever and not player.hurt and not player.dead:
		e.modulate.a = lerp(e.modulate.a,1,0.1)
	else:
		e.modulate.a = lerp(e.modulate.a,0,0.15)
