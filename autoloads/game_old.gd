extends Node

signal started
signal player_died(peer_id)

const SERVER_USE_SSL := false

#const SERVER_ADDRESS := "127.0.0.1"
#const SERVER_ADDRESS := "51.15.71.106"
#const SERVER_ADDRESS := "2001:bc8:1820:121c::1"

const SERVER_DOMAIN := "127.0.0.1"
const SERVER_ADDRESS := "ws://%s" % SERVER_DOMAIN
const SERVER_PROTOCOLS := PoolStringArray() #["ludus"])

#const SERVER_DOMAIN := "bomberperson.tapir.lol"
#const SERVER_ADDRESS := "wss://%s" % SERVER_DOMAIN
#const SERVER_PROTOCOLS := PoolStringArray() #["ludus"])
const SERVER_PORT := 23420
const SERVER_MAX_CLIENTS := 4

const CLIENT_PROTOCOLS := SERVER_PROTOCOLS

onready var _tree := get_tree()

puppetsync var players = {}

var tile_size := 32
var game_started = false

var _peer
var _avatars = [
    "gorilla",
    "crocodile",
    "cow",
    "dog",
]


func _ready():
    randomize()
    _setup_network_peer()


func _process(_delta) -> void:
    if _peer:
        _peer.poll()


func _setup_network_peer() -> void:
    if _is_server():
        _peer = _create_server_peer()
        _peer.connect("client_connected", self, "_on_client_connected")
        _peer.connect("client_disconnected", self, "_on_client_disconnected")
    else:
        _peer = _create_client_peer()

    assert(_peer != null)
    _tree.network_peer = _peer


func _create_server_peer() -> WebSocketServer:
    print("Starting server (port: %d)..." % SERVER_PORT)
    var peer = WebSocketServer.new()
    if SERVER_USE_SSL:
        peer.private_key = load("res://server.key")
        peer.ssl_certificate = load("res://server.crt")
        peer.handshake_timeout = 10.0

    var err = peer.listen(SERVER_PORT, SERVER_PROTOCOLS, true)
    if err != OK:
        print("Server: Failed to listen on port %d. Exiting.", SERVER_PORT)
        _tree.quit()
        return null

    return peer


func _create_client_peer() -> WebSocketClient:
    var server_address_port = "%s:%d" % [SERVER_ADDRESS, SERVER_PORT]
    print("Starting client (server address: %s)..." % server_address_port)
    var peer = WebSocketClient.new()
    peer.verify_ssl = SERVER_USE_SSL

    var err = peer.connect_to_url(server_address_port, CLIENT_PROTOCOLS, true)
    if err != OK:
        print("Client: Failed connect to server (server address: %s)", SERVER_ADDRESS)
        set_process(false)
        # NOTE: Cannot get_tree().quit() on HTML5.
        return null

    return peer


func _is_server() -> bool:
    return "--server" in OS.get_cmdline_args() or OS.has_feature("Server")


#func _on_connected_to_server() -> void:
#    rpc_id(1, "register_player")


func _on_client_connected(id: int, _protocol: String) -> void:
    print("CLIENT CONNECTED: %d" % id)
    #players[peer_id] = {
    #    peer_id = peer_id,
    #    avatar = random_avatar(),
    #    alive = true,
    #}
    #rset("players", players)
    #rpc("maybe_start_game")


func _on_client_disconnected(id: int, _was_clean_close: bool) -> void:
    print("CLIENT DISCONNECTED: %d" % id)
    #if players.has(peer_id):
    #    players.erase(peer_id)


master func register_player_death() -> void:
    var peer_id = _tree.get_rpc_sender_id()
    if not Game.players.has(peer_id):
        return

    Game.players[peer_id].alive = false
    print(Game.players)


remotesync func maybe_start_game() -> void:
    print("Peer: %d - Players: %s" % [_tree.get_network_unique_id(), players])
    if len(players) == 2 and not game_started:
        game_started = true
        emit_signal("started")


func random_avatar() -> String:
    var random_index = randi() % len(_avatars)
    var random_avatar = _avatars[random_index]
    _avatars.remove(random_index)
    return random_avatar
