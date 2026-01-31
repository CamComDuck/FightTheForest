@icon("res://icons/carronia.png")
class_name Icon
extends Sprite2D

@onready var background: Sprite2D = %Background as Sprite2D

@export var useBackground: bool = false

func _ready() -> void:
	background.visible = useBackground


func SetUseBackground(newUse: bool) -> void:
	useBackground = newUse
	background.visible = useBackground


func SetIcon(newIcon: Texture2D) -> void:
	self.texture = newIcon