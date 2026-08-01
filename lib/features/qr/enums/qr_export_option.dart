enum QrExportOption {
  /// Export QR card(s) as a PDF.
  pdf,

  /// Export QR card(s) as PNG image(s).
  png,

  /// Export a ZIP archive containing PNG images.
  zipPng,

  /// Export a ZIP archive containing PDF files.
  zipPdf;

  /// Returns true if the export produces PDF files.
  bool get isPdf {
    switch (this) {
      case QrExportOption.pdf:
      case QrExportOption.zipPdf:
        return true;

      case QrExportOption.png:
      case QrExportOption.zipPng:
        return false;
    }
  }

  /// Returns true if the export produces PNG images.
  bool get isPng {
    switch (this) {
      case QrExportOption.png:
      case QrExportOption.zipPng:
        return true;

      case QrExportOption.pdf:
      case QrExportOption.zipPdf:
        return false;
    }
  }

  /// Returns true if the export is a ZIP archive.
  bool get isZip {
    switch (this) {
      case QrExportOption.zipPng:
      case QrExportOption.zipPdf:
        return true;

      case QrExportOption.pdf:
      case QrExportOption.png:
        return false;
    }
  }

  /// User-friendly label.
  String get label {
    switch (this) {
      case QrExportOption.pdf:
        return 'PDF';

      case QrExportOption.png:
        return 'PNG Image';

      case QrExportOption.zipPng:
        return 'ZIP of PNG Images';

      case QrExportOption.zipPdf:
        return 'ZIP of PDF Files';
    }
  }
}
