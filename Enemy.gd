extends KinematicBody2D

const GRAVITY = 300
const JUMP_HIGHT = 155
const MAX_SPD = 80

enum move_types {PATROL,ATTACK,FOLLOW,SUPRISED}

export (NodePath) onready var player = get_node(player) as KinematicBody2D
export (String) onready var enemy_text

onready var sprite = $icon
onready var sight = $EnemySight
onready var coll_obj = $CollisionShape2D
onready var area2d = $Area2D
onready var light_area = $Area2D2
onready var attack_area = $Area2D3
onready var raycast = $RayCast2D
onready var raycast2 = $RayCast2D2
onready var raycast3 = $RayCast2D3
onready var ground_raycast = $RayCast2D4
onready var anim_player = $AnimationPlayer
onready var anim_player2 = $AnimationPlayer/AnimationPlayer2
onready var timer = $Timer
onready var e = $TextBox
onready var tilemap = TileMap.new()

var motion = Vector2.ZERO
var x_move_dir = 0
var move_left = false
var closest = false
var used = false
var cur_type = move_types.PATROL

func _physics_process(_delta):
#	if cur_type == move_types.PATROL:
	scale.x = 1
	anim_player.play("Patrol")
	anim_player2.play("Sight")
	if light_area.overlaps_body(player):
		ui.AlarmedSound()
		cur_type = move_types.SUPRISED
		anim_player.stop()
		timer.start(1)
	
	if not ground_raycast.is_colliding():
		area_collided(tilemap)
	if move_left:
		motion.x = lerp(motion.x,-1*float(MAX_SPD)/2.5,0.1)
		light_area.position.x = -16
	else:
		motion.x = lerp(motion.x,1*float(MAX_SPD)/2.5,0.1)
		light_area.position.x = 16
#	if cur_type == move_types.FOLLOW:
#		scale.x = 1
#		anim_player.play("AngryRun")
#		anim_player2.play("Sight")
#		raycast.cast_to = -(raycast.global_position - (player.global_position))
#		raycast2.cast_to = -(raycast2.global_position - (player.global_position+Vector2.UP*26))
#		raycast3.cast_to = -(raycast3.global_position - (player.global_position+Vector2.UP*12))
#		if not raycast.is_colliding() or not raycast2.is_colliding() or not raycast3.is_colliding():
#			if Vector2(position.x,0).distance_to(Vector2(player.position.x,0)) > 10:
#				motion.x += -(position.x - player.position.x)
#				x_move_dir = motion.x
#				motion.x = clamp(motion.x,-MAX_SPD,MAX_SPD)
#			elif not is_on_floor():
#				motion.x += -(position.x - player.position.x)
#				x_move_dir = motion.x
#				motion.x = clamp(motion.x,-float(MAX_SPD)/3,float(MAX_SPD)/3)
#			else:
#				motion.x = lerp(motion.x,0,.1)
#				if abs(motion.x) <= 20:
#					attack()
#			var self_yet = false
#			for i in get_tree().get_nodes_in_group("Enemy"):
#				if i == self:
#					self_yet = true
#				elif self_yet:
#					if position.distance_to(i.position) < 20:
#						motion.x /= 2
#		else:
#			motion.x = lerp(motion.x,0,.1)
#		if stepify(-(position.x - player.position.x),10) != 0:
#			sprite.flip_h = -(position.x - player.position.x) < 0
#	if cur_type == move_types.ATTACK:
#		match sprite.flip_h:
#			true:
#				attack_area.position.x = -7
#			false:
#				attack_area.position.x = 7
#		if sprite.frame == 22 or sprite.frame == 23:
#			if attack_area.overlaps_body(player) and not player.hurt and not player.dead:
#				player.die(-(attack_area.position.x))
#	if cur_type == move_types.SUPRISED:
#		motion.x = 0
#		sprite.frame = 0
#		suprised.show()
#	else:
#		suprised.hide()
#	if player.hurt:
#		sight.modulate.a -= 0.005
	if position.distance_to(player.position) < 48 and Input.is_action_just_pressed("Use") and not player.lever and not player.hurt and not player.dead and closest and not used:
		e.modulate.a = lerp(e.modulate.a,1,0.1)
		used = true
		ui.change_ui("Text")
		ui.change_ui("EnemyTxt" + enemy_text)
		get_tree().paused = true
	elif position.distance_to(player.position) < 48 and not player.lever and not player.lever and not player.hurt and not player.dead and closest and not used:
		e.modulate.a = lerp(e.modulate.a,1,0.1)
	else:
		e.modulate.a = lerp(e.modulate.a,0,0.15)
	motion.y += GRAVITY*_delta
	sight.flip_h = sprite.flip_h
	motion = move_and_slide(motion,Vector2.UP)

func jump():
	if is_on_floor() and (not raycast.is_colliding() or not raycast2.is_colliding() or not raycast3.is_colliding()):
		motion.y -= JUMP_HIGHT

func area_collided(_body):
	if is_on_floor() and (_body is TileMap or _body.is_in_group("Enemy")):
		ground_raycast.position.x = -ground_raycast.position.x
		coll_obj.position.x = -coll_obj.position.x
		area2d.position.x = -area2d.position.x
		sprite.flip_h = !sprite.flip_h
		move_left = !move_left

func attack():
	anim_player.play("Attack")
	motion.x = 0
	cur_type = move_types.ATTACK

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		cur_type = move_types.FOLLOW

func timeout():
	cur_type = move_types.FOLLOW
