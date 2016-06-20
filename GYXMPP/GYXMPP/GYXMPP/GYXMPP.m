//
//  GYXMPP.m
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "GYXMPP.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "XMPPReconnect.h"
#import "XMPPLogging.h"
#import "GYGenUUID.h"
#import "GYMessengeExtendElement.h"
#import "NSString+dictionaryToJsonString.h"

//#import "GYMessengeExtendElement.h"

NSString *const WCLoginStatusChangeNotification = @"WCLoginStatusNotification";

@interface GYXMPP ()<XMPPStreamDelegate>{
    
    XMPPResultBlock _resultBlock;
    
    XMPPReconnect *_reconnect;// 自动连接模块

    XMPPStream *_xmppStream;//
}
@property (nonatomic, assign) NSTimeInterval connectTimeout;




//内部方法
// 1. 初始化XMPPStream
-(void)setupXMPPStream;


// 2.连接到服务器
-(void)connectToHost;

// 3.连接到服务成功后，再发送密码授权
-(void)sendPwdToHost;


// 4.授权成功后，发送"在线" 消息
-(void)sendOnlineToHost;

@end

@implementation GYXMPP


#pragma mark - xmpp单例
static id _instace;


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _connectTimeout = 15.f;
    
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    return self;
}

#pragma mark  -初始化XMPPStream
-(void)setupXMPPStream{
    _xmppStream = [[XMPPStream alloc] init];
// 每一个模块添加后都要激活
    //添加自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
    // 添加聊天模块
    
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)teardownXmpp{
    
    // 移除代理
    [_xmppStream removeDelegate:self];
    
    // 停止模块
    [_reconnect deactivate];
      
    // 断开连接
    [_xmppStream disconnect];
    
    // 清空资源
    _reconnect = nil;
    _xmppStream = nil;
    
}

-(void)connectToHost{
  //  WCLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    // 发送通知【正在连接】
  //  [self postNotification:XMPPResultTypeConnecting];
    
//    self.userName =@"m_e_0603211000000000000";
//    self.passWord = @"0603211000000000000,4,bc84d7991daf0fc07371e5d0285d7c7d598ae68c5e25969ecfbc92c0f1655281,06032110000";
    
    self.domain = @"im.gy.com";
    self.host = @"ldev04.dev.gyist.com";
//    self.domain = @"appledemacintosh.local";
//    self.host = @"appledemacintosh.local";
    
    self.port = @"5222";
    
    self.resource = @"mobile_im";
    
    
    XMPPJID *myJID = [XMPPJID jidWithUser:self.userName domain: self.domain resource:self.resource];
    
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名
    _xmppStream.hostName =  self.host;//不仅可以是域名，还可是IP地址
    
    // 设置端口 如果服务器端口是5222，可以省略
    _xmppStream.hostPort = [self.port intValue];
    
    // 连接
    NSError *err = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        
        if (err) {
             DDLogInfo(@"%@",err);
        }
    }
    
}


#pragma mark 连接到服务成功后，再发送密码授权
-(void)sendPwdToHost{
  //  WCLog(@"再发送密码授权");
    NSError *err = nil;
    
    // 从单例里获取密码
   // NSString *pwd = [WCUserInfo sharedWCUserInfo].pwd;
    
    [_xmppStream authenticateWithPassword:self.passWord error:&err];
    
    if (err) {
        DDLogInfo(@"%@",err);
    }
}

-(void)sendOnlineToHost{
    
   // WCLog(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
  //  WCLog(@"%@",presence);
    
    [_xmppStream sendElement:presence];
    
}

-(void)postNotification:(XMPPResultType)resultType{
    
    // 将登录状态放入字典，然后通过通知传递
    NSDictionary *userInfo = @{@"loginStatus":@(resultType)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCLoginStatusChangeNotification object:nil userInfo:userInfo];
}

#pragma mark -XMPPStream Delegate

