import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('JarObject advanced features', () {
    test('allowExtra validation', () {
      final schema = Jar.object({
        'name': Jar.string().required(),
      }).strict();

      expect(
          schema.validate({
            'name': 'John',
            'extra': 'field',
          }).isValid,
          false);

      final allowSchema = Jar.object({
        'name': Jar.string().required(),
      }).allowExtra();

      expect(
          allowSchema.validate({
            'name': 'John',
            'extra': 'field',
          }).isValid,
          true);
    });

    test('requireFields validation', () {
      final schema = Jar.object()
          .requireFields(['firstName', 'lastName'], 'Both names are required');

      expect(
          schema.validate({
            'firstName': 'John',
            'lastName': 'Doe',
          }).isValid,
          true);

      expect(
          schema.validate({
            'firstName': 'John',
          }).isValid,
          false);

      expect(
          schema.validate({
            'firstName': 'John',
          }).error,
          'Both names are required');
    });

    test('forbidFields validation', () {
      final schema =
          Jar.object().forbidFields(['password'], 'Password not allowed here');

      expect(
          schema.validate({
            'username': 'john',
          }).isValid,
          true);

      expect(
          schema.validate({
            'username': 'john',
            'password': '1234',
          }).isValid,
          false);

      expect(
          schema.validate({
            'password': '1234',
          }).error,
          'Password not allowed here');
    });

    test('requireAtLeastOne validation', () {
      final schema = Jar.object().requireAtLeastOne(
          ['email', 'phone'], 'Contact information is required');

      expect(
          schema.validate({
            'email': 'john@example.com',
          }).isValid,
          true);

      expect(
          schema.validate({
            'phone': '1234567890',
          }).isValid,
          true);

      expect(
          schema.validate({
            'email': 'john@example.com',
            'phone': '1234567890',
          }).isValid,
          true);

      expect(schema.validate({}).isValid, false);
      expect(schema.validate({}).error, 'Contact information is required');
    });

    test('requireExactlyOne validation', () {
      final schema = Jar.object().requireExactlyOne(
          ['creditCard', 'paypal', 'wire'],
          'Select exactly one payment method');

      expect(
          schema.validate({
            'creditCard': '4111111111111111',
          }).isValid,
          true);

      expect(
          schema.validate({
            'creditCard': '4111111111111111',
            'paypal': 'email@example.com',
          }).isValid,
          false);

      expect(
          schema.validate({
            'creditCard': '4111111111111111',
            'paypal': 'email@example.com',
          }).error,
          'Select exactly one payment method');
    });

    test('merge schemas', () {
      final addressSchema = Jar.object({
        'street': Jar.string().required('Street is required'),
        'city': Jar.string().required('City is required'),
      });

      final contactSchema = Jar.object({
        'phone': Jar.string().matches(r'^\d{10}$', 'Invalid phone number'),
        'email': Jar.string().email('Invalid email'),
      });

      final mergedSchema = addressSchema.merge(contactSchema);

      expect(
          mergedSchema.validate({
            'street': '123 Main St',
            'city': 'Springfield',
            'phone': '1234567890',
            'email': 'test@example.com',
          }).isValid,
          true);

      expect(
          mergedSchema.validate({
            'street': '123 Main St',
            'city': 'Springfield',
            'phone': 'invalid',
            'email': 'test@example.com',
          }).isValid,
          false);
    });

    test('extend schema', () {
      final baseSchema = Jar.object({
        'id': Jar.number().required('ID is required'),
        'name': Jar.string().required('Name is required'),
      });

      final extendedSchema = baseSchema.extend({
        'email':
            Jar.string().email('Invalid email').required('Email is required'),
      });

      expect(
          extendedSchema.validate({
            'id': 1,
            'name': 'John',
            'email': 'john@example.com',
          }).isValid,
          true);

      expect(
          extendedSchema.validate({
            'id': 1,
            'name': 'John',
          }).isValid,
          false);
    });

    test('pick fields', () {
      final userSchema = Jar.object({
        'id': Jar.number().required('ID is required'),
        'name': Jar.string().required('Name is required'),
        'email':
            Jar.string().email('Invalid email').required('Email is required'),
        'password': Jar.string().required('Password is required'),
      });

      final publicUserSchema = userSchema.pick(['id', 'name', 'email']);

      expect(
          publicUserSchema.validate({
            'id': 1,
            'name': 'John',
            'email': 'john@example.com',
          }).isValid,
          true);

      expect(
          publicUserSchema.validate({
            'id': 1,
            'name': 'John',
            'email': 'john@example.com',
          }).isValid,
          true);
    });

    test('omit fields', () {
      final userSchema = Jar.object({
        'id': Jar.number().required('ID is required'),
        'name': Jar.string().required('Name is required'),
        'email':
            Jar.string().email('Invalid email').required('Email is required'),
        'password': Jar.string().required('Password is required'),
      });

      final publicUserSchema = userSchema.omit(['password']);

      expect(
          publicUserSchema.validate({
            'id': 1,
            'name': 'John',
            'email': 'john@example.com',
          }).isValid,
          true);

      expect(
          publicUserSchema.validate({
            'id': 1,
            'name': 'John',
            'email': 'john@example.com',
            'password': 'secret',
          }).isValid,
          true);
    });
  });

  group('Conditional validation', () {
    test('conditional field validation with when', () {
      final schema = Jar.object({
        'isCompany':
            Jar.boolean().required('Please specify if you are a company'),
        'companyName': Jar.string(),
        'personalName': Jar.string(),
      });

      schema.fields['companyName'] = Jar.string().when('isCompany', {
        true: (s) => s.required('Company name is required for companies'),
        false: (s) => s.optional(),
      });

      schema.fields['personalName'] = Jar.string().when('isCompany', {
        false: (s) => s.required('Personal name is required for individuals'),
        true: (s) => s.optional(),
      });

      expect(
          schema.validate({
            'isCompany': true,
            'companyName': 'Acme Inc',
          }).isValid,
          true);

      expect(
          schema.validate({
            'isCompany': true,
            'personalName': 'John Doe',
          }).isValid,
          false);

      expect(
          schema.validate({
            'isCompany': false,
            'personalName': 'John Doe',
          }).isValid,
          true);

      expect(
          schema.validate({
            'isCompany': false,
            'companyName': 'Acme Inc',
          }).isValid,
          false);
    });
  });

  group('Transformations', () {
    test('string transformations', () {
      final schema = Jar.string()
          .transform((value) => value?.toUpperCase())
          .matches(r'^[A-Z]+$', 'Must be uppercase');

      expect(schema.validate('test').isValid, true);
      expect(schema.validate('Test').isValid, true);
      expect(schema.validate('TEST').isValid, true);
    });

    test('number transformations', () {
      final schema = Jar.number()
          .transform((value) => (value ?? 0) + 10)
          .min(15, 'Must be at least 15 after transformation');

      expect(schema.validate(3).isValid, false);
      expect(schema.validate(5).isValid, true);
      expect(schema.validate(10).isValid, true);
    });
  });

  group('Complex real-world schemas', () {
    test('Address validation schema', () {
      final addressSchema = Jar.object({
        'street': Jar.string().required('Street is required'),
        'city': Jar.string().required('City is required'),
        'state': Jar.string().required('State is required'),
        'zip': Jar.string()
            .matches(r'^\d{5}(-\d{4})?$', 'Invalid ZIP code format')
            .required('ZIP code is required'),
        'country': Jar.string().required('Country is required'),
        'isInternational': Jar.boolean().optional(),
      });

      addressSchema.fields['internationalCode'] =
          Jar.string().when('isInternational', {
        true: (s) => s.required('International code is required'),
        false: (s) => s.optional(),
      });

      expect(
          addressSchema.validate({
            'street': '123 Main St',
            'city': 'Springfield',
            'state': 'IL',
            'zip': '12345',
            'country': 'USA',
            'isInternational': false,
          }).isValid,
          true);

      expect(
          addressSchema.validate({
            'street': '123 Main St',
            'city': 'Springfield',
            'state': 'IL',
            'zip': '12345',
            'country': 'USA',
            'isInternational': true,
          }).isValid,
          false);

      expect(
          addressSchema.validate({
            'street': '123 Main St',
            'city': 'Springfield',
            'state': 'IL',
            'zip': '12345',
            'country': 'USA',
            'isInternational': true,
            'internationalCode': '123',
          }).isValid,
          true);
    });

    test('Product schema with variants', () {
      final variantSchema = Jar.object({
        'sku': Jar.string().required('SKU is required'),
        'price': Jar.number()
            .min(0, 'Price must be positive')
            .required('Price is required'),
        'inventory': Jar.number()
            .integer('Inventory must be an integer')
            .required('Inventory is required'),
      });

      final productSchema = Jar.object({
        'name': Jar.string().required('Product name is required'),
        'description': Jar.string().optional(),
        'category': Jar.string().required('Category is required'),
        'hasVariants':
            Jar.boolean().required('Specify if product has variants'),
        'basePrice': Jar.number().min(0, 'Base price must be positive'),
      });

      productSchema.fields['variants'] = Jar.array(variantSchema).when(
        'hasVariants',
        {
          true: (s) => s
              .min(1, 'At least one variant is required')
              .required('Variants are required'),
          false: (s) => s.optional(),
        },
      );

      productSchema.fields['basePrice'] = Jar.number().when(
        'hasVariants',
        {
          false: (s) => s
              .min(0, 'Base price must be positive')
              .required('Base price is required'),
          true: (s) => s.optional(),
        },
      );

      expect(
          productSchema.validate({
            'name': 'Simple Product',
            'description': 'A simple product without variants',
            'category': 'Electronics',
            'hasVariants': false,
            'basePrice': 19.99,
          }).isValid,
          true);

      expect(
          productSchema.validate({
            'name': 'Complex Product',
            'description': 'A product with multiple variants',
            'category': 'Clothing',
            'hasVariants': true,
            'variants': [
              {
                'sku': 'CLO-RED-S',
                'price': 29.99,
                'inventory': 10,
              },
              {
                'sku': 'CLO-RED-M',
                'price': 29.99,
                'inventory': 5,
              }
            ],
          }).isValid,
          true);

      expect(
          productSchema.validate({
            'name': 'Invalid Product',
            'description': 'A product claiming to have variants',
            'category': 'Clothing',
            'hasVariants': true,
          }).isValid,
          false);
    });
  });

  group('Custom validation methods', () {
    test('Custom email domain validation', () {
      final customEmailValidator =
          Jar.string().email('Invalid email format').addValidator(
        (value) {
          if (value == null || value.isEmpty) return null;
          if (!value.contains('@')) return null;
          final domain = value.split('@').last;
          if (['example.com', 'test.com'].contains(domain)) {
            return 'Email domain not allowed';
          }
          return null;
        },
      );

      expect(customEmailValidator.validate('user@example.com').isValid, false);
      expect(customEmailValidator.validate('user@test.com').isValid, false);
      expect(
          customEmailValidator.validate('user@valid-domain.com').isValid, true);
    });

    test('Password strength validator', () {
      final passwordStrengthValidator = Jar.string().addValidator(
        (value) {
          if (value == null || value.length < 8) return 'Password too short';

          int strength = 0;
          if (RegExp(r'[A-Z]').hasMatch(value)) strength++;
          if (RegExp(r'[a-z]').hasMatch(value)) strength++;
          if (RegExp(r'[0-9]').hasMatch(value)) strength++;
          if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) strength++;

          if (strength < 3) return 'Password not strong enough';
          return null;
        },
      );

      expect(passwordStrengthValidator.validate('password').isValid, false);
      expect(passwordStrengthValidator.validate('Password1!').isValid, true);
      expect(passwordStrengthValidator.validate('Pass1!').isValid, false);
    });
  });
}
