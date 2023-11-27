void log(String? text, bool error) {
  print("${DateTime.now().toIso8601String()} - ${(error) ? "ERROR: " : "INFO: "} $text");
}