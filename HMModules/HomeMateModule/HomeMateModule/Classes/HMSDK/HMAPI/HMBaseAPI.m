//
//  HMBaseAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/5.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMBaseBusiness.h"

@implementation HMBaseAPI
+ (void)postNotification:(NSString *)aName object:(id)anObject
{
    [HMBaseBusiness postNotification:aName object:anObject];
}
+ (void)postNotification:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    [HMBaseBusiness postNotification:aName object:anObject userInfo:aUserInfo];
}
@end
