//
//  CDVAppDelegate+UMSocial.m
//  testCordova
//
//  Created by DLonion on 2017/3/1.
//
//

#import "CDVAppDelegate+UMSocial.h"
#import <objc/runtime.h>
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialDefine.h"

#define USHARE_DEMO_APPKEY @"5861e5daf5ade41326001eab"

@implementation CDVAppDelegate (UMSocial)

+(void)load{
    Method origin1;
    Method swizzle1;
    origin1  = class_getInstanceMethod([self class],@selector(init));
    swizzle1 = class_getInstanceMethod([self class], @selector(um_init));
    method_exchangeImplementations(origin1, swizzle1);
    
    origin1  = class_getInstanceMethod([self class],@selector(application:openURL: sourceApplication:annotation:));
    swizzle1 = class_getInstanceMethod([self class], @selector(um_application:openURL: sourceApplication:annotation:));
    method_exchangeImplementations(origin1, swizzle1);
    
    origin1  = class_getInstanceMethod([self class],@selector(application:handleOpenURL:));
    swizzle1 = class_getInstanceMethod([self class], @selector(um_application:handleOpenURL:));
    method_exchangeImplementations(origin1, swizzle1);
}

-(instancetype)um_init{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidLaunch:) name:UIApplicationDidFinishLaunchingNotification object:nil];

    return [self um_init];
}

NSDictionary *_launchOptions;

-(void)applicationDidLaunch:(NSNotification *)notification{
    
    if (notification) {

        /* 打开日志 */
        [[UMSocialManager defaultManager] openLog:YES];
        // 打开图片水印
        //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
        [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = YES;

        _launchOptions = notification.userInfo;
        [self configUSharePlatforms];
        
    }
}

- (void)configUSharePlatforms

{
    
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:UMConfig_fileName ofType:@"plist"];
    NSMutableDictionary *plistData = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UMAppKeys"];
    
    NSString *appKey = plistData[UMConfig_appKey];
    NSString *wechatSessionAppKey = plistData[UMConfig_wechatSessionAppKey];
    NSString *wechatSessionAppSecret = plistData[UMConfig_wechatSessionAppSecret];
    NSString *qqAppKey = plistData[UMConfig_qqAppKey];
    NSString *sinaAppKey = plistData[UMConfig_sinaAppKey];
    NSString *sinaAppSecret = plistData[UMConfig_sinaAppSecret];
    NSString *sinaURL = plistData[UMConfig_sinaRedirectURL];
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:appKey];
    
    
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:wechatSessionAppKey appSecret:wechatSessionAppSecret redirectURL:@"http://www.bjzjns.com"];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:qqAppKey/*设置QQ平台的appID*/  appSecret:nil redirectURL:nil];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:sinaAppKey  appSecret:sinaAppSecret redirectURL:sinaURL];
}


- (BOOL)um_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响

    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    [self um_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return result;
}


- (BOOL)um_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    [self um_application:application handleOpenURL:url];
    return result;
}

@end
