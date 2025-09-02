String formatCurrency(double amount) {
  String result = amount.toStringAsFixed(0);
  String formatted = '';
  int counter = 0;

  for (int i = result.length - 1; i >= 0; i--) {
    if (counter == 3) {
      formatted = '.$formatted';
      counter = 0;
    }
    formatted = result[i] + formatted;
    counter++;
  }
  return 'Rp $formatted';
}
