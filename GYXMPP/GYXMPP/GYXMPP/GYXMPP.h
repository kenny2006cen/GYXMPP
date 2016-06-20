//
//  GYXMPP.h
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDlog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

#import "GYMessage.h"
#import "GYHDVoiceModel.h"
#import "GYHDVideoModel.h"

//// 自定义Log

//#ifdef DEBUG
//
//#define WCLog(...) NSLog(@"%s %d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
//
//#else
//#define WCLog(...)
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

typedef enum {
    XMPPResultTypeConnecting,//连接中...
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure,//登录失败
    XMPPResultTypeNetErr,//网络不给力
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type);// XMPP请求结果的block


@protocol GYXMPPDelegate <NSObject>

-(void)xmppSendingMessage:(GYMessage*)message;

-(void)xmppDidSendMessage:(GYMessage*)message;

-(void)xmppDidFailedSendMessage:(GYMessage*)message;

-(void)xmppdidReceiveMessage:(GYMessage*)message;

@end

@interface GYXMPP : NSObject

@property(nonatomic,assign)id <GYXMPPDelegate>delegate;

@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *passWord;
@property (nonatomic,copy) NSString *host;
@property (nonatomic,copy) NSString *port;
@property (nonatomic,copy) NSString *domain;
@property (nonatomic,copy) NSString *resource;

@property (nonatomic,copy) NSString *userNickName;//当前用户昵称,需要在发送前配置

@property (nonatomic,copy) NSString *userPhoto;//当前用户头像,需要在发送前配置

+ (instancetype)sharedInstance;

/**
 *  用户注销
 
 */
-(void)xmppUserlogout;
/**
 *  用户登录
 */
-(void)xmppUserLogin:(XMPPResultBlock)resultBlock;

-(void)xmppUserLoginWithUserName:(NSString *)userName PassWord:(NSString*)password :(XMPPResultBlock)resultBlock;



/*
  最终发送方法
 */
-(GYMessage*)sendMessage:(GYMessage*)message;

//发送文本
-(GYMessage*)sendTextMessageWithString:(NSString*)text ToUser:(NSString*)userName;

//发送图片
-(GYMessage*)sendImageMessageWithImage:(UIImage*)image ToUser:(NSString*)userName;

//发送语音
-(GYMessage*)sendAudioMessageWithVoice:(GYHDVoiceModel*)voice ToUser:(NSString*)userName;
@end
