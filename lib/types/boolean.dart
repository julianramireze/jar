import 'package:jar/schema.dart';

class JarBoolean extends JarSchema<bool, JarBoolean> {
  JarBoolean required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarBoolean optional() {
    validators.clear();
    return self;
  }

  JarBoolean isTrue([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value == true ? null : (message ?? 'Must be true');
    });
  }

  JarBoolean isFalse([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value == false ? null : (message ?? 'Must be false');
    });
  }

  @override
  JarBoolean when(
      String field, Map<dynamic, JarBoolean Function(JarBoolean)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarBoolean equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      if (otherValue is! bool?) return null;
      return value == otherValue
          ? null
          : (message ?? 'Must be equal to $field');
    });
  }
}
