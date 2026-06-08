class TableView {
  void printTable(
    List<String> headers,
    List<List<String?>> rows, {
    required List<bool> numericColumns,
  }) {
    if (rows.isEmpty) {
      print('  \x1B[33m⚠ No records found matching query.\x1B[0m');
      return;
    }

    // Convert nulls to clean empty strings safely
    final safeRows = rows
        .map((row) => row.map((cell) => cell ?? '').toList())
        .toList();

    // Calculate column widths based on longest string lengths
    final widths = List<int>.generate(headers.length, (colIndex) {
      final headerWidth = _getVisualLength(headers[colIndex]);
      final rowWidth = safeRows.fold<int>(0, (max, row) {
        int currentLen = _getVisualLength(row[colIndex]);
        return currentLen > max ? currentLen : max;
      });
      return headerWidth > rowWidth ? headerWidth : rowWidth;
    });

    // Generate sleek box borders using smooth Unicode drawing glyphs
    final topBorder = _buildCustomBorder(
      widths,
      left: '┌',
      sep: '┬',
      right: '┐',
    );
    final middleBorder = _buildCustomBorder(
      widths,
      left: '├',
      sep: '┼',
      right: '┤',
    );
    final bottomBorder = _buildCustomBorder(
      widths,
      left: '└',
      sep: '┴',
      right: '┘',
    );

    // Print out the complete structured table
    print('\x1B[90m$topBorder\x1B[0m'); // Subtle dark gray grid line
    print(_buildRow(headers, widths, numericColumns, useHeaderColor: true));
    print('\x1B[90m$middleBorder\x1B[0m');

    for (final row in safeRows) {
      print(_buildRow(row, widths, numericColumns, useHeaderColor: false));
    }

    print('\x1B[90m$bottomBorder\x1B[0m');
  }

  // UI VIEW METHODS

  // Display products table with color-coded stock alerts
  void displayProducts(List<dynamic> products) {
    final List<List<String>> formattedRows = [];

    for (var p in products) {
      int stock = p.stock ?? 0;
      String stockString;

      // Apply dynamic colors to the stock fields based on inventory depth
      if (stock == 0) {
        stockString = '\x1B[1m\x1B[31mOUT\x1B[0m'; // Bold Red
      } else if (stock < 5) {
        stockString = '\x1B[33m$stock [LOW]\x1B[0m'; // Yellow
      } else {
        stockString = '\x1B[32m$stock\x1B[0m'; // Green
      }

      formattedRows.add([
        p.id.toString(),
        p.name.toString(),
        (p.categoryName ?? 'Unassigned').toString(),
        '\x1B[36m\$${p.price?.toStringAsFixed(2)}\x1B[0m', // Cyan Price Tag
        stockString,
      ]);
    }

    printTable(
      ['ID', 'Product Name', 'Category', 'Price', 'Stock'],
      formattedRows,
      numericColumns: [true, false, false, true, true],
    );
  }

  // Display categories table
  void displayCategories(List<dynamic> categories) {
    printTable(
      ['ID', 'Category Name'],
      categories.map((c) => [c.id.toString(), c.name.toString()]).toList(),
      numericColumns: [true, false],
    );
  }

  // Display orders table with colored statuses
  void displayOrders(List<dynamic> orders) {
    final List<List<String>> formattedRows = [];

    for (var o in orders) {
      String status = (o.status ?? 'pending').toString().toUpperCase();

      if (status == 'COMPLETED' || status == 'PAID') {
        status =
            '\x1B[32m$status\x1B[0m'; // Green for successful complete orders
      } else if (status == 'PENDING') {
        status =
            '\x1B[33m$status\x1B[0m'; // Yellow for incomplete pending actions
      }

      formattedRows.add([
        o.id.toString(),
        (o.userId ?? 'N/A').toString(),
        '\x1B[32m\$${o.total?.toStringAsFixed(2)}\x1B[0m',
        status,
        (o.createdAt ?? 'N/A').toString(),
      ]);
    }

    printTable(
      ['ID', 'User', 'Total', 'Status', 'Date'],
      formattedRows,
      numericColumns: [true, false, true, false, false],
    );
  }

  // Display cart table with a neat cash tabulation section
  void displayCart(dynamic cart) {
    if (cart.isEmpty) {
      print('\n  \x1B[90m[ Your shopping cart is empty ]\x1B[0m\n');
      return;
    }

    printTable(
      ['ID', 'Product Name', 'Price', 'Qty', 'Subtotal'],
      cart.items
          .map<List<String?>>(
            (item) => [
              item.product.id.toString(),
              item.product.name.toString(),
              '\$${item.product.price?.toStringAsFixed(2)}',
              item.quantity.toString(),
              '\$${item.subtotal.toStringAsFixed(2)}',
            ],
          )
          .toList(),
      numericColumns: [true, false, true, true, true],
    );

    // Bottom summary tabulation cards
    print('  Summary: \x1B[1m${cart.itemCount}\x1B[0m lines registered.');
    print(
      '  Total  : \x1B[1m\x1B[32m\$${cart.total.toStringAsFixed(2)}\x1B[0m\n',
    );
  }

  // Display receipt as a realistic point-of-sale voucher slip
  void displayReceipt(dynamic order) {
    if (order == null) {
      print('\n\x1B[31m[!] Error: Cannot display empty order record.\x1B[0m\n');
      return;
    }

    // 1. Receipt Outer Frame Header
    // print('\n=======================================================');
    // print('                      OFFICIAL RECEIPT                 ');
    // print('=======================================================');

    // 2. Order Meta Information Block
    print('  Order Reference : #${order.id.toString().padRight(10)}');
    print('  Transaction Date: ${(order.createdAt ?? 'N/A').padRight(10)}');
    print('  Order Status    : ${(order.status ?? 'Pending').toUpperCase()}');
    print('-------------------------------------------------------');

    // 3. Line Items Column Headers
    print(
      '  ${'ITEM DESCRIPTION'.padRight(22)} '
      '${'PRICE'.padLeft(9)} '
      '${'QTY'.padLeft(5)} '
      '${'SUBTOTAL'.padLeft(11)}',
    );
    print('-------------------------------------------------------');

    // 4. Populate Line Items Loops
    if (order.items == null || order.items.isEmpty) {
      print('            -- No items registered to order --          ');
    } else {
      for (var item in order.items) {
        // Safe string extraction handling null fields gracefully
        String name = item.productName?.toString() ?? 'Unknown Item';
        String price = '\$${(item.unitPrice ?? 0.0).toStringAsFixed(2)}';
        String qty = item.quantity?.toString() ?? '0';
        String subtotal = '\$${(item.subtotal ?? 0.0).toStringAsFixed(2)}';

        // Truncate overly long product names to preserve right padding margins
        if (name.length > 22) {
          name = '${name.substring(0, 19)}...';
        }

        print(
          '  ${name.padRight(22)} '
          '${price.padLeft(9)} '
          '${qty.padLeft(5)} '
          '${subtotal.padLeft(11)}',
        );
      }
    }

    // 5. Financial Tabulations Calculation Summary Block
    print('-------------------------------------------------------');

    String finalTotal = '\$${(order.total ?? 0.0).toStringAsFixed(2)}';

    // Highlight final balance with bold ANSI terminal coloration rules
    print(
      '  \x1B[1m${'NET AMOUNT PAID:'.padRight(38)} \x1B[32m${finalTotal.padLeft(13)}\x1B[0m',
    );
    print('=======================================================\n');
  }

  // INTERNAL PRIVATE HELPER LOGIC

  // Safely calculates the visible width of text, completely ignoring invisible ANSI escape codes
  int _getVisualLength(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '').length;
  }

  // Assembles custom border strings using Unicode glyph outlines
  String _buildCustomBorder(
    List<int> widths, {
    required String left,
    required String sep,
    required String right,
  }) {
    final parts = widths.map(
      (w) => '─' * (w + 2),
    ); // Add 2 for internal cell padding spaces
    return '$left${parts.join(sep)}$right';
  }

  // Constructs individual aligned rows with proper cell compensation logic
  String _buildRow(
    List<String> values,
    List<int> widths,
    List<bool> numericColumns, {
    required bool useHeaderColor,
  }) {
    final cells = <String>[];

    for (var i = 0; i < values.length; i++) {
      String cellText = values[i];

      // Calculate missing character counts consumed by invisible color codes
      int visibleLen = _getVisualLength(cellText);
      int codeOffset = cellText.length - visibleLen;

      String paddedCell = numericColumns[i]
          ? cellText.padLeft(widths[i] + codeOffset)
          : cellText.padRight(widths[i] + codeOffset);

      if (useHeaderColor) {
        paddedCell = '\x1B[1m\x1B[37m$paddedCell\x1B[0m'; // Bold White styling
      }

      cells.add(paddedCell);
    }

    // Connect individual rows using crisp vertical border walls
    return '\x1B[90m│\x1B[0m ${cells.join(' \x1B[90m│\x1B[0m ')} \x1B[90m│\x1B[0m';
  }
}
