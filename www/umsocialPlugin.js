
var exec = require("cordova/exec");

function UmsocialModel() {};

    // 目前支持的平台名字: "sina", "wechatSession", "wechatTimeLine", "qq"

//分享网页

//示例

// platform: 平台名字
// thumbURL: 封面图片
// title': 标题 
// description': 描述
// webPageURL': 分享的网页链接

// var data = {'platform': 'sina', 
// 			'thumbURL': 'https://mobile.umeng.com/images/pic/home/social/img-1.png',
// 			 'title': '哈哈哈', 
// 			 'description': '哦哦哦', 
// 			 'webPageURL': 
// 			 'http://mobile.umeng.com/social'};

//  function shareToSina() {
	//data一定要放到数组里面再传
//     umsocialModel.shareWebPage(alertSuccess,alertFail,[data]);
// }
UmsocialModel.prototype.shareWebPage = function (success,fail,option) {
     exec(success, fail, 'umsocial', 'shareWebPage', option);
};




//三方登录

//示例

// platform: 平台名字
// var data = {'platform': 'sina'};


//  function loginToSina() {
	//data一定要放到数组里面再传
//     umsocialModel.loginWithPlatform(alertSuccess,alertFail,[data]);
// }

//登录返回值:
//这是友盟返回的所有字段, 有的字段在某些平台会返回空.
// {"name": "", //名字
// "iconurl": "", //头像
// "gender": "", //性别
// "uid": "", //uid
// "openid": "", //openid
// "accessToken": "", //accessToken
// "refreshToken": "", //refreshToken
// "expiration": ""} //过期时间

UmsocialModel.prototype.loginWithPlatform = function (success,fail,option) {
     exec(success, fail, 'umsocial', 'loginWithPlatform', option);
};


//是否安装了某个社交平台

//示例

// platform: 平台名字
// var data = {'platform': 'sina'};


//  function checkSina() {
	//data一定要放到数组里面再传
//     umsocialModel.isInstalledPlatform(alertSuccess,alertFail,[data]);
// }
UmsocialModel.prototype.isInstalledPlatform = function (success,fail,option) {
    exec(success, fail, 'umsocial', 'isInstalledPlatform', option);
};

var umsocialModel = new UmsocialModel();
module.exports = umsocialModel;



//分享或登录失败时返回的错误码
 // 2000            // 未知错误
 // 2001            // 不支持（url scheme 没配置，或者没有配置-ObjC， 或则SDK版本不支持或则客户端版本不支持）
 // 2002            // 授权失败
 // 2003            // 分享失败
 // 2004  			// 请求用户信息失败
 // 2005            // 分享内容为空
 // 2006       	    // 分享内容不支持
 // 2007            // schemaurl fail
 // 2008            // 应用未安装
 // 2009            // 用户取消操作
 // 2010            // 网络异常
 // 2011            // 第三方错   
 // 2013   			// 对应的UMSocialPlatformProvider的方法没有实现
 // 2014   			// 没有用https的请求,@see UMSocialGlobal isUsingHttpsWhenShareContent





