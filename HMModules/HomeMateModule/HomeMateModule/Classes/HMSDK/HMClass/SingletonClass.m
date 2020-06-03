//
//  SingletonClass.m
//  Vihome
//
//  Created by orvibo on 15-1-15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SingletonClass.h"

@implementation SingletonClass

#pragma mark - 模板，需要子类自己实现
+ (instancetype)shareInstance
{
    [NSException raise:@"异常信息" format:@"子类必须自己实现此方法"];
    Singleton();
    
#if 0
    static id __singletion__;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __singletion__ =[[self alloc] init];
    });
    
    return __singletion__;
#endif
}

@end
