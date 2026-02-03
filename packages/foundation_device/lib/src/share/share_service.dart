import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareText(String text, {String? subject}) =>
      Share.share(text, subject: subject);

  Future<void> shareFiles(List<String> paths,
          {String? text, String? subject}) =>
      Share.shareXFiles(paths.map((p) => XFile(p)).toList(),
          text: text, subject: subject);
}
