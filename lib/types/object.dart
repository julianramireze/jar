import 'package:jar/jar.dart';
import 'package:jar/result.dart';
import 'package:jar/schema.dart';

class JarObject extends JarSchema<Map<String, dynamic>, JarObject> {
  final Map<String, JarSchema<dynamic, dynamic>> fields;
  bool _allowExtra = false;
  List<String>? _ignoredFields;

  JarObject({required this.fields});

  JarObject required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarObject optional() {
    validators.clear();
    return self;
  }

  JarObject requireFields(List<String> fieldNames, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;

      for (final field in fieldNames) {
        if (!value.containsKey(field) || value[field] == null) {
          return message ?? 'The field $field is required';
        }
      }
      return null;
    });
  }

  JarObject forbidFields(List<String> fieldNames, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;

      for (final field in fieldNames) {
        if (value.containsKey(field)) {
          return message ?? 'The field $field is not allowed';
        }
      }
      return null;
    });
  }

  JarObject requireAtLeastOne(List<String> fieldNames, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;

      final hasOne = fieldNames
          .any((field) => value.containsKey(field) && value[field] != null);

      return hasOne
          ? null
          : (message ??
              'At least one of these fields is required: ${fieldNames.join(", ")}');
    });
  }

  JarObject requireExactlyOne(List<String> fieldNames, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;

      final presentFields = fieldNames
          .where((field) => value.containsKey(field) && value[field] != null)
          .length;

      return presentFields == 1
          ? null
          : (message ??
              'Exactly one of these fields must be present: ${fieldNames.join(", ")}');
    });
  }

  JarObject allowExtra() {
    _allowExtra = true;
    return self;
  }

  JarObject strict() {
    _allowExtra = false;
    return self;
  }

  @override
  JarResult validate(Map<String, dynamic>? value,
      [Map<String, dynamic>? allValues]) {
    final baseResult = super.validate(value, allValues ?? value);
    if (!baseResult.isValid) {
      return baseResult;
    }

    if (fields.isEmpty || value == null) {
      return JarResult.success();
    }

    final ignoredFields = _ignoredFields ?? [];

    if (!_allowExtra) {
      final extraFields = value.keys
          .where(
              (key) => !fields.containsKey(key) && !ignoredFields.contains(key))
          .toList();

      if (extraFields.isNotEmpty) {
        return JarResult.error(
            'Extra fields are not allowed: ${extraFields.join(", ")}');
      }
    }

    final errors = [];

    fields.forEach((key, fieldSchema) {
      final fieldValue = value[key];

      if (fieldSchema is JarObject && fieldValue is Map<String, dynamic>) {
        final nestedResult = fieldSchema.validate(fieldValue, value);
        if (!nestedResult.isValid) {
          if (nestedResult.details != null &&
              nestedResult.details!.containsKey('errors')) {
            final nestedErrors = nestedResult.details!['errors'];
            for (var error in nestedErrors) {
              errors.add({
                'path': '$key.${error['path']}',
                'message': error['message'],
              });
            }
          } else {
            errors.add({
              'path': key,
              'message': nestedResult.error,
            });
          }
        }
      } else {
        final fieldResult = fieldSchema.validate(fieldValue, value);
        if (!fieldResult.isValid) {
          errors.add({
            'path': key,
            'message': fieldResult.error,
          });
        }
      }
    });

    if (errors.isNotEmpty) {
      return JarResult.error('Validation failed', {'errors': errors});
    }

    return JarResult.success();
  }

  @override
  JarObject when(
      String field, Map<dynamic, JarObject Function(JarObject)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarObject merge(JarObject other) {
    return JarObject(
      fields: {...fields, ...other.fields},
    )
      ..validators.addAll(validators)
      .._allowExtra = _allowExtra;
  }

  JarObject extend(Map<String, JarSchema> additionalFields) {
    return merge(JarObject(fields: additionalFields));
  }

  JarObject pick(List<String> fieldNames) {
    return JarObject(
      fields: Map.fromEntries(
          fields.entries.where((entry) => fieldNames.contains(entry.key))),
    )
      ..validators.addAll(validators)
      .._allowExtra = _allowExtra;
  }

  JarObject omit(List<String> fieldNames) {
    final result = JarObject(
      fields: Map.fromEntries(
          fields.entries.where((entry) => !fieldNames.contains(entry.key))),
    )
      ..validators.addAll(validators)
      .._allowExtra = _allowExtra;

    result._ignoredFields = fieldNames;

    return result;
  }

  JarObject equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);

      if (otherValue is! Map<String, dynamic>?) return null;
      if (otherValue == null) return null;

      if (!_haveSameKeys(value, otherValue)) {
        return message ?? 'Must be equal to $field';
      }

      for (final key in value.keys) {
        final val1 = value[key];
        final val2 = otherValue[key];

        if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
          if (!_areObjectsEqual(val1, val2)) {
            return message ?? 'Must be equal to $field';
          }
        } else if (val1 is List && val2 is List) {
          if (!_areListsEqual(val1, val2)) {
            return message ?? 'Must be equal to $field';
          }
        } else if (val1 != val2) {
          return message ?? 'Must be equal to $field';
        }
      }

      return null;
    });
  }

  bool _haveSameKeys(Map<String, dynamic> obj1, Map<String, dynamic> obj2) {
    final keys1 = obj1.keys.toSet();
    final keys2 = obj2.keys.toSet();
    return keys1.length == keys2.length &&
        keys1.every((key) => keys2.contains(key));
  }

  bool _areObjectsEqual(Map<String, dynamic> obj1, Map<String, dynamic> obj2) {
    if (!_haveSameKeys(obj1, obj2)) return false;

    for (final key in obj1.keys) {
      final val1 = obj1[key];
      final val2 = obj2[key];

      if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areObjectsEqual(val1, val2)) return false;
      } else if (val1 is List && val2 is List) {
        if (!_areListsEqual(val1, val2)) return false;
      } else if (val1 != val2) {
        return false;
      }
    }

    return true;
  }

  bool _areListsEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;

    for (var i = 0; i < list1.length; i++) {
      final val1 = list1[i];
      final val2 = list2[i];

      if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areObjectsEqual(val1, val2)) return false;
      } else if (val1 is List && val2 is List) {
        if (!_areListsEqual(val1, val2)) return false;
      } else if (val1 != val2) {
        return false;
      }
    }

    return true;
  }

  JarObject custom(String? Function(Map<String, dynamic>? value) validator,
      [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final validationResult = validator(value);
      return validationResult ?? null;
    });
  }
}
