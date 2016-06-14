//
//  GYXMPP.h
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDlog.h"
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


@interface GYXMPP : NSObject

+ (instancetype)sharedInstance;

/**
 *  用户注销
 
 */
-(void)xmppUserlogout;
/**
 *  用户登录
 */
-(void)xmppUserLogin:(XMPPResultBlock)resultBlock;

@end
