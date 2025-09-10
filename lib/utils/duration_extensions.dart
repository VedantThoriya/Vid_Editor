extension DurationFormatter on Duration {
  String formatAsMMSS() {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
