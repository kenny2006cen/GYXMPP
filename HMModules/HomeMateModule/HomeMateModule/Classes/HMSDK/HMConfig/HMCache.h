//
//  HMCache.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/12/21.
//  Copyright © 2018 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    注意！！！！！！！！
    HMCache主要用于将短时间内会反复调用的方法的结果【缓存在内存中，默认缓存10s】，避免在短时间内反复查询数据库
 */

#define hmCachedValue(key) [HMCache objectForKey:[NSString stringWithFormat:@"%s_%@",__func__,key]]

#define hmCache(key,value) [HMCache cacheObject:value forKey:[NSString stringWithFormat:@"%s_%@",__func__,key]]

@interface HMCache : NSObject

+ (id)objectForKey:(NSString *)aKey;

+ (void)cacheObject:(id)anObject forKey:(NSString *)aKey;

@end
