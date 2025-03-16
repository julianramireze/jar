import 'package:jar/jar.dart';
import 'package:jar/result.dart';
import 'package:jar/schema.dart';

class JarArray<T> extends JarSchema<List<T>, JarArray<T>> {
  final JarSchema<T, JarSchema<T, dynamic>>? elementSchema;

  JarArray(this.elementSchema);

  JarArray<T> required([String? message]) {
    return addValidator(
        (value) => value == null ? (message ?? 'Required field') : null);
  }

  JarArray<T> optional() {
    validators.clear();
    return self;
  }

  JarArray<T> min(int length, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.length >= length
          ? null
          : (message ?? 'Minimum $length elements');
    });
  }

  JarArray<T> max(int length, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.length <= length
          ? null
          : (message ?? 'Maximum $length elements');
    });
  }

  JarArray<T> length(int exactLength, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      return value.length == exactLength
          ? null
          : (message ?? 'Must have exactly $exactLength elements');
    });
  }

  JarArray<T> unique([String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final set = Set<T>.from(value);
      return set.length == value.length
          ? null
          : (message ?? 'Elements must be unique');
    });
  }

  @override
  JarResult validate(List<T>? value, [Map<String, dynamic>? allValues]) {
    final listResult = super.validate(value, allValues);
    if (!listResult.isValid) {
      return listResult;
    }

    if (value != null && elementSchema != null) {
      final errors = <int, String>{};
      for (var i = 0; i < value.length; i++) {
        final elementResult = elementSchema!.validate(value[i], allValues);
        if (!elementResult.isValid) {
          errors[i] = elementResult.error!;
        }
      }
      if (errors.isNotEmpty) {
        return JarResult.error(
            'Errors in list elements', {'elementErrors': errors});
      }
    }

    return JarResult.success();
  }

  @override
  JarArray<T> when(String field,
      Map<dynamic, JarArray<T> Function(JarArray<T>)> conditions) {
    super.when(field, conditions);
    return self;
  }

  JarArray<T> equalTo(String field, [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final otherValue = getFieldValue(field);
      if (otherValue is! List?) return null;
      if (value.length != otherValue!.length) {
        return message ?? 'Must be equal to $field';
      }
      for (var i = 0; i < value.length; i++) {
        if (value[i] != otherValue[i]) {
          return message ?? 'Must be equal to $field';
        }
      }
      return null;
    });
  }

  JarArray<T> custom(String? Function(List<T>? value) validator,
      [String? message]) {
    return addValidator((value) {
      if (value == null) return null;
      final validationResult = validator(value);
      return validationResult ?? null;
    });
  }
}
