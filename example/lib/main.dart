import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wechat_login/flutter_wechat_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterWechatLogin = FlutterWechatLogin();

  bool _isInstalled = false;
  bool startLogin = false;
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    doInit();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> doInit() async {

    _flutterWechatLogin.init(appId: "", secret: "", universalLink: "");

    bool isInstalled = await _flutterWechatLogin.isInstalled();

    if (!mounted) return;

    setState(() {
      _isInstalled = isInstalled;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget userInfoWidget = Container();
    if (startLogin) userInfoWidget = CircularProgressIndicator();
    if (userInfo.isNotEmpty) {
      userInfoWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.network(userInfo['headimgurl'], width: 40,),
          ),
          SizedBox(width: 5,),
          Text(userInfo['nickname']),
        ],
      );
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wechat Login Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('isInstalled Wechat : $_isInstalled'),
              ElevatedButton(
                child: Text("Login"),
                onPressed: () {
                  doLogin();
                },
              ),
              SizedBox(height: 10,),
              userInfoWidget
            ],
          ),
        ),
      ),
    );
  }

  Future<void> doLogin() async {
    if (mounted) {
      setState(() {
        startLogin = true;
      });
    }

    Map<String, dynamic> wechatInfo = await _flutterWechatLogin.login();
    print('flutter_wechat_plugin -> wechatInfo = $wechatInfo');

    Map<String, dynamic> accessTokenInfo = await _flutterWechatLogin.getAccessToken(code: wechatInfo['code']);
    print('flutter_wechat_plugin -> accessTokenInfo = $accessTokenInfo');

    Map<String, dynamic> refreshTokenInfo = await _flutterWechatLogin.refreshToken(refreshToken: accessTokenInfo['refresh_token']);
    print('flutter_wechat_plugin -> refreshTokenInfo = $refreshTokenInfo');

    Map<String, dynamic> checkTokenInfo = await _flutterWechatLogin.checkToken(accessToken: accessTokenInfo['access_token'], openid: accessTokenInfo['openid']);
    print('flutter_wechat_plugin -> checkTokenInfo = $checkTokenInfo');

    Map<String, dynamic> userInfo = await _flutterWechatLogin.getUserInfo(accessToken: accessTokenInfo['access_token'], openid: accessTokenInfo['openid']);
    print('flutter_wechat_plugin -> userInfo = $userInfo');

    if (mounted) {
      setState(() {
        startLogin = false;
        this.userInfo = userInfo;
      });
    }
  }
}