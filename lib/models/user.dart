class User {
  String email;
  String password;
  String weight;
  String height;
  String bodyType;
  String age;

  User({
    required this.email,
    required this.password,
    required this.weight,
    required this.height,
    required this.bodyType,
    required this.age,
  });

  // Convertir la clase User a un mapa para poder guardarla como JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'userData': {
        'weight': weight,
        'height': height,
        'bodyType': bodyType,
        'age': age,
      }
    };
  }

  // Crear un objeto User desde un mapa (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      weight: json['userData']['weight'],
      height: json['userData']['height'],
      bodyType: json['userData']['bodyType'],
      age: json['userData']['age'],
    );
  }
}
