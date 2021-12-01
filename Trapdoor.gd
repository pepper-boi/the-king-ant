extends StaticBody2D

onready var collision_shape = $CollisionShape2D
onready var sprite = $Sprite

#func _input(_event):
#	if Input.is_action_just_pressed("Crouch"):
#		open()

func open():
	collision_shape.disabled = true
	sprite.frame = 1

func close():
	collision_shape.disabled = false
	sprite.frame = 0
