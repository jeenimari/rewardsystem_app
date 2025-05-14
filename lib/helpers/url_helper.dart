// helpers/url_helper.dart 파일 생성
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UrlHelper {
  static Future<void> openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // URL을 열 수 없는 경우
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL을 열 수 없습니다')),
          );
        }
      }
    } catch (e) {
      // URL 형식이 잘못된 경우 등 예외 처리
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}