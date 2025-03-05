# JAR: Elegant Schema Validation for Flutter and Dart

[![pub package](https://img.shields.io/pub/v/jar.svg)](https://pub.dev/packages/jar)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

JAR is a powerful, flexible, and intuitive schema validation library for Flutter and Dart. Build type-safe validation schemas with a chainable API that makes complex validations simple and readable.

## Features

- 🔒 **Type-safe validation** for objects, strings, numbers, arrays, and more
- ⛓️ **Chainable API** for building intuitive validation rules
- 🔄 **Conditional validation** with `.when()` for dynamic requirements
- 🌐 **Complex object validation** with nested schemas and custom error messages
- 🧩 **Schema composition** with `.merge()` for multi-step form validation
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
- `.when(String field, Map<dynamic, JarMixed<T> Function(JarMixed<T>)> conditions)` - Applies conditional validation based on another field's value

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

## License

JAR is available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

JAR is developed and maintained by [Julian Ramirez](https://github.com/julianramireze).
