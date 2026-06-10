import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cue.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

// ─── App / User Profile ──────────────────────────────────────────────────────

class AppState {
  const AppState({this.userName, this.userRole, this.isLoading = true});

  final String? userName;
  final String? userRole;
  final bool isLoading;

  bool get isOnboarded => userName != null && userName!.isNotEmpty;

  AppState copyWith({String? userName, String? userRole, bool? isLoading}) =>
      AppState(
        userName: userName ?? this.userName,
        userRole: userRole ?? this.userRole,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppState(
      userName: prefs.getString('user_name'),
      userRole: prefs.getString('user_role'),
      isLoading: false,
    );
  }

  Future<void> saveProfile(String name, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_role', role);
    state = state.copyWith(userName: name, userRole: role, isLoading: false);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((_) => AppStateNotifier());

// ─── Timecode ────────────────────────────────────────────────────────────────

class TimecodeState {
  const TimecodeState({
    this.frames = 0,
    this.isRunning = false,
    this.framerate = 25,
  });

  final int frames;
  final bool isRunning;
  final int framerate;

  TimecodeState copyWith({int? frames, bool? isRunning, int? framerate}) =>
      TimecodeState(
        frames: frames ?? this.frames,
        isRunning: isRunning ?? this.isRunning,
        framerate: framerate ?? this.framerate,
      );
}

class TimecodeNotifier extends StateNotifier<TimecodeState> {
  TimecodeNotifier() : super(const TimecodeState());

  void update(int frames, {required bool isRunning}) =>
      state = state.copyWith(frames: frames, isRunning: isRunning);

  void setFramerate(int framerate) =>
      state = state.copyWith(framerate: framerate);
}

final timecodeProvider =
    StateNotifierProvider<TimecodeNotifier, TimecodeState>(
        (_) => TimecodeNotifier());

// ─── Session ─────────────────────────────────────────────────────────────────

final currentSessionProvider = StateProvider<SessionModel?>((ref) => null);

// ─── Session Discovery (mDNS) ─────────────────────────────────────────────────
// Replaced by real mDNS discovery later; mock data drives the UI for now.

final discoveredSessionsProvider =
    StateProvider<List<SessionModel>>((ref) => _mockSessions);

final _mockSessions = [
  SessionModel(
    id: 'mock-001',
    name: 'Phantom of the Opera — Wed Night',
    framerate: 25,
    version: 3,
    masterDeviceId: 'device-001',
    created: DateTime(2026, 6, 10, 19, 0),
    hostAddress: '192.168.1.42',
    hostPort: 8080,
    users: const [
      UserModel(
        name: 'Sarah',
        role: 'Stage Manager',
        permission: Permission.directEdit,
        isMaster: true,
        isConnected: true,
      ),
      UserModel(
        name: 'James',
        role: 'Lighting Op',
        permission: Permission.propose,
        isConnected: true,
      ),
      UserModel(
        name: 'Tom',
        role: 'Director',
        permission: Permission.view,
        isConnected: false,
      ),
    ],
    cues: const [
      Cue(id: 1, label: 'Overture Start', timecode: '00:02:30:00'),
      Cue(id: 2, label: 'Chandelier Drop', timecode: '00:08:15:12'),
      Cue(id: 3, label: 'Fly Cue 1', timecode: '00:12:34:00'),
      Cue(id: 4, label: 'Costume Change 1', timecode: '00:23:10:15'),
      Cue(id: 5, label: 'Scene 2 — Lights', timecode: '00:31:45:00'),
      Cue(id: 6, label: 'Music Sting', timecode: '00:42:18:10'),
      Cue(id: 7, label: 'Interval', timecode: '01:05:00:00'),
      Cue(id: 8, label: 'Act 2 — Opening', timecode: '01:10:30:00'),
    ],
  ),
  SessionModel(
    id: 'mock-002',
    name: 'Les Misérables — Tech Run',
    framerate: 30,
    version: 1,
    masterDeviceId: 'device-002',
    created: DateTime(2026, 6, 10, 14, 0),
    hostAddress: '192.168.1.55',
    hostPort: 8080,
    users: const [
      UserModel(
        name: 'Alex',
        role: 'Stage Manager',
        permission: Permission.directEdit,
        isMaster: true,
        isConnected: true,
      ),
      UserModel(
        name: 'Priya',
        role: 'Sound Op',
        permission: Permission.view,
        isConnected: true,
      ),
    ],
    cues: const [
      Cue(id: 1, label: 'Act 1 — Prologue', timecode: '00:00:30:00'),
      Cue(id: 2, label: 'Barricade Fly', timecode: '00:45:20:00'),
      Cue(id: 3, label: 'Interval', timecode: '01:20:00:00'),
    ],
  ),
];
