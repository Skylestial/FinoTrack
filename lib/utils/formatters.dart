String formatCurrency(double value) {
  final rounded = value.round();
  return '\u20B9 ${_formatWithCommas(rounded)}';
}

String formatPercent(double value) {
  return '${value.toStringAsFixed(1)}%';
}

String _formatWithCommas(int value) {
  final text = value.toString();
  if (text.length <= 3) {
    return text;
  }

  final buffer = StringBuffer();
  var count = 0;
  for (var i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write(',');
      count = 0;
    }
  }
  return buffer.toString().split('').reversed.join();
}
