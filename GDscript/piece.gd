extends Node2D


@export var color: String

var matched = false


func move(target):
	var tween = create_tween()
	tween.tween_property(self, "position", target, .33).from(self.position)

func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1, 1, .5)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
