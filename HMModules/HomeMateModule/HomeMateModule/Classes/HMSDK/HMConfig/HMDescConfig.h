//
//  HMDescConfig.h
//  HomeMate
//
//  Created by Air on 16/9/23.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMTypes.h"

@interface HMDescConfig : NSObject

// 内置数据版本号变化了
+(BOOL)isBuiltInDataVersionChanged;

+(NSArray *)localConfigSQL;

+(void)getDeviceInfoFromServer:(commonBlock)completion;

@end
