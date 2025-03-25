import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Dependent validation tests', () {
    test('Simple field dependency validation', () {
      final userSchema = Jar.object({
        'country': Jar.string().required().oneOf(['US', 'MX', 'CA']),
        'postalCode': Jar.string().required().custom(
          (value, [allValues]) {
            final country = allValues?['country'];

            if (country == 'US') {
              return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value!)
                  ? null
                  : 'US postal code must be in format 12345 or 12345-6789';
            } else if (country == 'CA') {
              return RegExp(r'^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$')
                      .hasMatch(value!)
                  ? null
                  : 'Canadian postal code must be in format A1A 1A1';
            } else if (country == 'MX') {
              return RegExp(r'^\d{5}$').hasMatch(value!)
                  ? null
                  : 'Mexican postal code must be 5 digits';
            }

            return null;
          },
        ),
      });

      expect(
          userSchema.validate({
            'country': 'US',
            'postalCode': '12345',
          }).isValid,
          true);

      expect(
          userSchema.validate({
            'country': 'CA',
            'postalCode': 'A1A 1A1',
          }).isValid,
          true);

      expect(
          userSchema.validate({
            'country': 'MX',
            'postalCode': '12345',
          }).isValid,
          true);

      expect(
          userSchema.validate({
            'country': 'US',
            'postalCode': 'ABC123',
          }).isValid,
          false);

      final invalidCaResult = userSchema.validate({
        'country': 'CA',
        'postalCode': '12345',
      });
      expect(invalidCaResult.isValid, false);
      expect(invalidCaResult.details?['errors'][0]['message'],
          'Canadian postal code must be in format A1A 1A1');
    });

    test('Multi-level field dependency validation', () {
      final orderSchema = Jar.object({
        'orderType': Jar.string()
            .required()
            .oneOf(['standard', 'express', 'international']),
        'estimatedDays': Jar.number().required().custom(
          (value, [allValues]) {
            final orderType = allValues?['orderType'];

            if (orderType == 'standard' && (value! < 3 || value > 7)) {
              return 'Standard shipping should take 3-7 days';
            } else if (orderType == 'express' && (value! < 1 || value > 2)) {
              return 'Express shipping should take 1-2 days';
            } else if (orderType == 'international' && value! < 7) {
              return 'International shipping should take at least 7 days';
            }

            return null;
          },
        ),
      });

      expect(
          orderSchema.validate({
            'orderType': 'standard',
            'estimatedDays': 5,
          }).isValid,
          true);

      expect(
          orderSchema.validate({
            'orderType': 'express',
            'estimatedDays': 1,
          }).isValid,
          true);

      final invalidStandardResult = orderSchema.validate({
        'orderType': 'standard',
        'estimatedDays': 2,
      });
      expect(invalidStandardResult.isValid, false);
      expect(invalidStandardResult.details?['errors'][0]['message'],
          'Standard shipping should take 3-7 days');

      final invalidInternationalResult = orderSchema.validate({
        'orderType': 'international',
        'estimatedDays': 5,
      });
      expect(invalidInternationalResult.isValid, false);
      expect(invalidInternationalResult.details?['errors'][0]['message'],
          'International shipping should take at least 7 days');
    });

    test('Form validation with multiple dependencies', () {
      final formSchema = Jar.object({
        'userType': Jar.string().required().oneOf(['personal', 'business']),
        'hasPremium': Jar.boolean().required(),
        'maxUsers': Jar.number().required().custom(
          (value, [allValues]) {
            final userType = allValues?['userType'];
            final hasPremium = allValues?['hasPremium'];

            if (userType == 'personal') {
              final maxAllowed = hasPremium == true ? 5 : 1;
              if (value! > maxAllowed) {
                return 'Personal accounts can have maximum $maxAllowed users';
              }
            } else if (userType == 'business') {
              final maxAllowed = hasPremium == true ? 50 : 10;
              if (value! > maxAllowed) {
                return 'Business accounts with premium can have maximum $maxAllowed users';
              }
            }

            return null;
          },
        ),
      });

      expect(
          formSchema.validate({
            'userType': 'personal',
            'hasPremium': false,
            'maxUsers': 1,
          }).isValid,
          true);

      expect(
          formSchema.validate({
            'userType': 'personal',
            'hasPremium': true,
            'maxUsers': 5,
          }).isValid,
          true);

      expect(
          formSchema.validate({
            'userType': 'business',
            'hasPremium': false,
            'maxUsers': 10,
          }).isValid,
          true);

      expect(
          formSchema.validate({
            'userType': 'business',
            'hasPremium': true,
            'maxUsers': 50,
          }).isValid,
          true);

      final invalidPersonalResult = formSchema.validate({
        'userType': 'personal',
        'hasPremium': false,
        'maxUsers': 3,
      });
      expect(invalidPersonalResult.isValid, false);
      expect(invalidPersonalResult.details?['errors'][0]['message'],
          'Personal accounts can have maximum 1 users');

      final invalidBusinessResult = formSchema.validate({
        'userType': 'business',
        'hasPremium': true,
        'maxUsers': 100,
      });
      expect(invalidBusinessResult.isValid, false);
      expect(invalidBusinessResult.details?['errors'][0]['message'],
          'Business accounts with premium can have maximum 50 users');
    });

    test('Password confirmation validation', () {
      final passwordSchema = Jar.object({
        'password': Jar.string()
            .required('Password is required')
            .min(8, 'Password must be at least 8 characters'),
        'confirmPassword': Jar.string()
            .required('Please confirm password')
            .custom((value, [allValues]) {
          final password = allValues?['password'];
          if (value != password) {
            return 'Passwords do not match';
          }
          return null;
        }),
      });

      expect(
          passwordSchema.validate({
            'password': 'password123',
            'confirmPassword': 'password123',
          }).isValid,
          true);

      final invalidResult = passwordSchema.validate({
        'password': 'password123',
        'confirmPassword': 'differentpassword',
      });
      expect(invalidResult.isValid, false);
      expect(invalidResult.details?['errors'][0]['message'],
          'Passwords do not match');

      final tooShortResult = passwordSchema.validate({
        'password': 'short',
        'confirmPassword': 'short',
      });
      expect(tooShortResult.isValid, false);
      expect(tooShortResult.details?['errors'][0]['message'],
          'Password must be at least 8 characters');
    });

    test('Conditional required fields based on selection', () {
      final creditCardSchema = Jar.object({
        'paymentMethod': Jar.string().required(),
        'creditCardNumber': Jar.string()
      }).custom((value, [allValues]) {
        if (value!['paymentMethod'] == 'creditCard' &&
            (value['creditCardNumber'] == null ||
                value['creditCardNumber'].isEmpty)) {
          return 'Credit card number is required for credit card payments';
        }
        return null;
      });

      expect(
          creditCardSchema.validate({
            'paymentMethod': 'bankTransfer',
          }).isValid,
          true);

      expect(
          creditCardSchema.validate({
            'paymentMethod': 'creditCard',
            'creditCardNumber': '4111111111111111',
          }).isValid,
          true);

      final invalidResult = creditCardSchema.validate({
        'paymentMethod': 'creditCard',
      });

      expect(invalidResult.isValid, false);
      expect(invalidResult.error,
          'Credit card number is required for credit card payments');
    });
  });
}
