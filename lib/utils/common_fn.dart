import 'package:intl/intl.dart';

class CommonFn {
  static String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
