class Band {
  String id;
  String name;
  int? votes;

  Band({
    required this.id,
    required this.name,
    this.votes,
  });

  // el backend va a responder un mapa (pq es mas comodo)
  // creamos un Factory constructor (es un constructor que recibe argumentos
  // y devuelve una instancia de la clase)
  factory Band.fromMap(Map<String, dynamic> obj) {
    return Band(
      id: obj['id'],
      name: obj['name'],
      votes: obj['votes'],
    );
  }
}
