class User {
  final int id;
  final String name;
  final String? imageUrl; // На будущее под картинку

  const User({required this.id, required this.name, this.imageUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl};
  }
}
