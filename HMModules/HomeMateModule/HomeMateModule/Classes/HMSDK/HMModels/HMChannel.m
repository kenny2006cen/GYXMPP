//
//  HMChannel.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMChannel.h"
#import "HMBaseModel+Extension.h"

@implementation HMChannel
+(NSString *)tableName
{
    return @"channel";
}

+ (NSArray*)columns
{
    return @[
             column("channelName", "text"),
             column("channelNamePinYin", "text"),
             column("type", "integer"),
             column("sequence", "integer"),
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSMutableArray *)allChannel {
    
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from channel order by sequence"];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMChannel object:rs]];
    }
    [rs close];
    return array;
}
+ (BOOL)deleteAllChannel {
    NSString * sql = [NSString stringWithFormat:@"delete from channel"];
    BOOL result = [self executeUpdate:sql];
    return result;
}
- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
     pinyin = [[pinyin stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    return [pinyin uppercaseString];
}


@end
