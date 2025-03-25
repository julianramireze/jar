# JAR: Elegant Schema Validation for Flutter and Dart

[![pub package](https://img.shields.io/pub/v/jar.svg)](https://pub.dev/packages/jar)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

JAR is a powerful, flexible, and intuitive schema validation library for Flutter and Dart. Build type-safe validation schemas with a chainable API that makes complex validations simple and readable.

## Features

- 🔒 **Type-safe validation** for objects, strings, numbers, arrays, and more
- ⛓️ **Chainable API** for building intuitive validation rules
- 🔄 **Conditional validation** with `.when()` for dynamic requirements
- 🧠 **Context-aware validation** with access to all form values for cross-field validation
- 🌐 **Complex object validation** with nested schemas and custom error messages
- 🧩 **Schema composition** with `.merge()` for multi-step form validation
- 🛠️ **Custom validation** with `.custom()` for specialized validation logic
- 📱 **Flutter-friendly** for seamless form validation in your apps
- 🪶 **Lightweight** with zero external dependencies

## Installation

```bash
flutter pub add jar
```

## Quick Start

```dart
import 'package:jar/jar.dart';

void main() {
  // Define a schema
  final userSchema = Jar.object({
    'name': Jar.string().required('Name is required'),
    'email': Jar.string().email('Invalid email').required('Email is required'),
    'age': Jar.number().min(18, 'Must be at least 18 years old'),
  });

  // Validate data
  final result = userSchema.validate({
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 25,
  });

  print('Is valid: ${result.isValid}');

  // Invalid data example
  final invalidResult = userSchema.validate({
    'name': 'Jane Doe',
    'email': 'not-an-email',
    'age': 16,
  });

  print('Is valid: ${invalidResult.isValid}');
  print('Errors: ${invalidResult.details?['errors']}');
}
```

## Validators

JAR provides a variety of built-in validators for common use cases:

### String Validation

```dart
final emailSchema = Jar.string()
  .email('Invalid email format')
  .required('Email is required');

final passwordSchema = Jar.string()
  .min(8, 'Password must be at least 8 characters')
  .matches(r'(?=.*[A-Z])', 'Must contain at least one uppercase letter')
  .required('Password is required');
```

#### JarString Methods

- `.required([String? message])` - Ensures the value is not null or empty
- `.optional()` - Makes the field optional (clears previous validators)
- `.trim()` - Transforms the string by removing leading and trailing whitespace
- `.lowercase()` - Transforms the string to lowercase
- `.uppercase()` - Transforms the string to uppercase
- `.min(int length, [String? message])` - Ensures minimum string length
- `.max(int length, [String? message])` - Ensures maximum string length
- `.matches(String pattern, [String? message])` - Validates against a RegExp pattern
- `.email([String? message])` - Validates email format
- `.equalTo(String field, [String? message])` - Ensures the value equals another field's value
- `.oneOf(List<String> allowedValues, [String? message])` - Ensures the value is one of the allowed values
- `.custom(String? Function(String? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarString Function(JarString)> conditions)` - Applies conditional validation based on another field's value

### Number Validation

```dart
final ageSchema = Jar.number()
  .min(18, 'Must be at least 18 years old')
  .max(120, 'Invalid age')
  .required('Age is required');
```

#### JarNumber Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.min(num min, [String? message])` - Ensures minimum value
- `.max(num max, [String? message])` - Ensures maximum value
- `.positive([String? message])` - Ensures the value is positive (> 0)
- `.negative([String? message])` - Ensures the value is negative (< 0)
- `.integer([String? message])` - Ensures the value is an integer
- `.round()` - Transforms the value by rounding to the nearest integer
- `.truncate()` - Transforms the value by removing decimal places
- `.equalTo(String field, [String? message])` - Ensures the value equals another field's value
- `.custom(String? Function(num? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarNumber Function(JarNumber)> conditions)` - Applies conditional validation based on another field's value

### Boolean Validation

```dart
final termsSchema = Jar.boolean()
  .isTrue('You must accept the terms and conditions')
  .required('Please respond to the terms');
```

#### JarBoolean Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.isTrue([String? message])` - Ensures the value is true
- `.isFalse([String? message])` - Ensures the value is false
- `.equalTo(String field, [String? message])` - Ensures the value equals another field's value
- `.custom(String? Function(bool? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarBoolean Function(JarBoolean)> conditions)` - Applies conditional validation based on another field's value

### Date Validation

```dart
final birthDateSchema = Jar.date()
  .past('Birth date must be in the past')
  .required('Birth date is required');

final meetingSchema = Jar.date()
  .future('Meeting must be scheduled in the future')
  .required('Meeting date is required');
```

#### JarDate Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.min(DateTime min, [String? message])` - Ensures the date is after or equal to the minimum date
- `.max(DateTime max, [String? message])` - Ensures the date is before or equal to the maximum date
- `.future([String? message])` - Ensures the date is in the future (after now)
- `.past([String? message])` - Ensures the date is in the past (before now)
- `.equalTo(String field, [String? message])` - Ensures the value equals another field's value
- `.custom(String? Function(DateTime? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarDate Function(JarDate)> conditions)` - Applies conditional validation based on another field's value

### Array Validation

```dart
final skillsSchema = Jar.array(Jar.string())
  .min(1, 'At least one skill is required')
  .max(5, 'Maximum 5 skills allowed');
```

#### JarArray Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.min(int length, [String? message])` - Ensures minimum array length
- `.max(int length, [String? message])` - Ensures maximum array length
- `.length(int exactLength, [String? message])` - Ensures exact array length
- `.unique([String? message])` - Ensures all array elements are unique
- `.equalTo(String field, [String? message])` - Ensures the array equals another field's array
- `.custom(String? Function(List<T>? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarArray<T> Function(JarArray<T>)> conditions)` - Applies conditional validation based on another field's value

### Object Validation

```dart
final addressSchema = Jar.object({
  'street': Jar.string().required('Street is required'),
  'city': Jar.string().required('City is required'),
  'zipCode': Jar.string()
    .matches(r'^\d{5}(-\d{4})?$', 'Invalid zip code')
    .required('Zip code is required'),
});
```

#### JarObject Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.requireFields(List<String> fieldNames, [String? message])` - Ensures specific fields exist and are not null
- `.forbidFields(List<String> fieldNames, [String? message])` - Ensures specific fields do not exist
- `.requireAtLeastOne(List<String> fieldNames, [String? message])` - Ensures at least one of the specified fields exists
- `.requireExactlyOne(List<String> fieldNames, [String? message])` - Ensures exactly one of the specified fields exists
- `.allowExtra()` - Allows extra fields not defined in the schema
- `.strict()` - Disallows extra fields not defined in the schema
- `.merge(JarObject other)` - Combines two object schemas
- `.extend(Map<String, JarSchema> additionalFields)` - Adds additional fields to the schema
- `.pick(List<String> fieldNames)` - Creates a new schema with only the specified fields
- `.omit(List<String> fieldNames)` - Creates a new schema without the specified fields
- `.equalTo(String field, [String? message])` - Ensures the object equals another field's object
- `.custom(String? Function(Map<String, dynamic>? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarObject Function(JarObject)> conditions)` - Applies conditional validation based on another field's value

### Mixed Type Validation

```dart
final mixedSchema = Jar.mixed<dynamic>()
  .oneOf(['option1', 'option2', 3, 4], 'Invalid option')
  .required('This field is required');
```

#### JarMixed Methods

- `.required([String? message])` - Ensures the value is not null
- `.optional()` - Makes the field optional (clears previous validators)
- `.oneOf(List<T> allowed, [String? message])` - Ensures the value is one of the allowed values
- `.notOneOf(List<T> forbiddenValues, [String? message])` - Ensures the value is not one of the forbidden values
- `.equalTo(String field, [String? message])` - Ensures the value equals another field's value
- `.custom(String? Function(T? value, [Map<String, dynamic>? allValues]) validator)` - Applies a custom validation function with access to all form values
- `.when(String field, Map<dynamic, JarMixed<T> Function(JarMixed<T>)> conditions)` - Applies conditional validation based on another field's value

### Custom Validation

JAR allows you to define your own validation logic with the `.custom()` method:

```dart
final passwordSchema = Jar.string().custom(
  (value, [allValues]) {
    if (value == null || value.isEmpty) return 'Password is required';

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasUppercase) return 'Password must include at least one uppercase letter';
    if (!hasLowercase) return 'Password must include at least one lowercase letter';
    if (!hasDigit) return 'Password must include at least one digit';
    if (!hasSpecialChar) return 'Password must include at least one special character';

    return null;
  },
);
```

### Cross-Field Validation

JAR provides powerful cross-field validation by giving you access to all form values in custom validators:

```dart
final passwordConfirmSchema = Jar.object({
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
```

### Conditional Validation

JAR provides a powerful conditional validation system with the `.when()` method:

```dart
final paymentSchema = Jar.object({
  'paymentType': Jar.string().oneOf(['credit', 'paypal'], 'Invalid payment type'),
});

paymentSchema.fields['creditCardNumber'] =
  Jar.string().when('paymentType', {
    'credit': (s) => s
      .matches(r'^\d{16}$', 'Card number must be 16 digits')
      .required('Credit card number is required'),
    'paypal': (s) => s.optional(),
  });
```

### Dependent Field Validation

JAR allows validating fields based on the values of other fields:

```dart
final userSchema = Jar.object({
  'country': Jar.string().required().oneOf(['US', 'CA', 'MX']),
  'postalCode': Jar.string().required().custom((value, [allValues]) {
    final country = allValues?['country'];

    if (country == 'US') {
      return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value!)
          ? null
          : 'US postal code must be in format 12345 or 12345-6789';
    } else if (country == 'CA') {
      return RegExp(r'^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$').hasMatch(value!)
          ? null
          : 'Canadian postal code must be in format A1A 1A1';
    } else if (country == 'MX') {
      return RegExp(r'^\d{5}$').hasMatch(value!)
          ? null
          : 'Mexican postal code must be 5 digits';
    }

    return null;
  }),
});
```

### Multi-step Form Validation

JAR makes it easy to combine schemas for multi-step form validation:

```dart
// Step 1: Personal info
final personalInfoSchema = Jar.object({
  'name': Jar.string().required('Name is required'),
  'email': Jar.string().email('Invalid email').required('Email is required'),
});

// Step 2: Address info
final addressSchema = Jar.object({
  'street': Jar.string().required('Street is required'),
  'city': Jar.string().required('City is required'),
});

// Combined schema for final validation
final completeSchema = personalInfoSchema.merge(addressSchema);
```

### Object-Level Validation

For complex validations that involve relationships between multiple fields, you can use object-level validation:

```dart
final creditCardSchema = Jar.object({
  'paymentMethod': Jar.string().required(),
  'creditCardNumber': Jar.string()
}).custom((value, [allValues]) {
  // Validation at object level
  if (value!['paymentMethod'] == 'creditCard' &&
      (value['creditCardNumber'] == null || value['creditCardNumber'].isEmpty)) {
    return 'Credit card number is required for credit card payments';
  }
  return null;
});
```

## License

JAR is available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Contributors

[Julian Ramirez](https://github.com/julianramireze)
