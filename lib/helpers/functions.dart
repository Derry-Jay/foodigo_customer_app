class Functions {
  Functions();
  bool xor(bool a, bool b) =>
      a != null && b != null && ((!a && b) || (a && !b));
}
