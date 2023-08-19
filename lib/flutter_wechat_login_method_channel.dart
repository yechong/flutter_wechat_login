import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_wechat_login_platform_interface.dart';

/// An implementation of [FlutterWechatLoginPlatform] that uses method channels.
class MethodChannelFlutterWechatLogin extends FlutterWechatLoginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_wechat_login');

  @override
  Future<void> init({required String appId, required String secret, String? universalLink}) async {
    await methodChannel.invokeMethod<String>('init', {'appId': appId, 'secret': secret, 'universalLink': universalLink});
  }

  @override
  Future<bool> isInstalled() async {
    return await methodChannel.invokeMethod<bool>('isInstalled') ?? false;
  }

  @override
  Future<String?> login() async {
    return await methodChannel.invokeMethod<String>('login');
  }

  @override
  Future<String?> getAccessToken({required String code}) async {
    return await methodChannel.invokeMethod<String>('getAccessToken', {'code': code});
  }

  @override
  Future<String?> refreshToken({required String refreshToken}) async {
    return await methodChannel.invokeMethod<String>('refreshToken', {'refreshToken': refreshToken});
  }

  @override
  Future<String?> checkToken({required String accessToken, required String openid}) async {
    return await methodChannel.invokeMethod<String>('checkToken', {'accessToken': accessToken, 'openid': openid});
  }

  @override
  Future<String?> getUserInfo({required String accessToken, required String openid}) async {
    return await methodChannel.invokeMethod<String>('getUserInfo', {'accessToken': accessToken, 'openid': openid});
  }

}
