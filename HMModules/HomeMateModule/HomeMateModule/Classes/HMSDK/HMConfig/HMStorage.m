//
//  HMStorageClass.m
//  HomeMateSDK
//
//  Created by Air on 16/3/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMStorage.h"
#import "HMUtil.h"

@implementation HMStorage

+ (instancetype)shareInstance
{
    Singleton();
}

-(NSString *)appName
{
    if (!_appName) {
        [NSException raise:@"异常信息" format:@"请设置AppName"];
    }
    return _appName;
}

-(NSString *)descSource
{
    if (!_descSource) {
        [NSException raise:@"异常信息" format:@"请设置descSource"];
    }
    return _descSource;
}

-(NSString *)deviceToken{
    
    return [HMUserDefaults objectForKey:@"token"];
}

-(void)setDeviceToken:(NSString *)deviceToken{
    
    if (deviceToken) {
        
        [HMUserDefaults setObject:deviceToken forKey:@"token"];
        [HMUserDefaults synchronize];
    }
}

-(NSMutableArray *)taskArray
{
    if (!_taskArray) {
        _taskArray = [[NSMutableArray alloc]init];
    }
    return _taskArray;
}

-(NSMutableDictionary *)hmCacheDic
{
    if (!_hmCacheDic) {
        _hmCacheDic = [[NSMutableDictionary alloc]init];
    }
    return _hmCacheDic;
}
@end
