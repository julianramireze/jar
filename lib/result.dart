class JarResult {
  final bool isValid;
  final String? error;
  final Map<String, dynamic>? details;

  JarResult({
    required this.isValid,
    this.error,
    this.details,
  });

  factory JarResult.success() => JarResult(isValid: true);

  factory JarResult.error(String message,
          [Map<String, dynamic>? details]) =>
      JarResult(isValid: false, error: message, details: details);
}
