# flutter_wechat_login

[中文请移步此处](./README_CN.md)

Flutter Wechat Login Plugin

|             | Android | iOS   |
|-------------|---------|-------|
| **Support** | SDK 19+ | 11.0+ |

<p>
  <img src="https://github.com/yechong/flutter_wechat_login/blob/main/doc/images/android.gif?raw=true"
    alt="An animated image of the iOS Wechat Login Plugin UI" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/yechong/flutter_wechat_login/blob/main/doc/images/iphone.gif?raw=true"
   alt="An animated image of the Android Wechat Login Plugin UI" height="400"/>
</p>

## Features

This plugin has integrated the function of WeChat login:
- WeChat app authorized login
- Exchange code for access_token, refresh_token and authorized scope `/sns/oauth2/access_token`
- Refresh or renew access_token `/sns/oauth2/refresh_token`
- Check access_token validity `/sns/auth`
- Get user info `/sns/userinfo`

## Getting Started

Before using this plugin, it is strongly recommended to read the official documentation in detail
- [Android access guide](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/Android.html)
- [iOS access guide](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html)
- [Mobile App WeChat Login Development Guide](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)

### Usage

```dart
import 'package:flutter_wechat_login/flutter_wechat_login.dart';

// Create FlutterWechatLogin
final flutterWechatLogin = FlutterWechatLogin();

// Initialization
await flutterQqLogin.init(appId: "Your AppID", secret: "Your AppSecret", universalLink: "Your Universal Links(iOS Required)");

// Determine whether the WeChat application is currently installed
bool isInstalled = await flutterWechatLogin.isInstalled();

// Call up WeChat login, and return code after successful login
Map<String, dynamic> wechatInfo = await flutterWechatLogin.login();

// Exchange code for access_token, refresh_token and authorized scope
Map<String, dynamic> accessTokenInfo = await flutterWechatLogin.getAccessToken(code: wechatInfo['code']);

// Refresh or renew access_token
Map<String, dynamic> refreshTokenInfo = await flutterWechatLogin.refreshToken(refreshToken: accessTokenInfo['refresh_token']);

// Check access_token validity
Map<String, dynamic> checkTokenInfo = await flutterWechatLogin.checkToken(accessToken: accessTokenInfo['access_token'], openid: accessTokenInfo['openid']);

// Get user information
Map<String, dynamic> userInfo = await flutterWechatLogin.getUserInfo(accessToken: accessTokenInfo['access_token'], openid: accessTokenInfo['openid']);

```


### Configure Android version
- 1. Create a package name `wxapi` under the project `android` directory `/app/src/main/java/packageName`, and then create a new `WXEntryActivity` under this package name, the code is as follows:
```java
package packageName.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelbiz.SubscribeMessage;
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram;
import com.tencent.mm.opensdk.modelbiz.WXOpenBusinessView;
import com.tencent.mm.opensdk.modelbiz.WXOpenBusinessWebview;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

    private IWXAPI api;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d("flutter_wechat_login", "onCreate");
        super.onCreate(savedInstanceState);
        api = WXAPIFactory.createWXAPI(this, "", false);
        try {
            Intent intent = getIntent();
            api.handleIntent(intent, this);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        api.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq req) {
    }

    @Override
    public void onResp(BaseResp resp) {
        Log.d("flutter_wechat_login", "onResp -> " + resp.errCode);

        Intent intent = new Intent("flutter_wechat_login");
        intent.putExtra("errCode", resp.errCode);
        intent.putExtra("errStr", resp.errStr);
        intent.putExtra("type", resp.getType());

        if (resp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
            SendAuth.Resp authResp = (SendAuth.Resp) resp;
            Log.i("flutter_wechat_login", "COMMAND_SENDAUTH");
            intent.putExtra("code", authResp.code);
            intent.putExtra("state", authResp.state);
            intent.putExtra("lang", authResp.lang);
            intent.putExtra("country", authResp.country);
        }

        sendBroadcast(intent);
        finish();
    }
}

```

- 2. Configure `android/app/src/main/AndroidManifest.xml`
>WeChat needs to verify the package name, so the path of the Activity must be `your package name.wxapi.WXEntryActivity`, where `your package name` must be the package name filled in by the WeChat open platform registration application.
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
	<!-- new content 开始 -->
	<uses-permission android:name="android.permission.INTERNET" />
	<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
	<!-- new content 结束 -->
	<application>
		...
		<!-- new content 开始 -->
		<activity
			android:name="你的包名.wxapi.WXEntryActivity"
			android:theme="@android:style/Theme.Translucent.NoTitleBar"
			android:exported="true"
			android:taskAffinity="你的包名"
			android:launchMode="singleTask">
		</activity>
		<!-- new content 结束 -->
		...
	</application>
	<!-- new content 开始 -->
	<queries>
		<package android:name="com.tencent.mm" />
	</queries>
	<!-- new content 结束 -->
</manifest>
```


### Configure iOS version

Configure `URL Types`
- Use `xcode` to open your iOS project `Runner.xcworkspace`
- In the `info` configuration tab under `URL Types`, add a new entry
    - `identifier` fills in `weixin`
    - `URL Schemes` fill in `Your APPID`
    - As shown below:
      ![xcode configuration example](https://raw.githubusercontent.com/yechong/flutter_wechat_login/main/doc/images/ios_screenshot_01.png)

Configure `LSApplicationQueriesSchemes`
- Method 1, configure `info` in `xcode`
    - Open `info` configuration, add a `LSApplicationQueriesSchemes`, namely `Queried URL Schemes`
    - Add these items:
        - weixin
        - weixinULAPI
        - weixinURLParamsAPI
    - As shown below：
      ![xcode configuration example](https://raw.githubusercontent.com/yechong/flutter_wechat_login/main/doc/images/ios_screenshot_02.png)

- Method 2, modify `Info.plist` directly
    - Use `Android Studio` to open `ios/Runner/Info.plist` under the project project
    - Add the following configuration under the `dict` node (refer to the configuration format in the file):
```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>weixin</string>
	<string>weixinULAPI</string>
	<string>weixinURLParamsAPI</string>
</array>
```


## Donate
Buy the writer a cup of coffee
<p>
  <img src="https://github.com/yechong/flutter_wechat_login/blob/main/doc/images/wechat_qrcode.jpg?raw=true"
    alt="WeChat payment QR code" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/yechong/flutter_wechat_login/blob/main/doc/images/alipay_qrcode.jpg?raw=true"
   alt="Alipay collection QR code" height="400"/>
</p>


## LICENSE

```Copyright 2018 OpenFlutter Project

BSD 3-Clause License

Copyright 2017 German Saprykin
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
