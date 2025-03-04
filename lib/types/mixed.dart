import 'package:jar/schema.dart';

class JarMixed<T> extends JarSchema<T, JarMixed<T>> {
  JarMixed required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarMixed optional() {
    validators.clear();
    return self;
  }

  JarMixed oneOf(List<T> allowed, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return allowed.contains(value)
          ? null
          : (message ?? 'Value must be one of: ${allowed.join(", ")}');
    });
  }

  JarMixed notOneOf(List<T> forbiddenValues, [String? message]) {
    return addValidator((value) {
      if (value == null && !forbiddenValues.contains(null)) return null;
      return forbiddenValues.contains(value)
          ? (message ?? 'Must not be one of the forbidden values')
          : null;
    });
  }

  @override
  JarMixed<T> when(String field,
      Map<dynamic, JarMixed<T> Function(JarMixed<T>)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarMixed<T> equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      return value == otherValue
          ? null
          : (message ?? 'Must be equal to $field');
    });
  }
}
