import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Performance tests', () {
    test('Large object validation performance', () {
      final fields = <String, JarSchema>{};
      for (var i = 0; i < 100; i++) {
        fields['field$i'] = Jar.string().required('Field $i is required');
      }

      final largeSchema = Jar.object(fields);

      final validData = <String, dynamic>{};
      for (var i = 0; i < 100; i++) {
        validData['field$i'] = 'value$i';
      }

      final stopwatch = Stopwatch()..start();
      final result = largeSchema.validate(validData);
      stopwatch.stop();

      expect(result.isValid, true);
      print('Validar 100 campos tomó: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Deeply nested object validation', () {
      var innerSchema = Jar.object({
        'level1': Jar.string().required('Required'),
      });

      for (var i = 2; i <= 10; i++) {
        innerSchema = Jar.object({
          'level$i': Jar.string().required('Required'),
          'nested': innerSchema,
        });
      }

      var innerData = <String, dynamic>{'level1': 'value'};

      for (var i = 2; i <= 10; i++) {
        innerData = <String, dynamic>{
          'level$i': 'value',
          'nested': innerData,
        };
      }

      final stopwatch = Stopwatch()..start();
      final result = innerSchema.validate(innerData);
      stopwatch.stop();

      print(result.error);

      expect(result.isValid, true);
      print(
          'Validar objeto anidado a 10 niveles tomó: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
