extends Area2D

enum move_sides {MOVE_LEFT,MOVE_RIGHT,MOVE_BOTH}
export (move_sides) var move_dir

var enemies = []

func _ready():
	hide()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy"):
		if not enemies.has(body):
			enemies.append(body)

func _physics_process(_delta):
	for i in enemies:
		if overlaps_body(i):
			if i.x_move_dir < 0 and move_dir == move_sides.MOVE_LEFT or i.x_move_dir > 0 and move_dir == move_sides.MOVE_RIGHT or move_dir == move_sides.MOVE_BOTH:
				i.jump()
