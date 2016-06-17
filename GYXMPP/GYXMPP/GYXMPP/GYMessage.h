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

@interface GYMessage : NSObject

// Insert code here to declare functionality of your managed object subclass
@property (nonatomic, strong) NSNumber *msgId;
@property ( nonatomic, copy) NSString *msgUserJid;
@property ( nonatomic, copy) NSString *msgFriendJid;
@property ( nonatomic, strong) NSNumber *msgType;
@property ( nonatomic, strong) NSNumber *msgState;
@property ( nonatomic, strong) NSNumber *msgRead;
@property ( nonatomic, strong) NSNumber *msgShow;//消息是否显示

@property ( nonatomic, strong) NSNumber *msgIsSelf;
@property ( nonatomic, copy) NSString *msgSendTime;
@property ( nonatomic, copy) NSString *msgRecTime;
@property ( nonatomic, copy) NSString *msgBody;//json格式

@property ( nonatomic, copy) NSString *msgUserName;//用户名

@end

