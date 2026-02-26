int normalizedToADC(double value) {
  return ((value + 1.0) * 2047.5).round().clamp(0, 4095);
}