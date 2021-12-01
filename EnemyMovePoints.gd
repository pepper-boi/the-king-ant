extends Node2D

var children = []

func _ready():
	for i in get_children():
		children.append(i)

