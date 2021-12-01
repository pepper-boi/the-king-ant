extends Area2D

export (NodePath) onready var player = get_node(player) as KinematicBody2D
export (NodePath) onready var trapdoor = get_node(trapdoor)

onready var sprite = $Sprite
onready var e = $Label

var on = false

func _physics_process(_delta):
	if overlaps_body(player):
		player.lever = true
		if Input.is_action_just_pressed("Use"):
			if not on:
				trapdoor.open()
				sprite.frame += 1
			else:
				trapdoor.close()
				sprite.frame -= 1
			on = !on
		else:
			e.modulate.a = lerp(e.modulate.a,1,0.1)
	else:
		e.modulate.a = lerp(e.modulate.a,0,0.1)
		player.lever = false
