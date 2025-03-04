import 'package:flutter_test/flutter_test.dart';
import 'package:jar/jar.dart';

void main() {
  group('Complete form validation scenarios', () {
    test('E-commerce checkout form', () {
      final addressSchema = Jar.object({
        'street': Jar.string().required('Street is required'),
        'city': Jar.string().required('City is required'),
        'state': Jar.string().required('State is required'),
        'zipCode': Jar.string()
            .matches(r'^\d{5}(-\d{4})?$', 'Invalid zip code')
            .required('Zip code is required'),
      });

      final paymentSchema = Jar.object({
        'paymentType': Jar.string().oneOf(['credit', 'paypal', 'wire'],
            'Invalid payment type').required('Payment type is required'),
      });

      paymentSchema.fields['creditCardNumber'] =
          Jar.string().when('paymentType', {
        'credit': (s) => s
            .matches(r'^\d{16}$', 'Credit card must be 16 digits')
            .required('Credit card number is required'),
        'paypal': (s) => s.optional(),
        'wire': (s) => s.optional(),
      });

      paymentSchema.fields['paypalEmail'] = Jar.string().when('paymentType', {
        'paypal': (s) =>
            s.email('Invalid email').required('PayPal email is required'),
        'credit': (s) => s.optional(),
        'wire': (s) => s.optional(),
      });

      paymentSchema.fields['wireInstructions'] =
          Jar.string().when('paymentType', {
        'wire': (s) => s.required('Wire transfer instructions required'),
        'credit': (s) => s.optional(),
        'paypal': (s) => s.optional(),
      });

      final checkoutSchema = Jar.object({
        'customer': Jar.object({
          'name': Jar.string().required('Name is required'),
          'email':
              Jar.string().email('Invalid email').required('Email is required'),
          'phone': Jar.string().matches(r'^\d{10}$', 'Phone must be 10 digits'),
        }),
        'billingAddress': addressSchema,
        'shippingAddress': addressSchema,
        'sameAsShipping': Jar.boolean(),
        'payment': paymentSchema,
        'terms': Jar.boolean()
            .isTrue('Must accept terms')
            .required('Terms is required'),
      });

      expect(
          checkoutSchema.validate({
            'customer': {
              'name': 'John Doe',
              'email': 'john@example.com',
              'phone': '1234567890',
            },
            'billingAddress': {
              'street': '123 Main St',
              'city': 'Springfield',
              'state': 'IL',
              'zipCode': '12345',
            },
            'shippingAddress': {
              'street': '123 Main St',
              'city': 'Springfield',
              'state': 'IL',
              'zipCode': '12345',
            },
            'sameAsShipping': true,
            'payment': {
              'paymentType': 'credit',
              'creditCardNumber': '1234567890123456',
            },
            'terms': true,
          }).isValid,
          true);

      expect(
          checkoutSchema.validate({
            'customer': {
              'name': 'Jane Doe',
              'email': 'jane@example.com',
              'phone': '9876543210',
            },
            'billingAddress': {
              'street': '456 Oak Ave',
              'city': 'Riverdale',
              'state': 'NY',
              'zipCode': '54321',
            },
            'shippingAddress': {
              'street': '456 Oak Ave',
              'city': 'Riverdale',
              'state': 'NY',
              'zipCode': '54321',
            },
            'sameAsShipping': true,
            'payment': {
              'paymentType': 'paypal',
              'paypalEmail': 'jane@example.com',
            },
            'terms': true,
          }).isValid,
          true);

      final result = checkoutSchema.validate({
        'customer': {
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '1234567890',
        },
        'billingAddress': {
          'street': '123 Main St',
          'city': 'Springfield',
          'state': 'IL',
          'zipCode': '12345',
        },
        'shippingAddress': {
          'street': '123 Main St',
          'city': 'Springfield',
          'state': 'IL',
          'zipCode': '12345',
        },
        'sameAsShipping': true,
        'payment': {
          'paymentType': 'credit',
          'creditCardNumber': '1234567890123456',
        },
        'terms': false,
      });

      expect(result.isValid, false);
      expect(result.details?['errors']?[0]['path'], 'terms');
      expect(result.details?['errors']?[0]['message'], 'Must accept terms');
    });
  });

  group('Multi-step form validation', () {
    test('Wizard form validation', () {
      final userInfoSchema = Jar.object({
        'fullName': Jar.string().required('Name is required'),
        'email':
            Jar.string().email('Invalid email').required('Email is required'),
      });

      final professionalInfoSchema = Jar.object({
        'company': Jar.string().required('Company is required'),
        'position': Jar.string().required('Position is required'),
        'yearsExperience': Jar.number()
            .min(0, 'Invalid years')
            .required('Experience is required'),
      });

      final skillsSchema = Jar.object({
        'primarySkill': Jar.string().required('Primary skill is required'),
        'skillLevel': Jar.number()
            .min(1, 'Min level is 1')
            .max(10, 'Max level is 10')
            .required('Skill level is required'),
        'additionalSkills': Jar.array(Jar.string())
            .min(1, 'At least one additional skill required'),
      });

      expect(
          userInfoSchema.validate({
            'fullName': 'John Doe',
            'email': 'john@example.com',
          }).isValid,
          true);

      expect(
          professionalInfoSchema.validate({
            'company': 'ABC Corp',
            'position': 'Developer',
            'yearsExperience': 5,
          }).isValid,
          true);

      expect(
          skillsSchema.validate({
            'primarySkill': 'Flutter',
            'skillLevel': 8,
            'additionalSkills': ['Dart', 'Firebase'],
          }).isValid,
          true);

      final completeSchema =
          userInfoSchema.merge(professionalInfoSchema).merge(skillsSchema);

      expect(
          completeSchema.validate({
            'fullName': 'John Doe',
            'email': 'john@example.com',
            'company': 'ABC Corp',
            'position': 'Developer',
            'yearsExperience': 5,
            'primarySkill': 'Flutter',
            'skillLevel': 8,
            'additionalSkills': ['Dart', 'Firebase'],
          }).isValid,
          true);
    });
  });
}
