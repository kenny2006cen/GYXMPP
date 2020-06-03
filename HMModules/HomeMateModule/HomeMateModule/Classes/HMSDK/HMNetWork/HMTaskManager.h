//
//  HMTaskManager.h
//  HomeMateSDK
//
//  Created by 管理员 on 2017/4/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMTypes.h"

@class BaseCmd;
@class GlobalSocket;

@protocol StateMachineProtocol <NSObject>

@required
@property(nonatomic,strong) NSString *          host; // host
@property(nonatomic,assign) UInt16              port; // 端口号
-(GlobalSocket *)socket;
-(void)didSendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion;

@end

@interface HMTaskManager:NSObject

+(instancetype)stateWithDelegate:(id<StateMachineProtocol>)gateway;

// 判断指令是否需要登录
+(BOOL)isNeedLogin:(BaseCmd *)cmd;

-(BOOL)isConnected;

-(BOOL)isReady:(BaseCmd *)cmd;
-(void)prepare;
-(void)reset;

-(void)addTask:(BaseCmd *)cmd;
-(void)removeAllTasks;

-(HMUserLoginType)userLoginType;
@end

