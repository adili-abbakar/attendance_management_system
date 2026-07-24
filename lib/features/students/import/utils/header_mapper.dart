class HeaderMapper {
  HeaderMapper._();

  static const admissionNumberHeaders = [
    'admission number',
    'admission no',
    'adm no',
    'admission',
    'registration number',
    'reg number',
    'matric number',
    'matric no',
  ];

  static const fullNameHeaders = [
    'student name',
    'name',
    'full name',
    'student',
  ];

  static int? findAdmissionNumberColumn(List<dynamic> headers) {
    return _findColumn(headers, admissionNumberHeaders);
  }

  static int? findFullNameColumn(List<dynamic> headers) {
    return _findColumn(headers, fullNameHeaders);
  }

  static int? _findColumn(List<dynamic> headers, List<String> acceptedHeaders) {
    for (int i = 0; i < headers.length; i++) {
      final value = headers[i]
          .toString()
          .replaceAll('\uFEFF', '')
          .replaceAll('"', '')
          .trim()
          .toLowerCase();

      if (acceptedHeaders.contains(value)) {
        return i;
      }
    }

    return null;
  }
}
