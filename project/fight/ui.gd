class_name FightUI
extends Control


@onready var healthBarMoth:TextureProgressBar = %HealthBarMoth as TextureProgressBar
@onready var healthBarThreat:TextureProgressBar = %HealthBarThreat as TextureProgressBar


func setHealthMoth(health: int) -> void:
	healthBarMoth.value = health


func setHealthThreat(health: int) -> void:
	healthBarThreat.value = health