extends Node2D

var player
export (NodePath) onready var fake_player = get_node(fake_player)

onready var anim_player = $AnimationPlayer

var death_done = false

func _physics_process(_delta):
	if is_instance_valid(player):
#		if Input.is_action_pressed("ui_up") and not player.hurt and not death_done:
#			position = lerp(position,player.position+Vector2.UP*17,0.1)
#		elif Input.is_action_pressed("ui_down") and not player.hurt and not death_done:
#			position = lerp(position,player.position-Vector2.UP*4,0.1)
#		else:
		position = lerp(position,player.position+Vector2.UP*8,0.1)
		if player.hurt and not death_done:
			anim_player.play("PlayerDeath")
			death_done = true
			z_index = 20
	elif get_tree().get_nodes_in_group("Player").size()>0:
		player = get_tree().get_nodes_in_group("Player")[0]
		death_done = false
		position = player.position
