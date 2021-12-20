class User {
  final String imageUrl;
  final String nickname;

  User({
    required this.imageUrl,
    required this.nickname,
  });

  User.fromMap(Map<String, dynamic> map)
      : imageUrl = map['image_url'],
        nickname = map['login'];
}