-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    
        // 主机连接成功后，发送密码进行授权
        [self sendPwdToHost];
}
#pragma mark  与主机断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    // 如果没有错误，表示正常的断开连接(人为断开连接)
    
    if(error && _resultBlock){
        _resultBlock(XMPPResultTypeNetErr);
        
    }
    
    if (error) {
        //通知 【网络不稳定】
        [self postNotification:XMPPResultTypeNetErr];
    }
   // WCLog(@"与主机断开连接 %@",error);
    
}


#pragma mark -Auth method
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
  //  WCLog(@"授权成功");
    
    [self sendOnlineToHost];
    
    // 回调控制器登录成功
    if(_resultBlock){
        _resultBlock(XMPPResultTypeLoginSuccess);
        _resultBlock =nil;
    }
    
  //  [self postNotification:XMPPResultTypeLoginSuccess];
    
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
  //  WCLog(@"授权失败 %@",error);
    
    // 判断block有无值，再回调给登录控制器
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
        
    }
    
    [self postNotification:XMPPResultTypeLoginFailure];
}


#pragma mark -XMPPMessage method
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
  //  WCLog(@"%@",message);
    
    //如果当前程序不在前台，发出一个本地通知
    
    NSString *toID = [[message attributeForName:@"to"] stringValue];
    
    //add by shiang,检查是否收到消息回执
    NSXMLElement *requestACK = [message elementForName:@"request" xmlnsPrefix:@"gy:abnormal:offline"];
    NSString *elementId = [[requestACK elementForName:@"id"] stringValue];


}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
    DDLogInfo(@"消息发送成功");
    
    if ([message isChatMessageWithBody]){
        NSString *msgID = [[message attributeForName:@"id"]stringValue];
        if (msgID){
           
            GYMessage *sendMessage = [GYMessage findByAttribute:@"msgId" WithValue:msgID];
            if (!sendMessage||[sendMessage isKindOfClass:[NSNull class]]) {
                
                DDLogCVerbose(@"找不到该条消息");
                return;
            }

            sendMessage.deliveryState=MessageDeliveryState_Delivered;
            
           BOOL flag= [sendMessage update];
            
            if (flag) {
                //更新消息发送状态后刷新UI
                
                if (self.delegate&&[self.delegate respondsToSelector:@selector(xmppDidSendMessage:)]) {
                    
                    [self.delegate xmppDidSendMessage:sendMessage];
                }
            //    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessageState" object:sendMessage];
            }
        }
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{

    DDLogInfo(@"消息发送失败");

    if ([message isChatMessageWithBody]){
       
        NSString *msgID = [[message attributeForName:@"id"]stringValue];
        if (msgID){
        
            GYMessage *sendMessage = [GYMessage findByAttribute:@"msgId" WithValue:msgID];
           
            if (!sendMessage||[sendMessage isKindOfClass:[NSNull class]]) {
                
                DDLogCVerbose(@"找不到该条消息");
                return;
            }
            
            sendMessage.deliveryState=MessageDeliveryState_Failure;
            
            BOOL flag= [sendMessage update];
            
            if (flag) {
                
                if (self.delegate&&[self.delegate respondsToSelector:@selector(xmppDidFailedSendMessage:)]) {
                    
                    [self.delegate xmppDidFailedSendMessage:sendMessage];
                }
                

                //更新消息发送状态后刷新UI
              //  [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessageState" object:sendMessage];
            }
            else{
                DDLogCVerbose(@"消息更新发送失败");

            }

            
        }
    }
}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //XMPPPresence 在线 离线
    
    //presence.from 消息是谁发送过来
}

#pragma mark -Custom method
-(void)xmppUserlogout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
    
    
}

-(void)xmppUserLogin:(XMPPResultBlock)resultBlock{
    
    // 先把block存起来
    _resultBlock = resultBlock;
    
    // 如果以前连接过服务，要断开
    [_xmppStream disconnect];
    
    // 连接主机 成功后发送登录密码
    [self connectToHost];
}

