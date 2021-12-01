extends Node2D

onready var anim_player = $AnimationPlayer
onready var anim_player2 = $UiLayer/AnimationPlayer
onready var fake_player = $CanvasLayer/GameOffCharacter
onready var lights = $Node2D
onready var speak_label = $UiLayer/UiTextBox/Label
onready var text_box = $UiLayer/UiTextBox
onready var sound_manager = $Song

var restarted = false
var ending = false

var next_scene = "res://World.tscn"
var next_scene_pos = Vector2(-280,208)

func change_ui(type:String):
	match type:
		"Restart":
			anim_player.play("RestartText")
			restarted = true
		"Text":
			anim_player2.play("TextAppear")
		"TextDone":
			anim_player2.play("TextDone")
			if ending:
				anim_player.play("NextScene")
		"Ending":
			ending = true
		"SoundEnding":
			sound_manager.volume_db = -10
			sound_manager.play(0)
		var string:
			if string.begins_with("EnemyTxt"):
				string.erase(0,8)
				speak_label.text = string
			if string.begins_with("NewScene"):
				string.erase(0,8)
				next_scene = string
				anim_player.play("NextScene")

func _input(event):
	if restarted:
		if event is InputEventKey and event.pressed:
			anim_player.play("NextScene")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "NextScene":
		if not ending:
			anim_player.play("BackwardNextScene")
			var _idk = get_tree().change_scene(next_scene)
	#		get_tree().get_nodes_in_group("Player")[0].queue_free()
			Engine.time_scale = 1
			restarted = false
			fake_player.hide()
			lights.show()
		else:
			anim_player.play("TheEnd")

func CrouchSound():
	sound_manager.crouch.playing = true

func AlarmedSound():
	sound_manager.alarmed.play()

func JumpUpSound():
	sound_manager.jump_up.play()

func JumpLandSound():
	sound_manager.jump_land.play()

func VictorySound():
	sound_manager.victory.play()
