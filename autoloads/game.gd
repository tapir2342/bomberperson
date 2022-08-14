extends Node

signal started
#signal player_died(peer_id)

const GameServer := preload("res://autoloads/game_server.tscn")
const GameClient := preload("res://autoloads/game_client.tscn")

# Local
#const SERVER_DOMAIN := "127.0.0.1"
#const SERVER_ADDRESS := "ws://%s" % SERVER_DOMAIN
#const SERVER_USE_SSL := false

# Not local
const SERVER_DOMAIN := "bomberperson.tapir.lol"
const SERVER_ADDRESS := "wss://%s" % SERVER_DOMAIN
const SERVER_USE_SSL := true

const SERVER_PROTOCOLS := PoolStringArray() #["ludus"])
const SERVER_PORT := 23420
const SERVER_MAX_CLIENTS := 4

const CLIENT_PROTOCOLS := SERVER_PROTOCOLS

onready var _tree := get_tree()
onready var _ui_waiting: Control = get_node("/root/Main/CanvasLayer/Waiting")
onready var _ui_waiting_players_current: Control = _ui_waiting.get_node("PlayersCurrent")

puppetsync var players = {}

var tile_size := 32
var game_started = false

var _avatars = [
    "gorilla",
    "crocodile",
    "cow",
    "dog",
]


func _ready() -> void:
    randomize()

    var peer_node
    if _is_server():
        peer_node = GameServer.instance()
    else:
        peer_node = GameClient.instance()

    # FIXME: Might need to add to Main if deferred fucks up the ordering.
    #_tree.get_root().call_deferred("add_child", peer_node)
    _tree.get_root().get_node("/root/Main").add_child(peer_node)


func _is_server() -> bool:
    return "--server" in OS.get_cmdline_args() or OS.has_feature("Server")


func random_avatar() -> String:
    var random_index = randi() % len(_avatars)
    var random_avatar = _avatars[random_index]
    _avatars.remove(random_index)
    return random_avatar


remotesync func maybe_start_game() -> void:
    print("Peer: %d - Players: %s" % [_tree.get_network_unique_id(), players])
    if len(players) == 2 and not game_started:
        game_started = true
        emit_signal("started")
