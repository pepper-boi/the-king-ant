extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 80
const FRICTION = 0.25
const AIR_RESISTANCE = 0.07
const GRAVITY = 300
const JUMP_FORCE = 145
const CROUCH_FORCE = 300

var sprint_speed = 100
var crouch_speed = 30

var jump_pressed = false
var can_jump = true
var was_on_floor = false
var crouch = false
var hurt = false
var dead = false
var lever = false
var ladder = true

var motion = Vector2.ZERO

onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var anim_player2 = $AnimationPlayer/AnimationPlayer
onready var buffer_timer = $BufferTimer
onready var coyote_timer = $CoyoteTimer
onready var stand_collision = $CollisionShape2D
onready var crouch_collision = $CollisionShape2D2
onready var raycast1 = $RayCast2D
onready var raycast2 = $RayCast2D2

func _ready():
	position = ui.next_scene_pos

func _physics_process(delta):
	if hurt:
		if is_on_floor():
			motion.x = lerp(motion.x, 0, FRICTION)
			if abs(motion.x) < 20:
				anim_player.play("HurtDead")
				motion.x = 0
		elif abs(motion.y) < 40:
			anim_player.play("HurtMid")
		elif motion.y < 0:
			anim_player.play("HurtUp")
		elif motion.y > 0:
			anim_player.play("HurtDown")
			anim_player2.play("PlayerDead")
		motion.y += GRAVITY * delta
		motion = move_and_slide(motion,Vector2.UP)
		return
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input != 0:
		if not crouch:
			motion.x += x_input * ACCELERATION * delta
		else:
			motion.x = x_input * crouch_speed
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
	motion.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("ui_up"):
		jump_pressed = true
	if crouch and is_on_floor() and not motion.x == 0:
		if not ui.sound_manager.crouch.playing:
			ui.CrouchSound()
#	if Input.is_action_pressed("Sprint"):
#		motion.x = x_input * sprint_speed
	if can_jump and jump_pressed:
		ui.JumpUpSound()
		jump_pressed = false
		buffer_timer.stop()
		motion.y = -JUMP_FORCE
	if Input.is_action_pressed("Crouch"):
		stand_collision.disabled = true
		crouch = true
	elif stand_collision.disabled and !raycasts_colliding():
		stand_collision.disabled = false
		crouch = false
#	elif not crouch:
#		sprite.scale.y = lerp(sprite.scale.y,1,0.2)
#		sprite.position.y = lerp(sprite.position.y,-15,0.2)
	if is_on_floor():
		was_on_floor = true
		can_jump = true
		
		if x_input != 0:
			if not crouch:
				anim_player.play("Run")
			else:
				anim_player.play("CrouchWalk")
		elif motion.distance_to(Vector2.ZERO) < 10:
			if not crouch:
				anim_player.play("Idle")
			else:
				anim_player.play("CrouchIdle")
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
	else:
		if motion.y < 0:
			anim_player.play("JumpUp")
		if motion.y > 0:
			anim_player.play("JumpDown")
		if was_on_floor and motion.y > 0:
			coyote_timer.start(0.1)
		elif was_on_floor and motion.y < 0:
			can_jump = false
		was_on_floor = false
		if Input.is_action_just_released("ui_up"):
			buffer_timer.start(0.1)
	
		if not Input.is_action_pressed("ui_up") and motion.y < -JUMP_FORCE/2.0:
			motion.y = -JUMP_FORCE/2.0
	
		if Input.is_action_pressed("Crouch"):
			motion.y += CROUCH_FORCE*delta
	
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)
	var closest
	var closest_var = 10000
	for i in get_tree().get_nodes_in_group("Enemy"):
		if position.distance_to(i.position) < closest_var and not i.used:
			closest = i
			closest_var = position.distance_to(i.position)
		else:
			i.closest = false
	if is_instance_valid(closest):
		closest.closest = true
	motion = move_and_slide(motion, Vector2.UP)
	for i in get_slide_count():
		if get_slide_collision(i).collider.is_in_group("Spike"):
			die(get_slide_collision(i).position.x - position.x)
	if raycasts_spike() and not Input.is_action_pressed("Crouch"):
		die(10)

func bufferTimer():
	jump_pressed = false

func coyoteTimer():
	can_jump = false

func raycasts_colliding():
	return raycast1.is_colliding() or raycast2.is_colliding()

func raycasts_spike():
	var spike_collide = false
	if raycast1.is_colliding():
		if raycast1.get_collider().is_in_group("Spike"):
			spike_collide = true
	if raycast2.is_colliding():
		if raycast2.get_collider().is_in_group("Spike"):
			spike_collide = true
	return spike_collide

func die(speed):
	hurt = true
	z_index = 16
	crouch = false
	if speed > 0:
		sprite.flip_h = false
		motion.x = -80
	else:
		sprite.flip_h = true
		motion.x = 80
	motion.y = -100
	Engine.time_scale = 0.4

func dead_restart():
	var _idk = get_tree().reload_current_scene()

func _on_AnimationPlayer_animation_changed(_old_name, new_name):
	if new_name == "Hurt":
		dead = true

func _on_AnimationPlayer_animation_finished(_anim_name):
	if _anim_name == "HurtDead":
		get_tree().current_scene.hide()
		get_tree().get_nodes_in_group("FakePlayer")[0].transform = sprite.get_global_transform_with_canvas()
		get_tree().get_nodes_in_group("FakePlayer")[0].flip_h = sprite.flip_h
		get_tree().get_nodes_in_group("FakePlayer")[0].show()
		get_tree().get_nodes_in_group("Light")[0].get_parent().position = Vector2(160,90-8)
		ui.change_ui("Restart")
		get_tree().queue_delete(get_tree().current_scene)
