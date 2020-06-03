//
//  HMBaseAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/5.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMBaseAPI : NSObject

+ (void)postNotification:(NSString *_Nonnull)aName object:(nullable id)anObject;

+ (void)postNotification:(NSString *_Nonnull)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;
@end
