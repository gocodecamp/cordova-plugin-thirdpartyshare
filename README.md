Cordova Plugin ThirdPartyShare
====================
## CordovaPlugin 用于第三方平台的授权和分享 <br/>

**Android 注意事项**
  
**1.使用前请根据项目包路径配置plugin.xml文件*  （如项目包名为com.bjzjns.styleme请忽略本条所有配置）***
 - 如下标签中 target-dir属性值 com/bjzjns/styleme根据自己项目的包名进行替换）
 
		 <source-file src="src/android/src/wxapi/WXEntryActivity.java"
		   target-dir="src/com/bjzjns/styleme/wxapi" />
		<source-file src="src/android/src/WBShareActivity.java"
		   target-dir="src/com/bjzjns/styleme" />	
 
 - 对应的WXEntryActivity.java 和 WBShareActivity.java 自己手动修改文件包名

**2.添加CordovaPlugin的时候请配置对应平台的变量*（请确保正确）***
> --variable  ANDROID_TENCENT_SCHEME=
> --variable  ANDROID_WECHAT_ID= 
> --variable  ANDROID_WECHAT_SECRET= 
> --variable  ANDROID_WEIBO_KEY= 
> --variable  ANDROID_WEIBO_SECRET= 
> --variable  ANDROID_WEIBO_REDIRECT_URL=
> --variable  ANDROID_QQ_ID= 
> --variable  ANDROID_QQ_KEY= 
 
**3.测试的时候请设置正式签名否则无法正常的进行测试** 

 