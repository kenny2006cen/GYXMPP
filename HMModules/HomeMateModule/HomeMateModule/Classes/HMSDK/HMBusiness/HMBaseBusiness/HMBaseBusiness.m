//
//  HMBaseBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/5.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"
#import "HMStorage.h"

@implementation HMBaseBusiness

+(id <HMBusinessProtocol>)delegate
{
    return [HMStorage shareInstance].delegate;
}

+ (void)postNotification:(NSString *)aName object:(id)anObject
{
    //DLog(@"postNotification:%@ anObject:%@",aName,anObject);
    DLog(@"postNotification:%@",aName);
    
    if ([[NSThread currentThread]isMainThread]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject];
        });
    }
}
+ (void)postNotification:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    //DLog(@"postNotification:%@ anObject:%@ userInfo:%@",aName,anObject,aUserInfo);
    DLog(@"postNotification:%@",aName);
    
    if ([[NSThread currentThread]isMainThread]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject userInfo:aUserInfo];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject userInfo:aUserInfo];
        });
    }
}
@end
