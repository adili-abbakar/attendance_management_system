enum QrExportOption {
  printPdf,
  pdf,
  png,
  zipPng,
  zipPdf;

  bool get isPdf {
    switch (this) {
      case QrExportOption.printPdf:
      case QrExportOption.pdf:
      case QrExportOption.zipPdf:
        return true;

      case QrExportOption.png:
      case QrExportOption.zipPng:
        return false;
    }
  }

  bool get isPng {
    switch (this) {
      case QrExportOption.png:
      case QrExportOption.zipPng:
        return true;

      case QrExportOption.printPdf:
      case QrExportOption.pdf:
      case QrExportOption.zipPdf:
        return false;
    }
  }

  bool get isZip {
    switch (this) {
      case QrExportOption.zipPng:
      case QrExportOption.zipPdf:
        return true;

      case QrExportOption.printPdf:
      case QrExportOption.pdf:
      case QrExportOption.png:
        return false;
    }
  }

  bool get isPrint {
    return this == QrExportOption.printPdf;
  }

  String get label {
    switch (this) {
      case QrExportOption.printPdf:
        return 'Print';

      case QrExportOption.pdf:
        return 'PDF Document';

      case QrExportOption.png:
        return 'PNG Image';

      case QrExportOption.zipPng:
        return 'ZIP of PNG Images';

      case QrExportOption.zipPdf:
        return 'ZIP of PDF Files';
    }
  }
}
