import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/custom_widget/Fail.dart';
import 'package:myapp/model/token.dart';
import 'package:myapp/model/user.dart';

class Profile extends StatefulWidget {
  final String code;

  Profile({required this.code});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String _access_token;
  bool _isLoading = true;
  late User _user;

  @override
  void initState() {
    _getToken();
    super.initState();
  }

  void _goToFail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginFail()),
    );
  }

  void _getToken() async {
    setState(() => {_isLoading = true});
    final url = Uri.parse('https://api.intra.42.fr/oauth/token');
    final response = await http.post(url, body: {
      'grant_type': 'authorization_code',
      'client_id': dotenv.env['client_id'],
      'client_secret': dotenv.env['client_secret'],
      'code': widget.code,
      'redirect_uri': dotenv.env['redirect_uri'],
    });
    if (response.statusCode != 200) {
      print(response.body);
      _goToFail();
    } else {
      final token = Token.fromMap(jsonDecode(response.body));
      setState(() => {_access_token = token.accessToken});
      _getUser(token.accessToken);
    }
  }

  void _getUser(String token) async {
    final url = Uri.parse('https://api.intra.42.fr/v2/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode != 200) {
      _goToFail();
    } else {
      final user = User.fromMap(jsonDecode(response.body));
      setState(() {
        _isLoading = false;
        _user = user;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
          color: const Color(0x88808080),
          child: const Center(child: CircularProgressIndicator()));
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Container(
              width: 300,
              height: 300,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_user.imageUrl),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Hello! ${_user.nickname}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _buildBody(),
    );
  }
}
