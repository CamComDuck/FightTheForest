@icon("res://threat/tree.png")
class_name Threat
extends Sprite2D

signal onThreatDied

var maxHealth := 10
var currentHealth := 10

func getHealth() -> int:
    return currentHealth


func incrementHealth(inc: int) -> void:
    currentHealth += inc
    if currentHealth <= 0:
        # die
        print("threat died")
        onThreatDied.emit()
        