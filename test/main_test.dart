import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Jar.string()', () {
    test('required validation', () {
      final schema = Jar.string().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate('').isValid, false);
      expect(schema.validate('  ').isValid, true);
      expect(schema.validate('test').isValid, true);

      expect(schema.validate(null).error, 'Field is required');
      expect(schema.validate('').error, 'Field is required');
    });

    test('custom validation', () {
      final schema = Jar.string().custom(
        (value) => value!.length % 2 == 0 ? null : 'String length must be even',
      );

      expect(schema.validate('ab').isValid, true);
      expect(schema.validate('abcd').isValid, true);
      expect(schema.validate('abc').isValid, false);
      expect(schema.validate('abc').error, 'String length must be even');
    });

    test('min validation', () {
      final schema = Jar.string().min(3, 'Too short');

      expect(schema.validate('a').isValid, false);
      expect(schema.validate('ab').isValid, false);
      expect(schema.validate('abc').isValid, true);
      expect(schema.validate('abcd').isValid, true);

      expect(schema.validate('a').error, 'Too short');
    });

    test('max validation', () {
      final schema = Jar.string().max(5, 'Too long');

      expect(schema.validate('abcde').isValid, true);
      expect(schema.validate('abcdef').isValid, false);

      expect(schema.validate('abcdef').error, 'Too long');
    });

    test('email validation', () {
      final schema = Jar.string().email('Invalid email');

      expect(schema.validate('test').isValid, false);
      expect(schema.validate('test@example').isValid, false);
      expect(schema.validate('test@example.com').isValid, true);

      expect(schema.validate('test').error, 'Invalid email');
    });

    test('matches validation', () {
      final schema = Jar.string().matches(r'^[A-Z][a-z]+$', 'Invalid format');

      expect(schema.validate('test').isValid, false);
      expect(schema.validate('Test').isValid, true);
      expect(schema.validate('TEST').isValid, false);

      expect(schema.validate('test').error, 'Invalid format');
    });

    test('trim transformation', () {
      final schema = Jar.string().trim().min(3, 'Too short');

      expect(schema.validate('  a  ').isValid, false);
      expect(schema.validate('  abc  ').isValid, true);
    });

    test('lowercase transformation', () {
      final schema =
          Jar.string().lowercase().matches(r'^[a-z]+$', 'Must be lowercase');

      expect(schema.validate('TEST').isValid, true);
      expect(schema.validate('Test').isValid, true);
      expect(schema.validate('test').isValid, true);
    });

    test('equalTo validation', () {
      final objectSchema = Jar.object({
        'password': Jar.string().required('Password required'),
        'confirmPassword':
            Jar.string().equalTo('password', 'Passwords must match'),
      });

      expect(
          objectSchema.validate({
            'password': 'abc123',
            'confirmPassword': 'abc123',
          }).isValid,
          true);

      expect(
          objectSchema.validate({
            'password': 'abc123',
            'confirmPassword': 'different',
          }).isValid,
          false);
    });
  });

  group('Jar.number()', () {
    test('required validation', () {
      final schema = Jar.number().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate(0).isValid, true);
      expect(schema.validate(42).isValid, true);

      expect(schema.validate(null).error, 'Field is required');
    });

    test('min validation', () {
      final schema = Jar.number().min(10, 'Too small');

      expect(schema.validate(9).isValid, false);
      expect(schema.validate(10).isValid, true);
      expect(schema.validate(11).isValid, true);

      expect(schema.validate(9).error, 'Too small');
    });

    test('max validation', () {
      final schema = Jar.number().max(10, 'Too large');

      expect(schema.validate(10).isValid, true);
      expect(schema.validate(11).isValid, false);

      expect(schema.validate(11).error, 'Too large');
    });

    test('positive validation', () {
      final schema = Jar.number().positive('Must be positive');

      expect(schema.validate(-1).isValid, false);
      expect(schema.validate(0).isValid, false);
      expect(schema.validate(1).isValid, true);

      expect(schema.validate(-1).error, 'Must be positive');
    });

    test('negative validation', () {
      final schema = Jar.number().negative('Must be negative');

      expect(schema.validate(-1).isValid, true);
      expect(schema.validate(0).isValid, false);
      expect(schema.validate(1).isValid, false);

      expect(schema.validate(1).error, 'Must be negative');
    });

    test('integer validation', () {
      final schema = Jar.number().integer('Must be integer');

      expect(schema.validate(1).isValid, true);
      expect(schema.validate(1.5).isValid, false);

      expect(schema.validate(1.5).error, 'Must be integer');
    });
  });

  group('Jar.boolean()', () {
    test('required validation', () {
      final schema = Jar.boolean().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate(true).isValid, true);
      expect(schema.validate(false).isValid, true);

      expect(schema.validate(null).error, 'Field is required');
    });

    test('isTrue validation', () {
      final schema = Jar.boolean().isTrue('Must be true');

      expect(schema.validate(true).isValid, true);
      expect(schema.validate(false).isValid, false);

      expect(schema.validate(false).error, 'Must be true');
    });

    test('isFalse validation', () {
      final schema = Jar.boolean().isFalse('Must be false');

      expect(schema.validate(false).isValid, true);
      expect(schema.validate(true).isValid, false);

      expect(schema.validate(true).error, 'Must be false');
    });

    test('optional validation', () {
      final schema = Jar.boolean().optional();

      expect(schema.validate(null).isValid, true);
      expect(schema.validate(true).isValid, true);
      expect(schema.validate(false).isValid, true);
    });
  });

  group('Jar.array()', () {
    test('required validation', () {
      final schema = Jar.array().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate([]).isValid, true);
      expect(schema.validate([1, 2, 3]).isValid, true);

      expect(schema.validate(null).error, 'Field is required');
    });

    test('min validation', () {
      final schema = Jar.array().min(2, 'Too few items');

      expect(schema.validate([]).isValid, false);
      expect(schema.validate([1]).isValid, false);
      expect(schema.validate([1, 2]).isValid, true);
      expect(schema.validate([1, 2, 3]).isValid, true);

      expect(schema.validate([1]).error, 'Too few items');
    });

    test('max validation', () {
      final schema = Jar.array().max(2, 'Too many items');

      expect(schema.validate([]).isValid, true);
      expect(schema.validate([1]).isValid, true);
      expect(schema.validate([1, 2]).isValid, true);
      expect(schema.validate([1, 2, 3]).isValid, false);

      expect(schema.validate([1, 2, 3]).error, 'Too many items');
    });

    test('of validation', () {
      final schema = Jar.array(Jar.number().min(5, 'Number too small'));

      expect(schema.validate([5, 6, 7]).isValid, true);
      expect(schema.validate([4, 5, 6]).isValid, false);

      final result = schema.validate([4, 5, 6]);
      expect(result.isValid, false);

      expect(result.details?['elementErrors']?[0], 'Number too small');
    });

    test('unique validation', () {
      final schema = Jar.array().unique('Must contain unique values');

      expect(schema.validate([1, 2, 3]).isValid, true);
      expect(schema.validate([1, 2, 2]).isValid, false);

      expect(schema.validate([1, 2, 2]).error, 'Must contain unique values');
    });
  });

  group('Jar.object()', () {
    test('required validation', () {
      final schema = Jar.object().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate({}).isValid, true);
      expect(schema.validate({'key': 'value'}).isValid, true);

      expect(schema.validate(null).error, 'Field is required');
    });

    test('shape validation', () {
      final schema = Jar.object({
        'name': Jar.string().required('Name is required'),
        'age': Jar.number().min(18, 'Must be at least 18'),
      });

      expect(
          schema.validate({
            'name': 'John',
            'age': 20,
          }).isValid,
          true);

      expect(
          schema.validate({
            'name': '',
            'age': 16,
          }).isValid,
          false);

      final result = schema.validate({
        'name': '',
        'age': 16,
      });

      expect(result.details?['errors']?[0]['path'], 'name');
      expect(result.details?['errors']?[0]['message'], 'Name is required');
      expect(result.details?['errors']?[1]['path'], 'age');
      expect(result.details?['errors']?[1]['message'], 'Must be at least 18');
    });

    test('nested object validation', () {
      final schema = Jar.object({
        'user': Jar.object({
          'profile': Jar.object({
            'name': Jar.string().required('Name is required'),
          }),
        }),
      });

      expect(
          schema.validate({
            'user': {
              'profile': {
                'name': 'John',
              },
            },
          }).isValid,
          true);

      expect(
          schema.validate({
            'user': {
              'profile': {
                'name': '',
              },
            },
          }).isValid,
          false);

      final result = schema.validate({
        'user': {
          'profile': {
            'name': '',
          },
        },
      });

      expect(result.details?['errors']?[0]['path'], 'user.profile.name');
      expect(result.details?['errors']?[0]['message'], 'Name is required');
    });
  });

  group('Jar.date()', () {
    test('required validation', () {
      final schema = Jar.date().required('Date is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate(DateTime.now()).isValid, true);

      expect(schema.validate(null).error, 'Date is required');
    });

    test('min validation', () {
      final minDate = DateTime(2023, 1, 1);
      final schema = Jar.date().min(minDate, 'Date too early');

      expect(schema.validate(DateTime(2022, 12, 31)).isValid, false);
      expect(schema.validate(DateTime(2023, 1, 1)).isValid, true);
      expect(schema.validate(DateTime(2023, 1, 2)).isValid, true);

      expect(schema.validate(DateTime(2022, 12, 31)).error, 'Date too early');
    });

    test('max validation', () {
      final maxDate = DateTime(2023, 12, 31);
      final schema = Jar.date().max(maxDate, 'Date too late');

      expect(schema.validate(DateTime(2023, 12, 31)).isValid, true);
      expect(schema.validate(DateTime(2024, 1, 1)).isValid, false);

      expect(schema.validate(DateTime(2024, 1, 1)).error, 'Date too late');
    });

    test('future validation', () {
      final schema = Jar.date().future('Must be in the future');
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      expect(schema.validate(yesterday).isValid, false);
      expect(schema.validate(tomorrow).isValid, true);

      expect(schema.validate(yesterday).error, 'Must be in the future');
    });

    test('past validation', () {
      final schema = Jar.date().past('Must be in the past');
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      expect(schema.validate(yesterday).isValid, true);
      expect(schema.validate(tomorrow).isValid, false);

      expect(schema.validate(tomorrow).error, 'Must be in the past');
    });
  });

  group('Jar.mixed()', () {
    test('required validation', () {
      final schema = Jar.mixed().required('Field is required');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate('').isValid, true);
      expect(schema.validate(0).isValid, true);
      expect(schema.validate(false).isValid, true);

      expect(schema.validate(null).error, 'Field is required');
    });

    test('oneOf validation', () {
      final schema =
          Jar.mixed().oneOf(['apple', 'banana', 'orange'], 'Invalid fruit');

      expect(schema.validate('apple').isValid, true);
      expect(schema.validate('banana').isValid, true);
      expect(schema.validate('pear').isValid, false);

      expect(schema.validate('pear').error, 'Invalid fruit');
    });

    test('notOneOf validation', () {
      final schema = Jar.mixed().notOneOf([null, ''], 'Value cannot be empty');

      expect(schema.validate(null).isValid, false);
      expect(schema.validate('').isValid, false);
      expect(schema.validate('value').isValid, true);

      expect(schema.validate('').error, 'Value cannot be empty');
    });
  });

  group('Real-world schemas', () {
    test('Sign-in schema', () {
      final signInSchema = Jar.object({
        'email': Jar.string()
            .trim()
            .lowercase()
            .email('Invalid email format')
            .required('Email is required'),
        'password': Jar.string()
            .min(8, 'Password must be at least 8 characters')
            .max(20, 'Password cannot exceed 20 characters')
            .required('Password is required'),
        'keepSignedIn': Jar.boolean().optional(),
      });

      expect(
          signInSchema.validate({
            'email': 'test@example.com',
            'password': 'password123',
            'keepSignedIn': true,
          }).isValid,
          true);

      expect(
          signInSchema.validate({
            'email': 'invalid-email',
            'password': 'short',
          }).isValid,
          false);

      final result = signInSchema.validate({
        'email': 'invalid-email',
        'password': 'short',
      });

      expect(result.details?['errors']?.length, 2);
    });

    test('Sign-up schema', () {
      final signUpSchema = Jar.object({
        'fullName': Jar.string()
            .trim()
            .min(3, 'Name must be at least 3 characters')
            .max(40, 'Name cannot exceed 40 characters')
            .required('Full name is required'),
        'email': Jar.string()
            .trim()
            .lowercase()
            .email('Invalid email format')
            .required('Email is required'),
        'password': Jar.string()
            .trim()
            .min(8, 'Password must be at least 8 characters')
            .max(20, 'Password cannot exceed 20 characters')
            .matches(r'^(?=.*[A-Z])', 'Password must include uppercase letter')
            .matches(r'^(?=.*[a-z])', 'Password must include lowercase letter')
            .matches(r'^(?=.*[0-9])', 'Password must include a number')
            .required('Password is required'),
        'acceptTerms': Jar.boolean()
            .isTrue('You must accept terms and conditions')
            .required('You must accept terms and conditions'),
      });

      expect(
          signUpSchema.validate({
            'fullName': 'John Doe',
            'email': 'john@example.com',
            'password': 'Password123',
            'acceptTerms': true,
          }).isValid,
          true);

      expect(
          signUpSchema.validate({
            'fullName': 'Jo',
            'email': 'invalid-email',
            'password': 'password',
            'acceptTerms': false,
          }).isValid,
          false);

      final result = signUpSchema.validate({
        'fullName': 'Jo',
        'email': 'invalid-email',
        'password': 'password',
        'acceptTerms': false,
      });

      expect(result.details?['errors']?.length, 4);
    });

    test('Forgot password schema', () {
      final forgotPasswordSchema = Jar.object({
        'email': Jar.string()
            .trim()
            .lowercase()
            .email('Invalid email format')
            .required('Email is required'),
      });

      final forgotPasswordVerifyCodeSchema = Jar.object({
        'code': Jar.string()
            .trim()
            .matches(r'^[0-9]{5}$', 'Code must be 5 digits')
            .required('Code is required'),
      });

      final forgotPasswordNewPasswordSchema = Jar.object({
        'password': Jar.string()
            .trim()
            .min(8, 'Password must be at least 8 characters')
            .max(20, 'Password cannot exceed 20 characters')
            .matches(r'^(?=.*[A-Z])', 'Password must include uppercase letter')
            .matches(r'^(?=.*[a-z])', 'Password must include lowercase letter')
            .matches(r'^(?=.*[0-9])', 'Password must include a number')
            .required('Password is required'),
        'confirmPassword': Jar.string()
            .trim()
            .equalTo('password', 'Passwords must match')
            .required('Confirm password is required'),
      });

      expect(
          forgotPasswordSchema.validate({
            'email': 'test@example.com',
          }).isValid,
          true);

      expect(
          forgotPasswordVerifyCodeSchema.validate({
            'code': '12345',
          }).isValid,
          true);

      expect(
          forgotPasswordNewPasswordSchema.validate({
            'password': 'Password123',
            'confirmPassword': 'Password123',
          }).isValid,
          true);

      expect(
          forgotPasswordNewPasswordSchema.validate({
            'password': 'Password123',
            'confirmPassword': 'DifferentPassword123',
          }).isValid,
          false);
    });
  });
}
