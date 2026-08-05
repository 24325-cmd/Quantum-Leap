extends Node

const PLAYER = preload("uid://b2pdkxahkypgv")

var player: Player


func _ready() -> void:
	player = PLAYER.instantiate()
