void main() {
  String apiValue = "6.881,46";
  String step1 = apiValue.replaceAll('.', '');
  String step2 = step1.replaceAll(',', '.');
  double? val = double.tryParse(step2);
  // ignore: avoid_print
  print('Result: $val');
}
