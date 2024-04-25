extends Node3D

@export var PlayerScene : PackedScene
@onready var spawnpoint = $Spawnpoint

func _ready():
	for i in MultiplayerHandler.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(MultiplayerHandler.Players[i].id)
		currentPlayer.setColor(MultiplayerHandler.Players[i].PlayerColor)
		currentPlayer.setName(MultiplayerHandler.Players[i].Name)		
		add_child(currentPlayer)
		currentPlayer.global_position = spawnpoint.global_position
