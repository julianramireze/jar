import 'package:jar/jar.dart';
import 'package:jar/schema.dart';

class JarString extends JarSchema<String, JarString> {
  JarString required([String? message]) {
    return addValidator((value) =>
        value == null || value.isEmpty ? (message ?? 'Required field') : null);
  }

  JarString optional() {
    validators.clear();
    return self;
  }

  JarString trim() {
    return transform((value) => value?.trim());
  }

  JarString lowercase() {
    return transform((value) => value?.toLowerCase());
  }

  JarString uppercase() {
    return transform((value) => value?.toUpperCase());
  }

  JarString min(int length, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.length >= length
          ? null
          : (message ?? 'Minimum $length characters');
    });
  }

  JarString max(int length, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.length <= length
          ? null
          : (message ?? 'Maximum $length characters');
    });
  }

  JarString matches(String pattern, [String? message]) {
    final regex = RegExp(pattern);
    return addValidator((value) {
      if (value == null) return null;
      return regex.hasMatch(value) ? null : (message ?? 'Invalid format');
    });
  }

  JarString email([String? message]) {
    return matches(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        message ?? 'Invalid email');
  }

  @override
  JarString when(
      String field, Map<dynamic, JarString Function(JarString)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarString equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      return value == otherValue
          ? null
          : (message ?? 'Must be equal to $field');
    });
  }

  JarString oneOf(List<String> allowedValues, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return allowedValues.contains(value)
          ? null
          : (message ?? 'Value must be one of: ${allowedValues.join(", ")}');
    });
  }

  JarString custom(String? Function(String? value, [Map<String, dynamic>? allValues]) validator,
      [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final validationResult = validator(value, getAllValues());
      return validationResult ?? null;
    });
  }
}