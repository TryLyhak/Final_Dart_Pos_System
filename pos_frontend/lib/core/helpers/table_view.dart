void _printTable(
  List<String> headers,
  List<List<String>> rows, {
  required List<bool> numericColumns,
}) {
  final widths = List<int>.generate(headers.length, (columnIndex) {
    final headerWidth = headers[columnIndex].length;
    final rowWidth = rows.fold<int>(
      0,
      (currentMax, row) => row[columnIndex].length > currentMax
          ? row[columnIndex].length
          : currentMax,
    );
    return headerWidth > rowWidth ? headerWidth : rowWidth;
  });

  final border = _buildBorder(widths);
  print(border);
  print(_buildRow(headers, widths, numericColumns));
  print(border);
  for (final row in rows) {
    print(_buildRow(row, widths, numericColumns));
  }
  print(border);
}

String _buildBorder(List<int> widths) {
  return '+${widths.map((width) => '-' * (width + 2)).join('+')}+';
}

String _buildRow(
  List<String> values,
  List<int> widths,
  List<bool> numericColumns,
) {
  final cells = <String>[];
  for (var i = 0; i < values.length; i++) {
    cells.add(
      numericColumns[i]
          ? values[i].padLeft(widths[i])
          : values[i].padRight(widths[i]),
    );
  }

  return '| ${cells.join(' | ')} |';
}
