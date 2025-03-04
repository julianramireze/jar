import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Combinations and chaining', () {
    test('Multiple validations chain result', () {
      final schema = Jar.string()
          .required('Required error')
          .email('Email error')
          .min(30, 'Length error');

      expect(schema.validate(null).error, 'Required error');
      expect(schema.validate('invalid').error, 'Email error');

      const email = 'valid.email@example.com';
      final emailResult = schema.validate(email);

      print('Email length: ${email.length}, min required: 30');

      expect(emailResult.isValid, false);
      expect(emailResult.error, 'Length error');

      expect(
          schema
              .validate('this.is.a.very.long.valid.email@example.com')
              .isValid,
          true);
    });

    test('Transform then validate', () {
      final schema = Jar.string()
          .transform((v) => v?.padLeft(10, '0'))
          .min(10, 'Too short');

      expect(schema.validate('12345').isValid, true);
      expect(schema.validate('12345').error, null);
    });
  });

  group('Error message formatting', () {
    test('Custom dynamic error messages', () {
      final customMessage = (int min) =>
          (value) => 'Value "$value" must be at least $min characters';

      final schema = Jar.string().addValidator(
          (value) => (value?.length ?? 0) < 5 ? customMessage(5)(value) : null);

      expect(schema.validate('abc').error,
          'Value "abc" must be at least 5 characters');
      expect(schema.validate('abcdef').isValid, true);
    });
  });

  group('Edge cases', () {
    test('Empty array validation', () {
      final schema = Jar.array().required('Required array');
      expect(schema.validate([]).isValid, true);
    });

    test('Empty object validation', () {
      final schema = Jar.object().required('Required object');
      expect(schema.validate({}).isValid, true);
    });

    test('Zero value validation', () {
      final schema = Jar.number().min(0, 'Must be non-negative');
      expect(schema.validate(0).isValid, true);
    });

    test('Boolean false validation', () {
      final schema = Jar.boolean().required('Required boolean');
      expect(schema.validate(false).isValid, true);
    });

    test('Null transformation handling', () {
      final schema = Jar.string().transform((v) => v?.toUpperCase()).optional();

      expect(schema.validate(null).isValid, true);
    });
  });

  group('Multiple conditional branches', () {
    test('Multiple conditions on same field', () {
      final schema = Jar.object({
        'type': Jar.string().oneOf(['personal', 'business', 'nonprofit']),
        'taxId': Jar.string(),
        'personalId': Jar.string()
      });

      schema.fields['taxId'] = Jar.string().when('type', {
        'business': (s) => s.required('Businesses need tax ID'),
        'nonprofit': (s) => s.required('Nonprofits need tax ID'),
        'personal': (s) => s.optional(),
      });

      schema.fields['personalId'] = Jar.string().when('type', {
        'personal': (s) => s.required('Personal accounts need personal ID'),
        'business': (s) => s.optional(),
        'nonprofit': (s) => s.optional(),
      });

      expect(
          schema.validate({
            'type': 'business',
            'taxId': '12345',
          }).isValid,
          true);

      expect(
          schema.validate({
            'type': 'business',
          }).isValid,
          false);

      expect(
          schema.validate({
            'type': 'personal',
            'personalId': '12345',
          }).isValid,
          true);

      expect(
          schema.validate({
            'type': 'personal',
          }).isValid,
          false);
    });
  });
}
