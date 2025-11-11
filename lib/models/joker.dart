enum JokerType {
  fiftyFifty, // 50:50
  audience, // Seyirci
  phone, // Telefon
  doubleAnswer, // Çift Cevap
}

class Joker {
  final JokerType type;
  final String name;
  final String description;
  bool isUsed;

  Joker({
    required this.type,
    required this.name,
    required this.description,
    this.isUsed = false,
  });

  // Tüm jokerleri oluştur
  static List<Joker> createAllJokers() {
    return [
      Joker(
        type: JokerType.fiftyFifty,
        name: '50:50',
        description: 'İki yanlış şıkkı kaldırır',
      ),
      Joker(
        type: JokerType.audience,
        name: 'Seyirci',
        description: 'Seyircilerin tercihini gösterir',
      ),
      Joker(
        type: JokerType.phone,
        name: 'Telefon',
        description: 'Bir ipucu verir',
      ),
      Joker(
        type: JokerType.doubleAnswer,
        name: 'Tek Cevap',
        description: 'Tek şık işaretlendi',
      ),
    ];
  }
}
