import 'package:socket_io_client/socket_io_client.dart' as IO;

class MultiplayerService {
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  IO.Socket? _socket;
  String? _currentGameCode;
  String? _playerName;
  bool _isHost = false;

  // Callbacks
  Function(String gameCode)? onGameCreated;
  Function(Map<String, dynamic> players)? onPlayerJoined;
  Function(bool hostReady, bool guestReady)? onWaitingForPlayers;
  Function(int delay)? onGameStarting;
  Function()? onShootNow;
  Function(Map<String, dynamic> data)? onPlayerShot;
  Function(Map<String, dynamic> result)? onGameOver;
  Function(String socketId)? onPlayerLeft;
  Function(String message)? onError;
  Function(Map<String, dynamic> players)? onRematchReady;

  // Connexion au serveur
  void connect(String serverUrl) {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _setupListeners();
  }

  void _setupListeners() {
    _socket!.on('connect', (_) {
      print('Connecté au serveur multiplayer');
    });

    _socket!.on('disconnect', (_) {
      print('Déconnecté du serveur');
    });

    _socket!.on('game_created', (data) {
      _currentGameCode = data['gameCode'];
      _isHost = true;
      onGameCreated?.call(data['gameCode']);
    });

    _socket!.on('player_joined', (data) {
      onPlayerJoined?.call(data);
    });

    _socket!.on('waiting_for_players', (data) {
      onWaitingForPlayers?.call(data['hostReady'], data['guestReady']);
    });

    _socket!.on('game_starting', (data) {
      onGameStarting?.call(data['delay']);
    });

    _socket!.on('shoot_now', (_) {
      onShootNow?.call();
    });

    _socket!.on('player_shot', (data) {
      onPlayerShot?.call(data);
    });

    _socket!.on('game_over', (data) {
      onGameOver?.call(data);
    });

    _socket!.on('player_left', (data) {
      onPlayerLeft?.call(data['socketId']);
    });

    _socket!.on('error', (data) {
      onError?.call(data['message']);
    });

    _socket!.on('rematch_ready', (data) {
      onRematchReady?.call(data);
    });
  }

  // Créer une partie
  void createGame(String playerName) {
    _playerName = playerName;
    _socket!.emit('create_game', playerName);
  }

  // Rejoindre une partie
  void joinGame(String gameCode, String playerName) {
    _playerName = playerName;
    _currentGameCode = gameCode;
    _isHost = false;
    _socket!.emit('join_game', {
      'gameCode': gameCode,
      'playerName': playerName,
    });
  }

  // Signaler que le joueur est prêt
  void playerReady() {
    if (_currentGameCode != null) {
      _socket!.emit('player_ready', _currentGameCode);
    }
  }

  // Signaler un tir
  void playerShoot(int reactionTime) {
    if (_currentGameCode != null) {
      _socket!.emit('player_shoot', {
        'gameCode': _currentGameCode,
        'reactionTime': reactionTime,
      });
    }
  }

  // Demander un rematch
  void requestRematch() {
    if (_currentGameCode != null) {
      _socket!.emit('rematch', _currentGameCode);
    }
  }

  // Quitter la partie
  void leaveGame() {
    if (_currentGameCode != null) {
      _socket!.emit('leave_game', _currentGameCode);
      _currentGameCode = null;
      _isHost = false;
    }
  }

  // Déconnexion
  void disconnect() {
    leaveGame();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Getters
  String? get currentGameCode => _currentGameCode;
  String? get playerName => _playerName;
  bool get isHost => _isHost;
  bool get isConnected => _socket?.connected ?? false;
}