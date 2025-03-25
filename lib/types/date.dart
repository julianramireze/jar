import 'package:jar/jar.dart';
import 'package:jar/schema.dart';

class JarDate extends JarSchema<DateTime, JarDate> {
  JarDate required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarDate optional() {
    validators.clear();
    return self;
  }

  JarDate min(DateTime min, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.isAfter(min) || value.isAtSameMomentAs(min)
          ? null
          : (message ?? 'Must be after ${min.toString()}');
    });
  }

  JarDate max(DateTime max, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.isBefore(max) || value.isAtSameMomentAs(max)
          ? null
          : (message ?? 'Must be before ${max.toString()}');
    });
  }

  JarDate future([String? message]) {
    return min(DateTime.now(), message ?? 'Must be a future date');
  }

  JarDate past([String? message]) {
    return max(DateTime.now(), message ?? 'Must be a past date');
  }

  @override
  JarDate when(
      String field, Map<dynamic, JarDate Function(JarDate)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarDate equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      if (otherValue is! DateTime?) return null;
      return value.isAtSameMomentAs(otherValue!)
          ? null
          : (message ?? 'Must be equal to $field');
    });
  }

  JarDate custom(String? Function(DateTime? value, [Map<String, dynamic>? allValues]) validator,
      [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final validationResult = validator(value, getAllValues());
      return validationResult ?? null;
    });
  }
}