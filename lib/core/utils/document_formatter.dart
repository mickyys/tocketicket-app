/// Utilidades para formatear documentos de identidad
class DocumentFormatter {
  /// Formatea un número de documento según su tipo
  ///
  /// Si el tipo es 'rut', aplica formato chileno con puntos y guión
  /// Si es 'pasaporte' u otro tipo, devuelve el documento sin modificar
  static String formatDocument(String document, String documentType) {
    if (documentType.toLowerCase() == 'rut') {
      return formatRut(document);
    }
    return document; // Para pasaportes y otros documentos
  }

  /// Formatea un RUT chileno con puntos y guión
  ///
  /// Ejemplo: "123456789" -> "12.345.678-9"
  static String formatRut(String rut) {
    // Limpiar el RUT de puntos, guiones y espacios existentes
    String cleanRut = rut
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim();

    // Validar longitud mínima
    if (cleanRut.length < 2) {
      return rut; // Devolver original si es muy corto
    }

    // Separar número y dígito verificador
    String number = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1).toUpperCase();

    // Formatear número con puntos cada 3 dígitos desde la derecha
    String formattedNumber = '';
    for (int i = number.length - 1, j = 0; i >= 0; i--, j++) {
      if (j > 0 && j % 3 == 0) {
        formattedNumber = '.$formattedNumber';
      }
      formattedNumber = number[i] + formattedNumber;
    }

    return '$formattedNumber-$dv';
  }

  /// Obtiene el tipo de documento formateado para mostrar
  static String getDocumentTypeDisplay(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'rut':
        return 'RUT';
      case 'pasaporte':
        return 'Pasaporte';
      default:
        return documentType.toUpperCase();
    }
  }

  /// Limpia un documento de todos los caracteres de formato
  static String cleanDocument(String document) {
    return document
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim();
  }
}
