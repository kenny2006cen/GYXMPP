//
//  GYMessage+CoreDataProperties.h
//  GYXMPP
//
//  Created by User on 16/6/14.
//  Copyright © 2016年 jianglincen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GYMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *msgId;
@property (nullable, nonatomic, retain) NSString *msgFromUser;
@property (nullable, nonatomic, retain) NSString *msgToUser;
@property (nullable, nonatomic, retain) NSNumber *msgType;
@property (nullable, nonatomic, retain) NSNumber *msgState;
@property (nullable, nonatomic, retain) NSNumber *msgRead;
@property (nullable, nonatomic, retain) NSString *msgCard;

@property (nullable, nonatomic, retain) NSNumber *msgIsSelf;
@property (nullable, nonatomic, retain) NSString *msgSendTime;
@property (nullable, nonatomic, retain) NSString *msgRecTime;
@property (nullable, nonatomic, retain) NSString *msgBody;//json格式

@end

NS_ASSUME_NONNULL_END
