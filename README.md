# flutter_wechat_login

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



## 配置Activity
微信需要验证包名，因此Activity的路径必须是 `应用的包名.wxapi.WXEntryActivity` ，其中 `应用的包名` 必须是微信开放平台注册应用填写的包名