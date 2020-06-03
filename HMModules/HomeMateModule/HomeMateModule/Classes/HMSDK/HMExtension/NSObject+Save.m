//
//  NSObject+Save.m
//  Vihome
//
//  Created by Air on 15/6/29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NSObject+Save.h"
#import "HMConstant.h"

@implementation NSObject (Save)

-(id)objectWithKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(void)saveObject:(id)obj withKey:(NSString *)key
{
    if (obj) {
        
        DLog(@"保存数据 key:%@ value:%@",key,obj);
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)removeObjectWithKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
