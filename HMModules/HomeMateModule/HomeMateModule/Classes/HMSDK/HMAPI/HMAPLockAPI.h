//
//  HMAPLockAPI.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/2/28.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMAPConfigAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMAPLockAPI : NSObject
/**
 设置d回调
 
 @param delegate delegate
 */
+ (void)setAPConfigDelegate:(id<VhAPConfigDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
