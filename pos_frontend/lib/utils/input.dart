import 'dart:io';
import 'package:pos_frontend/utils/exceptions.dart';

String validateRequiredText(String value, {String fieldName = 'Value'}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ValidationException(message: '$fieldName is required.');
  }
  return trimmed;
}

String validateSearchKeyword(String value) {
  final keyword = validateRequiredText(value, fieldName: 'Search keyword');
  if (keyword.length < 2) {
    throw ValidationException(
      message: 'Search keyword must be at least 2 characters.',
    );
  }
  return keyword;
}

int validateId(int value, {String fieldName = 'ID'}) {
  if (value <= 0) {
    throw ValidationException(message: '$fieldName must be greater than zero.');
  }
  return value;
}

int validateNonNegativeInt(int value, {String fieldName = 'Value'}) {
  if (value < 0) {
    throw ValidationException(message: '$fieldName cannot be negative.');
  }
  return value;
}

int validatePositiveInt(int value, {String fieldName = 'Value'}) {
  if (value <= 0) {
    throw ValidationException(message: '$fieldName must be greater than zero.');
  }
  return value;
}

double validatePositiveDouble(double value, {String fieldName = 'Value'}) {
  if (value <= 0) {
    throw ValidationException(message: '$fieldName must be greater than zero.');
  }
  return value;
}

String readString({
  required String prompt,
  String fieldName = 'Value',
  int? minLength,
  int? maxLength,
}) {
  while (true) {
    stdout.write(prompt);
    final value = stdin.readLineSync() ?? '';

    try {
      final trimmed = validateRequiredText(value, fieldName: fieldName);

      if (minLength != null && trimmed.length < minLength) {
        print('⚠ $fieldName must be at least $minLength characters.');
        continue;
      }

      if (maxLength != null && trimmed.length > maxLength) {
        print('⚠ $fieldName must not exceed $maxLength characters.');
        continue;
      }

      return trimmed;
    } on ValidationException catch (e) {
      print('⚠ ${e.message}');
    }
  }
}

int readInt({required String prompt, int? min, int? max}) {
  while (true) {
    stdout.write(prompt);
    final raw = stdin.readLineSync()?.trim() ?? '';

    final value = int.tryParse(raw);

    if (value == null) {
      print('⚠ Please enter a valid whole number.');
      continue;
    }

    if (min != null && value < min) {
      print('⚠ Value must be at least $min.');
      continue;
    }

    if (max != null && value > max) {
      print('⚠ Value must not exceed $max.');
      continue;
    }

    return value;
  }
}

double readDouble({required String prompt, double? min, double? max}) {
  while (true) {
    stdout.write(prompt);
    final raw = stdin.readLineSync()?.trim() ?? '';

    final value = double.tryParse(raw);

    if (value == null) {
      print('⚠ Please enter a valid number.');
      continue;
    }

    if (min != null && value < min) {
      print('⚠ Value must be at least $min.');
      continue;
    }

    if (max != null && value > max) {
      print('⚠ Value must not exceed $max.');
      continue;
    }

    return value;
  }
}

bool readYesNo({required String prompt}) {
  while (true) {
    stdout.write('$prompt (Y/N): ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (input == 'y' || input == 'yes') return true;
    if (input == 'n' || input == 'no') return false;

    print('⚠ Please enter Y or N.');
  }
}

// void printHeader(String title) {
//   print('=' * 60);
//   print(title.toUpperCase());
//   print('=' * 60);
// }
void printHeader(String title) {
  print('=' * 60);

  // Convert to uppercase first
  String upperTitle = title.toUpperCase();

  // Calculate how much padding is needed on the left to center it
  int leftPadding = ((60 + upperTitle.length) / 2).floor();

  // padLeft brings it to the middle, then padRight fills the rest if needed
  print(upperTitle.padLeft(leftPadding));
  print('=' * 60);
}
