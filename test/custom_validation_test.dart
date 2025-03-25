import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Custom validation tests', () {
    test('JarString custom validation', () {
      final schema = Jar.string().custom(
        (value, [allValues]) =>
            value!.contains('@company.com') ? null : 'Must be a company email',
      );

      expect(schema.validate('user@company.com').isValid, true);
      expect(schema.validate('user@gmail.com').isValid, false);
      expect(
          schema.validate('user@gmail.com').error, 'Must be a company email');
    });

    test('JarNumber custom validation', () {
      final schema = Jar.number().custom(
        (value, [allValues]) =>
            value! % 2 == 0 ? null : 'Must be an even number',
      );

      expect(schema.validate(2).isValid, true);
      expect(schema.validate(4).isValid, true);
      expect(schema.validate(3).isValid, false);
      expect(schema.validate(3).error, 'Must be an even number');
    });

    test('JarBoolean custom validation', () {
      final currentHour = DateTime.now().hour;
      final isEvenHour = currentHour % 2 == 0;

      final schema = Jar.boolean().custom(
        (value, [allValues]) =>
            value == isEvenHour ? null : 'Must match current hour parity',
      );

      expect(schema.validate(isEvenHour).isValid, true);
      expect(schema.validate(!isEvenHour).isValid, false);
      expect(
          schema.validate(!isEvenHour).error, 'Must match current hour parity');
    });

    test('JarDate custom validation', () {
      final schema = Jar.date().custom(
        (value, [allValues]) => (value!.weekday == DateTime.saturday ||
                value.weekday == DateTime.sunday)
            ? null
            : 'Must be a weekend day',
      );

      final weekendDay = DateTime(2023, 1, 7);
      final weekday = DateTime(2023, 1, 9);

      expect(schema.validate(weekendDay).isValid, true);
      expect(schema.validate(weekday).isValid, false);
      expect(schema.validate(weekday).error, 'Must be a weekend day');
    });

    test('JarArray custom validation', () {
      final schema = Jar.array<int>().custom(
        (value, [allValues]) => value!.every((element) => element >= 0)
            ? null
            : 'All elements must be non-negative',
      );

      expect(schema.validate([0, 1, 2, 3]).isValid, true);
      expect(schema.validate([0, -1, 2, 3]).isValid, false);
      expect(schema.validate([0, -1, 2, 3]).error,
          'All elements must be non-negative');
    });

    test('JarObject custom validation', () {
      final schema = Jar.object().custom(
        (value, [allValues]) =>
            value!.keys.every((key) => (key as String).startsWith('user_'))
                ? null
                : 'All keys must start with user_',
      );

      expect(
          schema.validate({
            'user_id': 1,
            'user_name': 'John',
          }).isValid,
          true);

      expect(
          schema.validate({
            'user_id': 1,
            'name': 'John',
          }).isValid,
          false);

      expect(
          schema.validate({
            'user_id': 1,
            'name': 'John',
          }).error,
          'All keys must start with user_');
    });

    test('JarMixed custom validation', () {
      final schema = Jar.mixed<dynamic>().custom(
        (value, [allValues]) => (value is String || value is int)
            ? null
            : 'Value must be a string or an integer',
      );

      expect(schema.validate('test').isValid, true);
      expect(schema.validate(123).isValid, true);
      expect(schema.validate(12.34).isValid, false);
      expect(
          schema.validate(12.34).error, 'Value must be a string or an integer');
    });
  });

  group('Advanced custom validation scenarios', () {
    test('Custom password validation', () {
      final passwordSchema = Jar.string().custom(
        (value, [allValues]) {
          if (value == null || value.isEmpty) return 'Password is required';

          final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
          final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
          final hasDigit = RegExp(r'[0-9]').hasMatch(value);
          final hasSpecialChar =
              RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

          if (!hasUppercase)
            return 'Password must include at least one uppercase letter';
          if (!hasLowercase)
            return 'Password must include at least one lowercase letter';
          if (!hasDigit) return 'Password must include at least one digit';
          if (!hasSpecialChar)
            return 'Password must include at least one special character';

          return null;
        },
      );

      expect(passwordSchema.validate('Abcd1234!').isValid, true);
      expect(passwordSchema.validate('abcd1234!').isValid, false);
      expect(passwordSchema.validate('ABCD1234!').isValid, false);
      expect(passwordSchema.validate('Abcdefgh!').isValid, false);
      expect(passwordSchema.validate('Abcd1234').isValid, false);
    });

    test('Custom credit card validation', () {
      final ccSchema = Jar.string().custom(
        (value, [allValues]) {
          if (value == null || value.isEmpty)
            return 'Credit card number required';

          final ccNumber = value.replaceAll(' ', '');

          if (!RegExp(r'^\d+$').hasMatch(ccNumber))
            return 'Credit card must contain only digits';

          if (![13, 15, 16, 19].contains(ccNumber.length))
            return 'Invalid credit card number length';

          return null;
        },
      );

      expect(ccSchema.validate('4111 1111 1111 1111').isValid, true);
      expect(ccSchema.validate('411111111111111').isValid, true);
      expect(ccSchema.validate('411').isValid, false);
      expect(ccSchema.validate('abcd efgh ijkl mnop').isValid, false);
    });

    test('Custom validation with multiple schemas', () {
      final formSchema = Jar.object({
        'username': Jar.string().custom(
          (value, [allValues]) =>
              !value!.contains(' ') ? null : 'Username cannot contain spaces',
        ),
        'age': Jar.number().custom(
          (value, [allValues]) => value! >= 18 && value <= 65
              ? null
              : 'Age must be between 18 and 65',
        ),
        'agreeToTerms': Jar.boolean().custom(
          (value, [allValues]) =>
              value == true ? null : 'You must agree to the terms',
        ),
      });

      final validData = {
        'username': 'johndoe',
        'age': 30,
        'agreeToTerms': true,
      };

      final invalidData = {
        'username': 'john doe',
        'age': 16,
        'agreeToTerms': false,
      };

      expect(formSchema.validate(validData).isValid, true);
      expect(formSchema.validate(invalidData).isValid, false);

      final result = formSchema.validate(invalidData);
      expect(result.details?['errors'].length, 3);
    });

    test('Combining built-in and custom validations', () {
      final schema = Jar.string()
          .min(8, 'Too short')
          .max(20, 'Too long')
          .custom(
            (value, [allValues]) => RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)
                ? null
                : 'Only alphanumeric characters and underscores allowed',
          );

      expect(schema.validate('username_123').isValid, true);
      expect(schema.validate('ab').isValid, false);
      expect(schema.validate('username_123_very_long').isValid, false);
      expect(schema.validate('username@123').isValid, false);
    });

    test('Custom validation with conditional logic', () {
      final schema = Jar.object({
        'accountType': Jar.string().oneOf(['personal', 'business']),
        'businessName': Jar.string(),
        'taxId': Jar.string(),
      });

      schema.fields['businessName'] = Jar.string().when('accountType', {
        'business': (s) => s.required('Business name is required').custom(
              (value, [allValues]) => value!.length >= 3 && value.length <= 50
                  ? null
                  : 'Business name must be between 3 and 50 characters',
            ),
        'personal': (s) => s.optional(),
      });

      schema.fields['taxId'] = Jar.string().when('accountType', {
        'business': (s) => s.required('Tax ID is required').custom(
              (value, [allValues]) => RegExp(r'^\d{2}-\d{7}$').hasMatch(value!)
                  ? null
                  : 'Tax ID must be in format XX-XXXXXXX',
            ),
        'personal': (s) => s.optional(),
      });

      expect(
          schema.validate({
            'accountType': 'business',
            'businessName': 'Acme Corporation',
            'taxId': '12-3456789',
          }).isValid,
          true);

      expect(
          schema.validate({
            'accountType': 'business',
            'businessName': 'AC',
            'taxId': '12-3456789',
          }).isValid,
          false);

      expect(
          schema.validate({
            'accountType': 'business',
            'businessName': 'Acme Corporation',
            'taxId': '123456789',
          }).isValid,
          false);

      expect(
          schema.validate({
            'accountType': 'personal',
          }).isValid,
          true);
    });
  });
}
