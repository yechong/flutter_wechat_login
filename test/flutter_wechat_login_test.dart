import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wechat_login/flutter_wechat_login_method_channel.dart';
import 'package:flutter_wechat_login/flutter_wechat_login_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWechatLoginPlatform with MockPlatformInterfaceMixin implements FlutterWechatLoginPlatform {

  @override
  Future<void> init({required String appId, String? secret, String? universalLink}) => Future.value();

  @override
  Future<bool> isInstalled() => Future.value(true);

  @override
  Future<String?> login() => Future.value("{'ret': -1}");

  @override
  Future<String?> getAccessToken({required String code}) => Future.value("{'ret': -1}");

  @override
  Future<String?> refreshToken({required String refreshToken}) => Future.value("{'ret': -1}");

  @override
  Future<String?> checkToken({required String accessToken, required String openid}) => Future.value("{'ret': -1}");

  @override
  Future<String?> getUserInfo({required String accessToken, required String openid}) => Future.value("{'ret': -1}");

}

void main() {
  final FlutterWechatLoginPlatform initialPlatform =
      FlutterWechatLoginPlatform.instance;

  test('$MethodChannelFlutterWechatLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWechatLogin>());
  });
}
