import 'package:jar/jar.dart';
import 'package:jar/schema.dart';

class JarNumber extends JarSchema<num, JarNumber> {
  JarNumber required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarNumber optional() {
    validators.clear();
    return self;
  }

  JarNumber min(num min, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value >= min
          ? null
          : (message ?? 'Must be greater than or equal to $min');
    });
  }

  JarNumber max(num max, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value <= max
          ? null
          : (message ?? 'Must be less than or equal to $max');
    });
  }

  JarNumber positive([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value > 0 ? null : (message ?? 'Must be positive');
    });
  }

  JarNumber negative([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value < 0 ? null : (message ?? 'Must be negative');
    });
  }

  JarNumber integer([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.floor() == value ? null : (message ?? 'Must be an integer');
    });
  }

  JarNumber round() {
    return transform((value) => value?.round().toDouble());
  }

  JarNumber truncate() {
    return transform((value) => value?.truncate().toDouble());
  }

  @override
  JarNumber when(
      String field, Map<dynamic, JarNumber Function(JarNumber)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarNumber equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      if (otherValue is! num?) return null;
      return value == otherValue
          ? null
          : (message ?? 'Must be equal to $field');
    });
  }

  JarNumber custom(String? Function(num? value) validator, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final validationResult = validator(value);
      return validationResult ?? null;
    });
  }
}
