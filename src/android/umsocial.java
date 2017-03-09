//package com.bjzjns.cordovaplugin;
//
//import org.apache.cordova.CallbackContext;
//import org.apache.cordova.CordovaPlugin;
//import org.json.JSONArray;
//import org.json.JSONException;
//
///**
// * This class echoes a string called from JavaScript.
// */
//public class umsocial extends CordovaPlugin {
//
//    @Override
//    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
//        if (action.equals("coolMethod")) {
//            String message = args.getString(0);
//            this.coolMethod(message, callbackContext);
//            return true;
//        }
//        return false;
//    }
//
//    private void coolMethod(String message, CallbackContext callbackContext) {
//        if (message != null && message.length() > 0) {
//            callbackContext.success(message);
//        } else {
//            callbackContext.error("Expected one non-empty string argument.");
//        }
//    }
//}


package com.bjzjns.cordovaplugin;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.umeng.socialize.Config;
import com.umeng.socialize.PlatformConfig;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMAuthListener;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;


public class umsocial extends CordovaPlugin {

    public static final String TAG = umsocial.class.getSimpleName();
    private Activity mActivity;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        this.mActivity = cordova.getActivity();
        Config.DEBUG = true;          //Debug模式
        Config.isJumptoAppStore = true; // 其中qq 微信会跳转到下载界面进行下载，其他应用会跳到应用商店进行下载

        String wechatId = preferences.getString("WECHAT_ID", "");
        String wechatSecret = preferences.getString("WECHAT_SECRET", "");
        String weiboKey = preferences.getString("WEIBO_KEY", "");
        String weiboSecret = preferences.getString("WEIBO_SECRET", "");
        String weiboRedirectUrl = preferences.getString("WEIBO_REDIRECT_URL", "");
        String qqId = preferences.getString("QQ_ID", "");
        String qqKey = preferences.getString("QQ_KEY", "");

        PlatformConfig.setWeixin(wechatId, wechatSecret);
        PlatformConfig.setSinaWeibo(weiboKey, weiboSecret, weiboRedirectUrl);
        PlatformConfig.setQQZone(qqId, qqKey);

