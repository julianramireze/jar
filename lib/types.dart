import 'package:jar/schema.dart';
import 'package:jar/types/array.dart';
import 'package:jar/types/boolean.dart';
import 'package:jar/types/date.dart';
import 'package:jar/types/mixed.dart';
import 'package:jar/types/number.dart';
import 'package:jar/types/object.dart';
import 'package:jar/types/string.dart';

typedef JarValidator<T> = String? Function(T? value);
typedef JarValueTransformer<T> = T? Function(T? value);

class Jar {
  static JarString string() => JarString();
  static JarNumber number() => JarNumber();
  static JarDate date() => JarDate();
  static JarBoolean boolean() => JarBoolean();
  static JarArray<T> array<T>(
          [JarSchema<T, JarSchema<T, dynamic>>? elementSchema]) =>
      JarArray<T>(elementSchema);
  static JarObject object(
          [Map<String, JarSchema<dynamic, JarSchema<dynamic, dynamic>>>?
              fields]) =>
      JarObject(fields: fields ?? {});
  static JarMixed<T> mixed<T>() => JarMixed<T>();
}