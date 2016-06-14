//
//  GYMessage+CoreDataProperties.m
//  GYXMPP
//
//  Created by User on 16/6/14.
//  Copyright © 2016年 jianglincen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GYMessage+CoreDataProperties.h"

@implementation GYMessage (CoreDataProperties)

@dynamic msgId;
@dynamic msgFromUser;
@dynamic msgToUser;
@dynamic msgType;
@dynamic msgState;
@dynamic msgRead;
@dynamic msgCard;
@dynamic msgContent;
@dynamic msgIsSelf;
@dynamic msgSendTime;
@dynamic msgRecTime;
@dynamic msgBody;

@end
