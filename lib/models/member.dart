// One person on the team.
class Member {
  String id;
  String name;
  String email;
  String role;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // The first letter of the first two names, for example "PK".
  String initials() {
    List<String> words = name.trim().split(' ');
    String result = '';
    for (String word in words) {
      if (word.isNotEmpty && result.length < 2) {
        result = result + word[0].toUpperCase();
      }
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }

  static Member fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
}
