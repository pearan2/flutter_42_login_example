class Token {
  final String accessToken;

  Token({
    required this.accessToken,
  });

  Token.fromMap(Map<String, dynamic> map) : accessToken = map['access_token'];
}
