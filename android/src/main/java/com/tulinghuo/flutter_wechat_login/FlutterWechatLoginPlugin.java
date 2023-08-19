package com.tulinghuo.flutter_wechat_login;

import static android.content.ContentValues.TAG;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterWechatLoginPlugin
 */
public class FlutterWechatLoginPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler,
        ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Activity activity;
    private Context context;

    private String appId;
    private String secret;
    private IWXAPI api; // IWXAPI 是第三方app和微信通信的openApi接口
    private Result loginResult;
    private Result accessTokenResult;
    private Result checkTokenResult;
    private Result refreshTokenResult;
    private Result userInfoResult;

    private MyHandler handler;

    private static class MyHandler extends Handler {

        private final WeakReference<FlutterWechatLoginPlugin> flutterWechatLoginPluginWeakReference;

        public MyHandler(FlutterWechatLoginPlugin flutterWechatLoginPlugin){
            this.flutterWechatLoginPluginWeakReference = new WeakReference<>(flutterWechatLoginPlugin);
        }

        @Override
        public void handleMessage(Message msg) {
            int tag = msg.what;
            switch (tag) {
                case NetworkUtil.GET_TOKEN: {
                    Result result = flutterWechatLoginPluginWeakReference.get().accessTokenResult;
                    if (result == null) return;
                    Bundle data = msg.getData();
                    JSONObject json;
                    try {
                        json = new JSONObject(data.getString("result"));
                        result.success(json.toString());
                    }
                    catch (JSONException e) {
                        json = new JSONObject();
                        try {
                            json.put("ret", -1);
                        }
                        catch (JSONException ex) {
                            ex.printStackTrace();
                        }
                        Log.e(TAG, e.getMessage());
                        result.success(json.toString());
                    }
                    finally {
                        flutterWechatLoginPluginWeakReference.get().accessTokenResult = null;
                    }
                    break;
                }
                case NetworkUtil.REFRESH_TOKEN: {
                    Result result = flutterWechatLoginPluginWeakReference.get().refreshTokenResult;
                    if (result == null) return;
                    Bundle data = msg.getData();
                    JSONObject json;
                    try {
                        json = new JSONObject(data.getString("result"));
                        result.success(json.toString());
                    }
                    catch (JSONException e) {
                        json = new JSONObject();
                        try {
                            json.put("ret", -1);
                        }
                        catch (JSONException ex) {
                            ex.printStackTrace();
                        }
                        Log.e(TAG, e.getMessage());
                        result.success(json.toString());
                    }
                    finally {
                        flutterWechatLoginPluginWeakReference.get().refreshTokenResult = null;
                    }
                    break;
                }
                case NetworkUtil.CHECK_TOKEN: {
                    Result result = flutterWechatLoginPluginWeakReference.get().checkTokenResult;
                    if (result == null) return;
                    Bundle data = msg.getData();
                    JSONObject json;
                    try {
                        json = new JSONObject(data.getString("result"));
                        result.success(json.toString());
                    }
                    catch (JSONException e) {
                        json = new JSONObject();
                        try {
                            json.put("ret", -1);
                        }
                        catch (JSONException ex) {
                            ex.printStackTrace();
                        }
                        Log.e(TAG, e.getMessage());
                        result.success(json.toString());
                    }
                    finally {
                        flutterWechatLoginPluginWeakReference.get().checkTokenResult = null;
                    }
                    break;
                }
                case NetworkUtil.GET_INFO: {
                    Result result = flutterWechatLoginPluginWeakReference.get().userInfoResult;
                    if (result == null) return;
                    Bundle data = msg.getData();
                    JSONObject json;
                    try {
                        json = new JSONObject(data.getString("result"));
                        result.success(json.toString());
                    }
                    catch (JSONException e) {
                        json = new JSONObject();
                        try {
                            json.put("ret", -1);
                        }
                        catch (JSONException ex) {
                            ex.printStackTrace();
                        }
                        Log.e(TAG, e.getMessage());
                        result.success(json.toString());
                    }
                    finally {
                        flutterWechatLoginPluginWeakReference.get().userInfoResult = null;
                    }
                    break;
                }
            }
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_wechat_login");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        // 注册广播接收器
        IntentFilter intentFilter = new IntentFilter("flutter_wechat_login"); // 替换为你的广播Action
        flutterPluginBinding.getApplicationContext().registerReceiver(this, intentFilter);
        handler = new MyHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            this.appId = call.argument("appId");
            this.secret = call.argument("secret");
            Log.i("flutter_wechat_login", "call init -> appId= " + appId);
            regToWx();
            result.success(null);
        }
        else if (call.method.equals("isInstalled")) {
            boolean isInstalled = api.isWXAppInstalled();
            result.success(isInstalled);
        }
        else if (call.method.equals("login")) {
            SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo"; // 只能填 snsapi_userinfo
            req.state = "flutter_wechat_login";
            api.sendReq(req);
            this.loginResult = result;
        }
        else if (call.method.equals("getAccessToken")) {
            String code = call.argument("code");
            NetworkUtil.sendWxAPI(handler,
                    String.format("https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", this.appId, this.secret, code),
                    NetworkUtil.GET_TOKEN);
            this.accessTokenResult = result;
        }
        else if (call.method.equals("checkToken")) {
            String accessToken = call.argument("accessToken");
            String openid = call.argument("openid");
            NetworkUtil.sendWxAPI(handler,
                    String.format("https://api.weixin.qq.com/sns/auth?access_token=%s&openid=%s", accessToken, openid),
                    NetworkUtil.CHECK_TOKEN);
            this.checkTokenResult = result;
        }
        else if (call.method.equals("refreshToken")) {
            String refreshToken = call.argument("refreshToken");
            NetworkUtil.sendWxAPI(handler,
                    String.format("https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s", this.appId, refreshToken),
                    NetworkUtil.REFRESH_TOKEN);
            this.refreshTokenResult = result;
        }
        else if (call.method.equals("getUserInfo")) {
            String accessToken = call.argument("accessToken");
            String openid = call.argument("openid");
            NetworkUtil.sendWxAPI(handler,
                    String.format("https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s", accessToken, openid),
                    NetworkUtil.GET_INFO);
            this.userInfoResult = result;
        }
        else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        loginResult = null;
        accessTokenResult = null;
        checkTokenResult = null;
        refreshTokenResult = null;
        userInfoResult = null;
    }

    private void regToWx() {
        // 通过WXAPIFactory工厂，获取IWXAPI的实例
        Log.i("flutter_wechat_login", "通过WXAPIFactory工厂，获取IWXAPI的实例");
//        api = WXAPIFactory.createWXAPI(this.context, this.appId, true);
        api = WXAPIFactory.createWXAPI(this.context, null);
        // 将应用的appId注册到微信
        Log.i("flutter_wechat_login", "将应用的appId注册到微信");
        api.registerApp(this.appId);
        //建议动态监听微信启动广播进行注册到微信
        new ContextWrapper(context).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                // 将该app注册到微信
                Log.i("flutter_wechat_login", "监听微信启动广播进行注册到微信");
                api.registerApp(appId);
            }
        }, new IntentFilter(ConstantsAPI.ACTION_REFRESH_WXAPP));

//        api.handleIntent(activity.getIntent(), this);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onReceive(Context context, Intent intent) {
        int errCode = intent.getIntExtra("errCode", -999);
        String errStr = intent.getStringExtra("errStr");
        int type = intent.getIntExtra("type", -1);

        JSONObject jsonObject = new JSONObject();
        try {
            if (this.loginResult != null) {
                if (errCode == 0) {
                    if (type == ConstantsAPI.COMMAND_SENDAUTH) {
                        jsonObject.put("errCode", errCode);
                        jsonObject.put("errStr", errStr);
                        jsonObject.put("code", intent.getStringExtra("code"));
                        jsonObject.put("state", intent.getStringExtra("state"));
                        jsonObject.put("lang", intent.getStringExtra("lang"));
                        jsonObject.put("country", intent.getStringExtra("country"));
                        Log.i("flutter_wechat_login", "auth -> " + jsonObject.toString());
                        this.loginResult.success(jsonObject.toString());
                        this.loginResult = null;
                    }
                }
                else {
                    this.loginResult.success(jsonObject.toString());
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            if (this.loginResult != null) {
                this.loginResult.success(jsonObject.toString());
            }
        }
        finally {
            this.loginResult = null;
        }
    }
}
