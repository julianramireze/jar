# Changelog

All notable changes to the JAR validation library will be documented in this file.

## 1.1.1 - [2025-03-15]

### Fixed
- Improved type validation for arrays
  - Enhanced type checking for array elements
  - Fixed edge cases in array type validation
  - Added more robust type inference for mixed-type arrays

## 1.1.0 - [2025-03-15]

### Added
- Custom validation support with `.custom()` method for all schema types
  - Added to string, number, boolean, date, array, object, and mixed schemas
  - Allows for complex, context-aware validation rules
  - Returns dynamic error messages based on validation conditions
- Comprehensive test suite for custom validation scenarios
  - Basic validation tests for each schema type
  - Advanced validation tests for real-world scenarios
  - Complex conditional validation tests

### Changed
- Updated documentation to include custom validation examples
- Improved error handling for validation functions

## 1.0.0 - [2025-03-04]

### Added
- Initial release of JAR validation library
- Core schema types:
  - String validation with email, pattern matching, and transformations
  - Number validation with min/max, positive/negative, and integer checks
  - Boolean validation with true/false assertions
  - Date validation with past/future and min/max date ranges
  - Array validation with length constraints and element validation
  - Object validation with nested schemas and field requirements
  - Mixed type validation for flexible data structures
- Conditional validation with `.when()` method
- Schema composition with `.merge()` for multi-step forms
- Field transformation capabilities
- Comprehensive test suite