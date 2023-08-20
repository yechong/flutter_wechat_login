import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_wechat_login_method_channel.dart';

abstract class FlutterWechatLoginPlatform extends PlatformInterface {
  /// Constructs a FlutterWechatLoginPlatform.
  FlutterWechatLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWechatLoginPlatform _instance = MethodChannelFlutterWechatLogin();

  /// The default instance of [FlutterWechatLoginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWechatLogin].
  static FlutterWechatLoginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWechatLoginPlatform] when
  /// they register themselves.
  static set instance(FlutterWechatLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// init wechat plugin
  Future<void> init({required String appId, required String secret, String? universalLink}) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// check wechat app is installed
  Future<bool> isInstalled() {
    throw UnimplementedError('isInstalled() has not been implemented.');
  }

  /// WeChat app authorized login
  Future<String?> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  /// Exchange code for access_token, refresh_token and authorized scope
  Future<String?> getAccessToken({required String code}) {
    throw UnimplementedError('getAccessToken() has not been implemented.');
  }

  /// Refresh or renew access_token
  Future<String?> refreshToken({required String refreshToken}) {
    throw UnimplementedError('refreshToken() has not been implemented.');
  }

  /// Check access_token validity
  Future<String?> checkToken({required String accessToken, required String openid}) {
    throw UnimplementedError('checkToken() has not been implemented.');
  }

  /// Get WeChat user info
  Future<String?> getUserInfo({required String accessToken, required String openid}) {
    throw UnimplementedError('getUserInfo() has not been implemented.');
  }
}
