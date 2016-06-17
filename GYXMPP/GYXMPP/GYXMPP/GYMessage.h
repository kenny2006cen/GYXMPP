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
@property (nullable, nonatomic, retain) NSNumber *msgId;
@property (nullable, nonatomic, retain) NSString *msgUserJid;
@property (nullable, nonatomic, retain) NSString *msgFriendJid;
@property (nullable, nonatomic, retain) NSNumber *msgType;
@property (nullable, nonatomic, retain) NSNumber *msgState;
@property (nullable, nonatomic, retain) NSNumber *msgRead;
@property (nullable, nonatomic, retain) NSNumber *msgShow;//消息是否显示

@property (nullable, nonatomic, retain) NSNumber *msgIsSelf;
@property (nullable, nonatomic, retain) NSString *msgSendTime;
@property (nullable, nonatomic, retain) NSString *msgRecTime;
@property (nullable, nonatomic, retain) NSString *msgBody;//json格式

@end

