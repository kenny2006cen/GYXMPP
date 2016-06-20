//
//  GYMessage.h
//  GYXMPP
//
//  Created by User on 16/6/14.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GYFMDB.h"
#import "NSObject+GYFMDB.h"

typedef NS_ENUM(NSInteger, MessageBodyType) {
    MessageBodyType_Text = 0, //文本
    MessageBodyType_Image,    //图片
    MessageBodyType_Video,    //视频
    MessageBodyType_Voice,    //语音
//    MessageBodyType_File,
//    MessageBodyType_Command
};

typedef NS_ENUM(NSInteger, MessageDeliveryState) {
   
    MessageDeliveryState_Delivering =0,//发送中
    MessageDeliveryState_Delivered, //已经发送
    MessageDeliveryState_Failure    //已经发送
};

@interface GYMessage : NSObject

// Insert code here to declare functionality of your managed object subclass
@property (nonatomic, strong) NSNumber *msgId;
@property ( nonatomic, copy) NSString *msgUserJid;
@property ( nonatomic, copy) NSString *msgFriendJid;
@property ( nonatomic, assign) MessageBodyType  msgBodyType;
@property ( nonatomic, assign) MessageDeliveryState deliveryState;
@property ( nonatomic) BOOL msgRead;
@property ( nonatomic) BOOL msgShow;//消息是否显示

@property ( nonatomic) BOOL msgIsSelf;
@property ( nonatomic, copy) NSString *msgSendTime;
@property ( nonatomic, copy) NSString *msgRecTime;
@property ( nonatomic, copy) NSString *msgBody;//json格式

@property ( nonatomic, copy) NSString *msgUserName;//用户名

@property ( nonatomic, copy) NSString *msgUserHead;//用户头像

//+(BOOL)updateMesageDeliveryStatusToDB;//更新消息发送状态

@end

