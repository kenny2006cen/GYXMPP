//
//  HMAppFactoryLocalConfig.h
//  HomeMateSDK
//
//  Created by liqiang on 17/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAppFactoryLocalConfig : NSObject
+(NSArray *)localConfigSQL;
+(BOOL)localConfigDataChange;
@end