        UMShareAPI.get(mActivity);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.e(TAG, args.toString());
        if (action.equals("shareWebPage")) {
            this.shareWebPage(args, callbackContext);
            return true;
        } else if ("loginWithPlatform".equals(action)) {
            this.loginWithPlatform(args, callbackContext);
            return true;
        } else if ("isInstalledPlatform".equals(action)) {
            this.isInstalledPlatform(args, callbackContext);
            return true;
        }
        return false;
    }


    /**
     * 三方登录
     *
     * @param message         数据
     * @param callbackContext 回调
     */
    private void loginWithPlatform(JSONArray message, final CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            try {
                JSONObject jsonObject = message.getJSONObject(0);
                String platform = jsonObject.getString("platform");
                if (TextUtils.isEmpty(platform)) {
                    callbackContext.error("没有参数");
                    return;
                }
                final SHARE_MEDIA share_media = getPaltform(platform);
                if (null == share_media) {
                    callbackContext.error("平台名字错误");
                    return;
                }
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        cordova.setActivityResultCallback(umsocial.this);
                        UMShareAPI.get(mActivity).getPlatformInfo(mActivity, share_media, new UMAuthListener() {
                            @Override
                            public void onStart(SHARE_MEDIA platform) {
                                Log.e(TAG, "platform" + platform + "登录开始!");
                            }

                            @Override
                            public void onComplete(SHARE_MEDIA platform, int action, Map<String, String> data) {
                                JSONObject infoJSON = new JSONObject();
                                for (String key : data.keySet()) {
                                    try {
                                        infoJSON.put(key, data.get(key));
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                        callbackContext.error(e.toString());
                                    }
                                }
                                callbackContext.success(infoJSON);
                                Log.e(TAG, "platform" + platform + "成功");
                            }

                            @Override
                            public void onError(SHARE_MEDIA platform, int action, Throwable t) {
                                Log.e(TAG, "platform" + platform + "登录错误" + t.getMessage());
                                JSONObject errorJSONObject = new JSONObject();
                                try {
                                    errorJSONObject.put("status", "失败");
                                    errorJSONObject.put("msg", t.getMessage());
                                    callbackContext.error(errorJSONObject);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    callbackContext.error(e.getMessage());
                                }
                            }

                            @Override
                            public void onCancel(SHARE_MEDIA platform, int action) {
                                Log.e(TAG, "取消");
                                JSONObject errorJSONObject = new JSONObject();
                                try {
                                    errorJSONObject.put("status", "失败");
                                    errorJSONObject.put("msg", "用户取消");
                                    callbackContext.error(errorJSONObject);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    callbackContext.error(e.getMessage());
                                }
                            }
                        });
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                callbackContext.error(e.toString());
            }
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }


    /**
     * 网页分享
     *
     * @param message         数据
     * @param callbackContext 回调
     */
    private void shareWebPage(JSONArray message, final CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            try {
                JSONObject jsonObject = message.getJSONObject(0);
                String platform = jsonObject.getString("platform");
                String thumbURL = jsonObject.getString("thumbURL");
                String title = jsonObject.getString("title");
                String description = jsonObject.getString("description");
                String webPageURL = jsonObject.getString("webPageURL");

                if (TextUtils.isEmpty(platform) || TextUtils.isEmpty(thumbURL) ||
                        TextUtils.isEmpty(title) || TextUtils.isEmpty(description) ||
                        TextUtils.isEmpty(webPageURL)) {
                    callbackContext.error("没有参数");
                    return;
                }
                final SHARE_MEDIA share_media = getPaltform(platform);
                if (null == share_media) {
                    callbackContext.error("平台名字错误");
                    return;
                }
                UMImage thumb = new UMImage(mActivity, thumbURL);
                final UMWeb web = new UMWeb(webPageURL);
                web.setTitle(title);//标题
                web.setThumb(thumb);  //缩略图
                web.setDescription(description);//描述

                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        cordova.setActivityResultCallback(umsocial.this);
                        new ShareAction(mActivity).setPlatform(share_media)
                                .withMedia(web)
                                .setCallback(new UMShareListener() {
                                    @Override
                                    public void onStart(SHARE_MEDIA platform) {
                                        Log.e(TAG, "platform" + platform + "onStart！");
                                    }

                                    @Override
                                    public void onResult(SHARE_MEDIA platform) {
                                        Log.e(TAG, "platform" + platform + "onResult！");
                                        callbackContext.success("成功");
                                    }

                                    @Override
                                    public void onError(SHARE_MEDIA platform, Throwable t) {
                                        Log.e(TAG, "platform" + platform + "onError！");
                                        if (t != null) {
                                            Log.d("throw", "throw:" + t.getMessage());
                                        }
                                        JSONObject errorJSONObject = new JSONObject();
                                        try {
                                            errorJSONObject.put("status", "失败");
                                            errorJSONObject.put("msg", t.getMessage());
                                            callbackContext.error(errorJSONObject);
                                        } catch (JSONException e) {
                                            e.printStackTrace();
                                            callbackContext.error(e.getMessage());
                                        }

                                    }

                                    @Override
                                    public void onCancel(SHARE_MEDIA platform) {
                                        Log.e(TAG, "platform" + platform + "onCancel！");
                                        JSONObject errorJSONObject = new JSONObject();
                                        try {
                                            errorJSONObject.put("status", "失败");
                                            errorJSONObject.put("msg", "用户取消");
                                            callbackContext.error(errorJSONObject);
                                        } catch (JSONException e) {
                                            e.printStackTrace();
                                            callbackContext.error(e.getMessage());
                                        }

                                    }
                                })
                                .share();
                    }
                });
            } catch (JSONException e) {
                e.printStackTrace();
                callbackContext.error(e.toString());
            }
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }


    /**
     * 检查指定平台的应用是否安装 (已安装：1 未安装：0 )
     *
     * @param message
     * @param callbackContext
     */
    private void isInstalledPlatform(JSONArray message, final CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            try {
                JSONObject jsonObject = message.getJSONObject(0);
                String platform = jsonObject.getString("platform");
                if (TextUtils.isEmpty(platform)) {
                    callbackContext.error("没有参数");
                    return;
                }
                final SHARE_MEDIA share_media = getPaltform(platform);
                if (null == share_media) {
                    callbackContext.error("平台名字错误");
                    return;
                }
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        cordova.setActivityResultCallback(umsocial.this);
                        callbackContext.success(UMShareAPI.get(mActivity).isInstall(mActivity, share_media) ? "1" : "0");
                    }
                });

            } catch (JSONException e) {
                e.printStackTrace();
                callbackContext.error(e.toString());
            }
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }


    /**
     * 根据平台名称获取对应的平台值
     *
     * @param platform 平台名称
     * @return 平台值
     */
    private SHARE_MEDIA getPaltform(String platform) {
        SHARE_MEDIA share_media = null;
        if ("qq".equalsIgnoreCase(platform)) {
            share_media = SHARE_MEDIA.QQ;
        } else if ("qZone".equalsIgnoreCase(platform)) {
            share_media = SHARE_MEDIA.QZONE;
        } else if ("sina".equalsIgnoreCase(platform)) {
            share_media = SHARE_MEDIA.SINA;
        } else if ("wechatSession".equalsIgnoreCase(platform)) {
            share_media = SHARE_MEDIA.WEIXIN;
        } else if ("wechatTimeLine".equalsIgnoreCase(platform)) {
            share_media = SHARE_MEDIA.WEIXIN_CIRCLE;
        }
        return share_media;
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.e(TAG, "onActivityResult" + "requestCode=" + requestCode + "resultCode=" + resultCode);
        UMShareAPI.get(mActivity).onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        UMShareAPI.get(mActivity).release();
    }

}
