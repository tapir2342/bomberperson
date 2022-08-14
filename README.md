# bomberperson

Multiplayer bomber-style game in the browser.

# Notes

- NetworkedMultiplayerENet does not work in the browser and [it apparently never will](https://github.com/godotengine/godot/issues/21763#issuecomment-419630028).
- Self-signed SSL certificates *do not work* with [WebsocketMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_websocketmultiplayerpeer.html). For temporary testing (90 days), you can generate a free SSL certificate on zerossl.com.
- Self-signed SSL certificates *might work* with `NetworkedMultiplayerENet`.

# Why websockets?

```
 NetworkedMultiplayerENet: Not supported on HTML5.
 ​ WARNING: Unable to change IPv4 address mapping over IPv6 option
​    at: set_ipv6_only_enabled (drivers/unix/net_socket_posix.cpp:663) - Unable to change IPv4 address mapping over IPv6 option
​    at: set_broadcasting_enabled (drivers/unix/net_socket_posix.cpp:630) - Unable to change broadcast setting
​    at: poll (modules/enet/networked_multiplayer_enet.cpp:228) - Method failed.
​    ...
func _setup_network_peer() -> void:
	var peer = NetworkedMultiplayerENet.new()

	if is_server():
		print("Creating server (port: %d, max clients: %d)..." % [SERVER_PORT, SERVER_MAX_CLIENTS])
		peer.create_server(Game.SERVER_PORT, Game.SERVER_MAX_CLIENTS)
	else:
		print("Creating client (server address: %s, port: %d)..." % [SERVER_ADDRESS, SERVER_PORT])
		peer.create_client(Game.SERVER_ADDRESS, Game.SERVER_PORT)

	_tree.network_peer = peer
```

# Always use Websockets? Also on desktop clients? Yes.
# + Easier code base.
# + There only needs to be one server being built and run.
# + All players (no matter where they play) can share one server.
# - Uses TCP, enet uses UDP. *Should* be faster.
