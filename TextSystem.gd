extends Sprite

onready var timer = $Timer
onready var label = $Label

var completed = false
var queen = false
export (Array,String) var queen_text
var queen_text_num = 0

func letter_appear():
	if label.get_total_character_count() > label.visible_characters:
		label.visible_characters += 1
		timer.start(0.025)
	else:
		completed = true

func set_queen():
	queen = true
	queen_text_num = 0
	label.text = queen_text[0]

func _input(_event):
	if Input.is_action_just_pressed("Use"):
		if not completed:
			label.visible_characters = label.get_total_character_count()
		else:
			if not queen or queen_text_num+1 >= queen_text.size():
				completed = false
				queen = false
				ui.change_ui("TextDone")
				timer.stop()
			else:
				label.visible_characters = 0
				queen_text_num += 1
				label.text = queen_text[queen_text_num]
				completed = false
				timer.start(0.025)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TextAppear":
		timer.start(0.1)
	if anim_name == "TextDone":
		get_tree().paused = false
