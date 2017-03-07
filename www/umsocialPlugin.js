
var exec = require("cordova/exec");

function UmsocialModel() {};

//分享网页
UmsocialModel.prototype.shareWebPage = function (success,fail,option) {
     exec(success, fail, 'umsocial', 'shareWebPage', option);
};

//三方登录
UmsocialModel.prototype.loginWithPlatform = function (success,fail,option) {
     exec(success, fail, 'umsocial', 'loginWithPlatform', option);
};

var umsocialModel = new UmsocialModel();
module.exports = umsocialModel;

//分享示例

// 目前支持的平台名字: "sina", "wechatSession", "wechatTimeLine", "qq"

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



//登录示例

// 目前支持的平台名字: "sina", "wechatSession", "qq"

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

