import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = 'us-cdbr-east-02.cleardb.com',
      user = 'be16f9f6d1832e',
      password = '6ec54e2a',
      db = 'heroku_19a4bd20cf30ab1';
  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: db
    );
    return await MySqlConnection.connect(settings);
  }
}