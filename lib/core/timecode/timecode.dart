// Utility functions for working with SMPTE timecode.
// MTC parsing and UDP listening will be wired in when hardware is available.
abstract final class Timecode {
  static String framesToString(int frames, int framerate) {
    if (framerate <= 0) framerate = 25;
    final totalSeconds = frames ~/ framerate;
    final f = frames % framerate;
    final s = totalSeconds % 60;
    final m = (totalSeconds ~/ 60) % 60;
    final h = totalSeconds ~/ 3600;
    return '${_pad(h)}:${_pad(m)}:${_pad(s)}:${_pad(f)}';
  }

  static int stringToFrames(String timecode, int framerate) {
    final parts = timecode.split(':');
    if (parts.length != 4) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;
    final f = int.tryParse(parts[3]) ?? 0;
    return ((h * 3600 + m * 60 + s) * framerate) + f;
  }

  /// Returns e.g. "-2m 18s" (remaining) or "+5s" (past).
  static String formatCountdown(int framesDelta, int framerate) {
    if (framerate <= 0) framerate = 25;
    final abs = framesDelta.abs();
    final totalSec = abs ~/ framerate;
    final s = totalSec % 60;
    final m = totalSec ~/ 60;
    final sign = framesDelta >= 0 ? '-' : '+';
    if (m > 0) return '$sign${m}m ${s.toString().padLeft(2, '0')}s';
    return '$sign${s}s';
  }

  static bool isValid(String tc) =>
      RegExp(r'^\d{2}:\d{2}:\d{2}:\d{2}$').hasMatch(tc);

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
