
import 'dart:convert';

import 'flutter_wechat_login_platform_interface.dart';

class FlutterWechatLogin {
  Future<void> init({required String appId, required String secret, String? universalLink}) {
    return FlutterWechatLoginPlatform.instance.init(appId: appId, secret: secret, universalLink: universalLink);
  }

  Future<bool> isInstalled() {
    return FlutterWechatLoginPlatform.instance.isInstalled();
  }

  Future<Map<String, dynamic>> login() async {
    String data = await FlutterWechatLoginPlatform.instance.login() ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

  Future<Map<String, dynamic>> getAccessToken({required String code}) async {
    String data = await FlutterWechatLoginPlatform.instance.getAccessToken(code: code) ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) async {
    String data = await FlutterWechatLoginPlatform.instance.refreshToken(refreshToken: refreshToken) ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

  Future<Map<String, dynamic>> checkToken({required String accessToken, required String openid}) async {
    String data = await FlutterWechatLoginPlatform.instance.checkToken(accessToken: accessToken, openid: openid) ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

  Future<Map<String, dynamic>> getUserInfo({required String accessToken, required String openid}) async {
    String data = await FlutterWechatLoginPlatform.instance.getUserInfo(accessToken: accessToken, openid: openid) ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

}
