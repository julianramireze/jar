import 'package:jar/result.dart';
import 'package:jar/types.dart';

abstract class JarSchema<T, Self extends JarSchema<T, Self>> {
  final List<JarValidator<T>> validators = [];
  final List<JarValueTransformer<T>> transformers = [];
  final Map<String, Map<dynamic, Self Function(Self)>> _conditions = {};
  String? _dependsOn;
  Map<String, dynamic>? _allValues;

  Self get self => this as Self;

  JarResult validate(T? value, [Map<String, dynamic>? allValues]) {
    _allValues = allValues;
    var transformedValue = value;

    for (final transformer in transformers) {
      transformedValue = transformer(transformedValue);
    }

    if (_dependsOn != null && allValues != null) {
      final dependentValue = allValues[_dependsOn];
      final conditions = _conditions[_dependsOn];

      if (conditions != null && conditions.containsKey(dependentValue)) {
        final conditionFn = conditions[dependentValue];
        if (conditionFn != null) {
          final conditionSchema = conditionFn(self);
          final validatorsToApply =
              List<JarValidator<T>>.from(conditionSchema.validators);

          for (final validator in validatorsToApply) {
            final error = validator(transformedValue);
            if (error != null) return JarResult.error(error);
          }
        }
      }
    }

    for (final validator in validators) {
      final error = validator(transformedValue);
      if (error != null) return JarResult.error(error);
    }

    return JarResult.success();
  }

  Self addValidator(JarValidator<T> validator) {
    validators.add(validator);
    return self;
  }

  Self transform(JarValueTransformer<T> transformer) {
    transformers.add(transformer);
    return self;
  }

  Self when(String field, Map<dynamic, Self Function(Self)> conditions) {
    _dependsOn = field;
    _conditions[field] = conditions;
    return self;
  }

  T? getFieldValue(String fieldName) {
    return _allValues?[fieldName] as T?;
  }
  
  Map<String, dynamic>? getAllValues() {
    return _allValues;
  }
}