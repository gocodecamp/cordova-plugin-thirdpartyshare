//
//  ZJUMSocialPlugin.m
//  testCordova
//
//  Created by DLonion on 2017/3/1.
//
//

#import "ZJUMSocialPlugin.h"
#import <UMSocialCore/UMSocialCore.h>
#import <objc/runtime.h>

@interface ZJUMSocialPlugin ()

@property (nonatomic, strong) NSString *callbackId;

@end

@implementation ZJUMSocialPlugin


-(void)isInstalledPlatform:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    if (command.arguments.count>0) {
        //customize argument
        NSDictionary* dict = command.arguments[0];
        NSString *platformString = dict[@"platform"];
        
        UMSocialPlatformType platformType = [self platformTypeWithString:platformString];
        
        if (platformType == -1 || (platformType != UMSocialPlatformType_QQ && platformType != UMSocialPlatformType_Sina && platformType != UMSocialPlatformType_WechatSession && platformType != UMSocialPlatformType_WechatTimeLine)) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"平台名字错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            BOOL isInstalled = [[UMSocialManager defaultManager] isInstall:platformType];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isInstalled];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }
        
        
    }else{
        //callback
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有参数"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}



-(void)loginWithPlatform:(CDVInvokedUrlCommand *)command {
    
    self.callbackId = command.callbackId;
    if (command.arguments.count>0) {
        //customize argument
        NSDictionary* dict = command.arguments[0];
        NSString *platformString = dict[@"platform"];
        
        UMSocialPlatformType platformType = [self platformTypeWithString:platformString];
        
        if (platformType == -1 || (platformType != UMSocialPlatformType_QQ && platformType != UMSocialPlatformType_Sina && platformType != UMSocialPlatformType_WechatSession && platformType != UMSocialPlatformType_WechatTimeLine)) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"平台名字错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            [self getUserInfoForPlatform:platformType];
        }
        
        
        
    }else{
        //callback
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有参数"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    
}

-(void)shareWebPage:(CDVInvokedUrlCommand *)command{
    
    self.callbackId = command.callbackId;
    if (command.arguments.count>0) {
        //customize argument
        NSDictionary* dict = command.arguments[0];
        NSString *platformString = dict[@"platform"];
        NSString *thumbURL = dict[@"thumbURL"];
        NSString *title = dict[@"title"];
        NSString *description = dict[@"description"];
        NSString *webPageURL = dict[@"webPageURL"];
        
        UMSocialPlatformType platformType = [self platformTypeWithString:platformString];
        
        if (platformType == -1) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"平台名字错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            [self shareWebPageToPlatformType:platformType thumbURL:thumbURL title:title description:description webPageURL:webPageURL];
        }
        
        
        
    }else{
        //callback
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有参数"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType thumbURL:(NSString *)thumbURL title:(NSString *)title description:(NSString *)description webPageURL:(NSString *)webPageURL
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:description thumImage:thumbURL];
    //设置网页地址
    shareObject.webpageUrl = webPageURL;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        
        if (error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:error.code];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
            
        }else{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"分享成功"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }
        
    }];
}

- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:[UIApplication sharedApplication].keyWindow.rootViewController completion:^(id result, NSError *error) {
        
        UMSocialUserInfoResponse *resp = result;
        
        NSDictionary *mDict = [self zj_KeysAndValuesFromRespons:resp];
        
        if (error == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:error.code];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }
        
        
        // 第三方平台SDK原始数据
        NSLog(@" originalResponse: %@", resp.originalResponse);
    }];
}



- (UMSocialPlatformType)platformTypeWithString:(NSString *)string {
    
    int index = -1;
    NSArray * platformArray = @[@"sina", @"wechatSession", @"wechatTimeLine", @"qq"];
    for (int i = 0; i<platformArray.count; i++) {
        if ([string isEqualToString:platformArray[i]]) {
            index = i;
            break;
        }
    }
    
    switch (index) {
        case 0:
            return UMSocialPlatformType_Sina;
            break;
        case 1:
            return UMSocialPlatformType_WechatSession;
            break;
        case 2:
            return UMSocialPlatformType_WechatTimeLine;
            break;
        case 3:
            return UMSocialPlatformType_QQ;
            break;
        default:
            return -1;
            break;
    }
    
}



- (NSDictionary *)zj_KeysAndValuesFromRespons: (UMSocialUserInfoResponse *)respons {
    NSArray *keyArray = @[@"name", @"iconurl", @"gender", @"uid", @"openid", @"accessToken", @"refreshToken", @"expiration"];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    for (int i = 0; i<keyArray.count; i++) {
        NSString *key = keyArray[i];
        id value = [respons valueForKey:key];
        
        if ([value isKindOfClass:[NSDate class]]) {
            NSDate *date = value;
            value = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
        }
        if (value != nil) {
            
            [mDict setObject:value forKey:key];
        }
    }
    return mDict;
}



@end
