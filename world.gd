extends Node


@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var lobby_menu = $CanvasLayer/LobbyMenu

@onready var hud = $CanvasLayer/HUD
@onready var healtbar = $CanvasLayer/HUD/Healtbar
@onready var color_picker = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Color/ColorPickerButton
@onready var name_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Name/NameEntry

const Player = preload("res://Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(initConnection)

func _input(_event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed():
	main_menu.hide()
	#hud.show()
	lobby_menu.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	SendPlayerInformation(multiplayer.get_unique_id(),color_picker.color, name_entry.text)	
	#add_player(multiplayer.get_unique_id())

func initConnection():
	print("Connected with host")
	SendPlayerInformation.rpc_id(1,str(multiplayer.get_unique_id()),color_picker.color,name_entry.text)
	lobby_menu.show()	
	#upnp_setup()
func _on_join_button_pressed():
	main_menu.hide()
	#hud.show()
	enet_peer.create_client(address_entry.text,PORT)
	multiplayer.multiplayer_peer = enet_peer
@rpc("any_peer")
func SendPlayerInformation(id, color, player_name):
	if !MultiplayerHandler.Players.has(id):
		MultiplayerHandler.Players[id]={
			"Name": player_name,
			"PlayerColor":color,
			"id": id
		}
	if multiplayer.is_server():
		for i in MultiplayerHandler.Players:
			SendPlayerInformation.rpc(MultiplayerHandler.Players[i].id, 
			MultiplayerHandler.Players[i].PlayerColor,
			MultiplayerHandler.Players[i].Name)
	#print(MultiplayerHandler.Players)
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

@rpc("any_peer","call_local")
func startGame():
	var scene = load("res://Assets/Maps/Map1.tscn").instantiate()
	get_tree().root.add_child(scene)
	lobby_menu.hide()
	hud.show()
	
	
@rpc("any_peer","call_local")
func _on_start_button_pressed():
	if multiplayer.is_server():
		print("Started Game")
		startGame.rpc()

	else:
		print("Not hosting the game")
	pass # Replace with function body.
