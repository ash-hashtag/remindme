class globals{
  static bool? isBackground;
}

Future<bool> delay() async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
}