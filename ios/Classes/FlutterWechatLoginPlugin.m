#import "FlutterWechatLoginPlugin.h"
#import <UIKit/UIKit.h>
#import <WXApi.h>

@interface FlutterWechatLoginPlugin () <WXApiDelegate>
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *universalLink;
@property (nonatomic, strong) FlutterResult loginCallback; // 登录回调
@end

@implementation FlutterWechatLoginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_wechat_login"
            binaryMessenger:[registrar messenger]];
    FlutterWechatLoginPlugin* instance = [[FlutterWechatLoginPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if ([@"init" isEqualToString:call.method]) {
    NSDictionary *arguments = call.arguments;
    self.appId = arguments[@"appId"];
    self.secret = arguments[@"secret"];
    self.universalLink = arguments[@"universalLink"];
    NSLog(@"appId=%@ universalLink=%@", self.appId, self.universalLink);
    [WXApi registerApp:self.appId universalLink:self.universalLink];
    result(nil);
  }
  else if ([@"isInstalled" isEqualToString:call.method]) {
    bool isInstalled = [WXApi isWXAppInstalled];
    NSLog(@"isInstalled=%d", isInstalled);
    NSNumber *isInstalledNumber = [NSNumber numberWithBool:isInstalled];
    result(isInstalledNumber);
  }
  else if ([@"login" isEqualToString:call.method]) {
    // 保存登录回调
    self.loginCallback = result;
      
    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // 只能填 snsapi_userinfo
    req.state = @"flutter_wechat_login";
    // 第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req completion:^(BOOL success) {
        NSLog(@"request snsapi_userinfo -> %@", @(success));
    }];
  }
  else if ([@"getAccessToken" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *code = arguments[@"code"];
      NSString *api = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.appId, self.secret, code];
      [self sendGETRequestWithURL:api completionHandler:^(NSDictionary *responseDict, NSError *error) {
          NSString *jsonString = [self convertToJsonString:responseDict];
          if (jsonString && jsonString.length > 0) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  result(jsonString);
              });
          }
          else {
              result(@"{'ret': -1}");
          }
      }];
  }
  else if ([@"refreshToken" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *refreshToken = arguments[@"refreshToken"];
      NSString *api = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", self.appId, refreshToken];
      [self sendGETRequestWithURL:api completionHandler:^(NSDictionary *responseDict, NSError *error) {
          NSString *jsonString = [self convertToJsonString:responseDict];
          if (jsonString && jsonString.length > 0) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  result(jsonString);
              });
          }
          else {
              result(@"{'ret': -1}");
          }
      }];
  }
  else if ([@"checkToken" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *accessToken = arguments[@"accessToken"];
      NSString *openid = arguments[@"openid"];
      NSString *api = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/auth?access_token=%@&openid=%@", accessToken, openid];
      [self sendGETRequestWithURL:api completionHandler:^(NSDictionary *responseDict, NSError *error) {
          NSString *jsonString = [self convertToJsonString:responseDict];
          if (jsonString && jsonString.length > 0) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  result(jsonString);
              });
          }
          else {
              result(@"{'ret': -1}");
          }
      }];
  }
  else if ([@"getUserInfo" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *accessToken = arguments[@"accessToken"];
      NSString *openid = arguments[@"openid"];
      NSString *api = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openid];
      [self sendGETRequestWithURL:api completionHandler:^(NSDictionary *responseDict, NSError *error) {
          NSString *jsonString = [self convertToJsonString:responseDict];
          if (jsonString && jsonString.length > 0) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  result(jsonString);
              });
          }
          else {
              result(@"{'ret': -1}");
          }
      }];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //向微信注册
//    [WXApi registerApp:@"" universalLink:@""];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)onReq:(BaseReq *)req {
    if([req isKindOfClass:[GetMessageFromWXReq class]]) {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";

    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
        
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]]) {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
    }
}

- (void)onResp:(BaseResp *)resp {
    NSLog(@"onResp -> type=%d", resp.type);
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthReq *) resp;
        NSDictionary *dictionary = @{
            @"errCode": @(resp.errCode),
            @"errStr": resp.errStr == nil ? @"" : resp.errStr,
            @"code": authResp.code,
            @"lang": authResp.lang == nil ? @"" : authResp.lang,
            @"state": authResp.state == nil ? @"" : authResp.state,
            @"country": authResp.country == nil ? @"" : authResp.country
        };
        NSString *jsonString = [self convertToJsonString:dictionary];
        if (jsonString && jsonString.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.loginCallback) {
                    self.loginCallback(jsonString);
                    self.loginCallback = nil; // 清空回调
                }
            });
        }
    }
}
    
/**
    将给定的 NSDictionary 对象转换为 JSON 格式的字符串。
 
    @param dictionary 要转换的 NSDictionary 对象。
    @return 转换后的 JSON 格式的字符串，如果转换失败则返回 nil。
 */
- (NSString *)convertToJsonString:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"Error creating JSON data: %@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/**
     发送 GET 请求并将结果转换为字典。

     @param urlString 请求的 URL
     @param completionHandler 请求完成后的处理回调。如果成功，将传递解析后的字典对象；如果失败，将传递错误对象。
 */
- (void)sendGETRequestWithURL:(NSString *)urlString completionHandler:(void (^)(NSDictionary *responseDict, NSError *error))completionHandler {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completionHandler(nil, [NSError errorWithDomain:@"InvalidURL" code:1 userInfo:nil]);
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSError *jsonError;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError == nil && [responseDict isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(responseDict, nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, [NSError errorWithDomain:@"JSONError" code:1 userInfo:nil]);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
        }
    }];

    [dataTask resume];
}

@end
