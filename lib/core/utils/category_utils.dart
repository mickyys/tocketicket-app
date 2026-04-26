class CategoryUtils {
  /// Calcula la edad de un participante basándose en su fecha de nacimiento y la fecha del evento
  static int? calculateAge(DateTime? birthDate, DateTime? eventStartDate) {
    if (birthDate == null) return null;
    final eventDay = eventStartDate ?? DateTime.now();
    int age = eventDay.year - birthDate.year;
    final m = eventDay.month - birthDate.month;
    if (m < 0 || (m == 0 && eventDay.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Filtra las categorías disponibles para un participante basándose en su edad, género y el ticket seleccionado
  static List<dynamic> getFilteredCategories({
    required String? ticketId,
    required String? gender,
    required DateTime? birthDate,
    required List<dynamic> allCategories,
    required DateTime? eventStartDate,
  }) {
    if (ticketId == null || gender == null || birthDate == null) return [];

    final participantGender = gender.toLowerCase();
    final participantBirthYear = birthDate.year;
    final age = calculateAge(birthDate, eventStartDate);

    return allCategories.where((cat) {
      // 1. Validar Ticket
      final List<dynamic> ticketIds = cat['ticketIds'] ?? [];
      if (!ticketIds.contains(ticketId)) return false;

      // 2. Validar Género
      final genderValid = (() {
        final categoryGenders = cat['genders'];
        if (categoryGenders is List) {
          return categoryGenders.contains(participantGender) ||
              categoryGenders.contains('any');
        }
        if (categoryGenders is String) {
          final lowerCatGender = categoryGenders.toLowerCase();
          return lowerCatGender == participantGender ||
              lowerCatGender == 'any';
        }
        return false;
      })();

      if (!genderValid) return false;

      // 3. Validar Rango (Edad o Año)
      final categorizationType = cat['categorizationType'] ?? 'age';
      final from = cat['from'] ?? 0;
      final to = cat['to'] ?? 999;

      if (categorizationType == 'year') {
        return participantBirthYear >= from && participantBirthYear <= to;
      } else {
        return age != null && age >= from && age <= to;
      }
    }).toList();
  }
}
