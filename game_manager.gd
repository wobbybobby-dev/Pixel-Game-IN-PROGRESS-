extends Node2D

var story_data
var current_scene = "start"
#temporary
var current_choices = []
var waiting_for_choice = false

@onready var textbox = get_parent().get_node("textbox")

func load_story():
	var file = FileAccess.open("res://story.json", FileAccess.READ)
	var content = file.get_as_text()
	story_data = JSON.parse_string(content)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_story()
	load_scene(current_scene)
	textbox.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished():
	var scene = story_data[current_scene]
	
	if "choices" in scene:
		show_choices(scene["choices"])
	elif "ending" in scene:
		print("ENDING:", scene["ending"])

func show_choices(choices):
	current_choices = choices
	waiting_for_choice = true
	for i in range(choices.size()):
		print(str(i+1) + ": " + choices[i]["text"])

func load_scene(scene_id):
	var scene = story_data[scene_id]
	# send text to your textbox system
	textbox.queue_text(scene["text"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#temporary, to be modfified
	if waiting_for_choice:
		if Input.is_action_just_pressed("ui_left"):
			select_choice(0)
		elif Input.is_action_just_pressed("ui_right"):
			select_choice(1)

#temporary
func select_choice(index):
	waiting_for_choice = false
	var next_scene = current_choices[index]["next"]
	current_scene = next_scene
	load_scene(current_scene)
