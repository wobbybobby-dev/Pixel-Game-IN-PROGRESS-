extends Node2D

var story_data
var current_scene = "start"
var current_choices = []
var waiting_for_choice = false
var pending_choices = []
var game_over = false

@onready var textbox = get_parent().get_node("textbox")
@onready var choice_row = textbox.get_node("TextboxContainer/MarginContainer/VBoxContainer/ChoiceRow")
@onready var choice1 = choice_row.get_node("Choice1")
@onready var choice2 = choice_row.get_node("Choice2")

func load_story():
	var file = FileAccess.open("res://story.json", FileAccess.READ)
	if file == null:
		print("ERROR: story.json not found!")
		return
	var content = file.get_as_text()
	story_data = JSON.parse_string(content)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_story()
	textbox.dialogue_finished.connect(_on_dialogue_finished)
	choice1.pressed.connect(func(): select_choice(0))
	choice2.pressed.connect(func(): select_choice(1))
	choice_row.hide()
	load_scene(current_scene)

func _on_dialogue_finished():
	var scene = story_data[current_scene]
	
	if waiting_for_choice:
		return
	if pending_choices.size() > 0:
		display_choices(pending_choices)
		pending_choices = []
		return
	if "choices" in scene:
		pending_choices=(scene["choices"])
		textbox.queue_text("Which path will you take?")
	elif "ending" in scene:
		print("ENDING:", scene["ending"])
		game_over = true 
		textbox.hide_textbox()

func display_choices(choices):
	current_choices = choices
	waiting_for_choice = true
	
	choice1.text = choices[0]["text"]
	choice2.text = choices[1]["text"]
	
	choice_row.show()
	
	# fade in
	choice_row.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(choice_row, "modulate:a", 1.0, 0.4)

func load_scene(scene_id):
	var scene = story_data[scene_id]
	choice_row.hide()
	waiting_for_choice = false
	
	textbox.queue_text(scene["text"])     # send text to your textbox system

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#temporary, to be modfified
	if waiting_for_choice:
		if Input.is_action_just_pressed("ui_left"):
			select_choice(0)
		elif Input.is_action_just_pressed("ui_right"):
			select_choice(1)
	return

func select_choice(index):
	waiting_for_choice = false
	choice_row.hide()
	var next_scene = current_choices[index]["next"]
	current_scene = next_scene
	textbox.change_state(textbox.State.READY)       # FORCE textbox to continue automatically
	load_scene(current_scene)
