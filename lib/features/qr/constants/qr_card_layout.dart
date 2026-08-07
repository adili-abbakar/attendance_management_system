class QrCardLayout {
  const QrCardLayout._();


  // CARD SIZE (ISO/IEC ID-1)
  static const double cardWidthMm = 53.98;
  static const double cardHeightMm = 85.60;
  static const double portraitHeightFactor = cardHeightMm / cardWidthMm;


  // PDF GRID
  static const int columns = 3;
  static const int rows = 4;
  static const double pageMarginMm = 8;
  static const double horizontalSpacingMm = 4;
  static const double verticalSpacingMm = 4;


  // PREVIEW SIZE
  static const double previewWidth = 220;
  static const double previewHeight = previewWidth * portraitHeightFactor;
}
