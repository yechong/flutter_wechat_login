package com.tulinghuo.aibrain.wxapi;

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
        switch (req.getType()) {
            case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:
                Log.d("flutter_wechat_login", "onReq -> COMMAND_GETMESSAGE_FROM_WX");
                break;
            case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:
                Log.d("flutter_wechat_login", "onReq -> COMMAND_SHOWMESSAGE_FROM_WX");
                break;
            default:
                break;
        }
        finish();
    }

    @Override
    public void onResp(BaseResp resp) {
        Log.d("flutter_wechat_login", "onResp -> " + resp.errCode);

        Intent intent = new Intent("flutter_wechat_login");
        intent.putExtra("errCode", resp.errCode);
        intent.putExtra("errStr", resp.errStr);
        intent.putExtra("type", resp.getType());

        if (resp.getType() == ConstantsAPI.COMMAND_SUBSCRIBE_MESSAGE) {
            SubscribeMessage.Resp subscribeMsgResp = (SubscribeMessage.Resp) resp;
            Log.i("flutter_wechat_login", "COMMAND_SUBSCRIBE_MESSAGE");
            intent.putExtra("openId", subscribeMsgResp.openId);
            intent.putExtra("templateID", subscribeMsgResp.templateID);
            intent.putExtra("scene", subscribeMsgResp.scene);
            intent.putExtra("action", subscribeMsgResp.action);
            intent.putExtra("reserved", subscribeMsgResp.reserved);
        }

        if (resp.getType() == ConstantsAPI.COMMAND_LAUNCH_WX_MINIPROGRAM) {
            WXLaunchMiniProgram.Resp launchMiniProgramResp = (WXLaunchMiniProgram.Resp) resp;
            Log.i("flutter_wechat_login", "COMMAND_LAUNCH_WX_MINIPROGRAM");
            intent.putExtra("openId", launchMiniProgramResp.openId);
            intent.putExtra("extMsg", launchMiniProgramResp.extMsg);
        }

        if (resp.getType() == ConstantsAPI.COMMAND_OPEN_BUSINESS_VIEW) {
            WXOpenBusinessView.Resp launchMiniProgramResp = (WXOpenBusinessView.Resp) resp;
            Log.i("flutter_wechat_login", "COMMAND_OPEN_BUSINESS_VIEW");
            intent.putExtra("openId", launchMiniProgramResp.openId);
            intent.putExtra("extMsg", launchMiniProgramResp.extMsg);
            intent.putExtra("businessType", launchMiniProgramResp.businessType);
        }

        if (resp.getType() == ConstantsAPI.COMMAND_OPEN_BUSINESS_WEBVIEW) {
            WXOpenBusinessWebview.Resp response = (WXOpenBusinessWebview.Resp) resp;
            Log.i("flutter_wechat_login", "COMMAND_OPEN_BUSINESS_WEBVIEW");
            intent.putExtra("businessType", response.businessType);
            intent.putExtra("resultInfo", response.resultInfo);
        }

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