-(void)xmppUserLoginWithUserName:(NSString *)userName PassWord:(NSString*)password :(XMPPResultBlock)resultBlock{

    // 先把block存起来
    _resultBlock = resultBlock;
    
    // 如果以前连接过服务，要断开
    [_xmppStream disconnect];
    
    self.userName =@"m_e_0603211000000000000";
    self.passWord = @"0603211000000000000,4,3363e7844d0838a0bef59e6bb93af9b6d3e19bdc991f84f7aa4190794bdddeeb,06032110000";
//    self.userName =userName;@"jlc";
//    self.passWord =password; @"123";
    
    // 连接主机 成功后发送登录密码
    [self connectToHost];
}

-(void)xmppUserRegister:(XMPPResultBlock)resultBlock{
    // 先把block存起来
    _resultBlock = resultBlock;
    
    // 如果以前连接过服务，要断开
    [_xmppStream disconnect];
    
    // 连接主机 成功后发送注册密码
    [self connectToHost];
}

-(GYMessage*)sendMessage:(GYMessage *)message{
    
    //先保存默认数据
    message.msgId = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] ;
    
    message.msgBodyType =(int)MessageBodyType_Text;

    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    
    message.msgSendTime=dateString;
    message.msgRecTime =dateString;
    
    message.msgIsSelf=YES;
    message.msgRead=YES;//默认发送消息为已读，暂时先这样处理
    message.msgUserJid = self.userName;
    message.deliveryState =MessageDeliveryState_Delivering;
    
    message.msgShow= YES;
    
    NSString *elementID = [NSString stringWithFormat:@"%@",message.msgId];
    
    XMPPJID *JID = [XMPPJID jidWithString:message.msgFriendJid];
    
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:JID elementID:elementID];
    
    NSString *uuid=[GYGenUUID gen_uuid];
    NSXMLElement *uidelement=[GYMessengeExtendElement GYExtendElementWithID:uuid];
    
    [xmppMessage addChild:uidelement];
    
    [xmppMessage addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",message.msgUserJid,self.domain]];
    
    [xmppMessage addBody:message.msgBody];
    
   
  BOOL flag= [message save];
    
    if (flag) {
        
         [_xmppStream sendElement:xmppMessage];
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(xmppSendingMessage:)]) {
            
            [self.delegate xmppSendingMessage:message];
            
        }
    }
   
    
    return message;
}


//发送文本
-(GYMessage*)sendTextMessageWithString:(NSString*)text ToUser:(NSString*)userName{

    GYMessage *message =[[GYMessage alloc]init];
    
    message.msgUserJid =[GYXMPP sharedInstance].userName;
    
    message.msgFriendJid =userName;
    
    message.msgBodyType =MessageBodyType_Text;
    
    if ((text==nil||[text isKindOfClass:[NSNull class]])) {
        
        DDLogCVerbose(@"发送文本为空,请停止发送");
        
        return nil;
    }
    
    else{
    
        if (self.userNickName==nil||[self.userNickName isKindOfClass:[NSNull class]]) {
            
            self.userNickName=@"";
            self.userNickName=@"系统操作员";
            
        }
        
        if (self.userPhoto==nil||[self.userPhoto isKindOfClass:[NSNull class]]) {
            
            self.userPhoto=@"";
        }
        
        NSDictionary *dic =@{@"msg_content":text,
                             @"msg_type":@"2",
                             @"msg_icon":self.userPhoto,
                             @"msg_note":self.userNickName,
                             @"msg_code":@"00"};
        
        message.msgBody =[NSString dictionaryToJsonString:dic];
        
        [[GYXMPP sharedInstance]sendMessage:message];
        
        return message;
       
    }
    

}

//发送图片
-(GYMessage*)sendImageMessageWithImage:(UIImage*)image ToUser:(NSString*)userName{

    return nil;

}

//发送语音
-(GYMessage*)sendAudioMessageWithVoice:(GYHDVoiceModel*)voice ToUser:(NSString*)userName{

    return nil;

}

#pragma mark - lifecycle
-(void)dealloc{
    [self teardownXmpp];
}

@end
