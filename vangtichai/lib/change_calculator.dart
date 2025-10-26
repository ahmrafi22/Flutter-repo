class ChangeCalculator {
  // Change List
  static const List<int> denominations = [500, 100, 50, 20, 10, 5, 2, 1];


  static Map<int, int> calculateChange(int amount) {
    Map<int, int> changeBreakdown = {};


    for (int denomination in denominations) {
      changeBreakdown[denomination] = 0;
    }

    if (amount == 0) {
      return changeBreakdown;
    }

    int remainingAmount = amount;

    // number of notes for each denomination
    for (int denomination in denominations) {
      if (remainingAmount >= denomination) {
        int count = remainingAmount ~/ denomination;
        changeBreakdown[denomination] = count;
        remainingAmount = remainingAmount % denomination;
      }
    }

    return changeBreakdown;
  }


  static String formatAmount(int amount) {
    String amountStr = amount.toString();
    String result = '';
    int counter = 0;

    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = ',$result';
        counter = 0;
      }
      result = amountStr[i] + result;
      counter++;
    }

    return result;
  }
}
