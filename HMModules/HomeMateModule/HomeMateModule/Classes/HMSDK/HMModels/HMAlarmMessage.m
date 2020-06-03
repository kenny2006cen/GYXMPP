//
//  VihomeAlarmMessage.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAlarmMessage.h"

@implementation HMAlarmMessage

+(NSString *)tableName
{
    return @"alarmMessage";
}
+ (NSArray*)columns
{
    return @[column("messageId", "text"),
             column("uid", "text"),
             column("deviceId", "text"),
             column("type", "integer"),
             column("time", "integer"),
             column("message", "text"),
             column("readType", "integer"),
             column("disarmFlag", "integer"),
             column("createTime", "text"),
             column("updateTime", "text"),
             column("delFlag", "integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (messageId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from alarmMessage where messageId = '%@' and uid = '%@'",self.messageId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

@end
