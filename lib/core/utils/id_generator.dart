import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  static String generator() {
    return _uuid.v4();
  }
}
