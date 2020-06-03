//
//  HMCache.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/12/21.
//  Copyright © 2018 orvibo. All rights reserved.
//

#import "HMCache.h"
#import "HMStorage.h"

@implementation HMCache

+ (NSTimeInterval)defaultCacheTime
{
    return 10;
}
+ (id)objectForKey:(NSString *)aKey
{
    NSParameterAssert(aKey);
    NSDictionary *objDic = [[HMStorage shareInstance]hmCacheDic][aKey];
    if (objDic) {
        // 如果已缓存时长在规定时间内就直接返回缓存结果
        NSDate *date = objDic[@"date"];
        NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
        if (timeInterval < [self defaultCacheTime]) {
            return objDic[@"object"];
        }
    }
    // 缓存时间已超过默认时长，移除缓存结果
    [[[HMStorage shareInstance]hmCacheDic]removeObjectForKey:aKey];
    return nil;
}

+ (void)cacheObject:(id)anObject forKey:(NSString *)aKey
{
    NSParameterAssert(anObject);
    NSParameterAssert(aKey);
    [[[HMStorage shareInstance]hmCacheDic]setObject:@{@"object":anObject,@"date":[NSDate date]} forKey:aKey];
}

@end
