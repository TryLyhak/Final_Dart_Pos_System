import 'dart:io';

String readString({required String prompt}) {
  while (true) {
    stdout.write(prompt);
    final value = stdin.readLineSync()?.trim() ?? '';
    if (value.isNotEmpty) return value;
    print('Input cannot be empty. Please try again.');
  }
}

int readInt({required String prompt}) {
  while (true) {
    stdout.write(prompt);
    final raw = stdin.readLineSync()?.trim() ?? '';
    final parsed = int.tryParse(raw);
    if (parsed != null) return parsed;
    print('Please enter a valid number. Try again.');
  }
}

double readDouble({required String prompt}) {
  while (true) {
    stdout.write(prompt);
    final raw = stdin.readLineSync()?.trim() ?? '';
    final parsed = double.tryParse(raw);
    if (parsed != null && parsed > 0) return parsed;
    print('Please enter a valid number. Try again.');
  }
}

void printDivider() {
  print('=' * 45);
}

void printHeader(String title) {
  printDivider();
  print(title.toUpperCase());
  printDivider();
}
