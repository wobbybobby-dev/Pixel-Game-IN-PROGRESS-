extends CanvasLayer

signal dialogue_finished

const CHAR_READ_RATE = 0.05
var tween: Tween

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/end
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label2


func _ready() -> void:
	print("Starting State: State.READY")
	hide_textbox()

enum State{
	READY,
	READING,
	FINISHED
}
var current_state=State.READY
var text_queue = []

func _process(delta: float) -> void:
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.visible_ratio = 1.0
				if tween:
					tween.kill()
					end_symbol.text = ">"
					change_state(State.FINISHED)
				
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !text_queue.is_empty():
					change_state(State.READY)
				else:
					hide_textbox()
					emit_signal("dialogue_finished")

func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0
	change_state(State.READING)
	show_textbox()
	
	end_symbol.text = ""   # hide end symbol before completion of text
	
	label.visible_ratio=0.0
	tween = create_tween()
	var duration=float(len(next_text)) * CHAR_READ_RATE
	tween.tween_property(label, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func(): 
		end_symbol.text = ">"
		change_state(State.FINISHED)
		)
	
	if text_queue.is_empty():
		return
	
func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
		State.FINISHED:
			print("Changing state to: State.FINISHED")
			
	
	
	
	
	
