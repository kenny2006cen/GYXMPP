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
@property (nullable, nonatomic, strong) NSNumber *msgId;
@property (nullable, nonatomic, copy) NSString *msgUserJid;
@property (nullable, nonatomic, copy) NSString *msgFriendJid;
@property (nullable, nonatomic, strong) NSNumber *msgType;
@property (nullable, nonatomic, strong) NSNumber *msgState;
@property (nullable, nonatomic, strong) NSNumber *msgRead;
@property (nullable, nonatomic, strong) NSNumber *msgShow;//消息是否显示

@property (nullable, nonatomic, retain) NSNumber *msgIsSelf;
@property (nullable, nonatomic, copy) NSString *msgSendTime;
@property (nullable, nonatomic, copy) NSString *msgRecTime;
@property (nullable, nonatomic, copy) NSString *msgBody;//json格式

@end

