//
//  VihomeDeviceIr.m
//  Vihome
//
//  Created by Air on 15-2-9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceIr.h"

#import "HMDevice.h"
#import "HMDatabaseManager.h"

@implementation HMDeviceIr

+(NSString *)tableName
{
    return @"deviceIr";
}
/**
 *  FMDB中sqlite中存储不能用order index等关键字
 */
+ (NSArray*)columns
{
    return @[column("deviceIrId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("deviceAddress","text"),
             column("length","integer"),
             column("ir","text"),
             column("keyName","text"),
             column("sequence","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (deviceIrId) ON CONFLICT REPLACE";
}


+ (instancetype)object:(FMResultSet *)rs
{
    HMDeviceIr *deviceIr = [super object:rs];
    deviceIr.temporarySequence = deviceIr.sequence;
    return deviceIr;
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)updateObjectWithDeviceID
{
    NSString * sql = [NSString stringWithFormat:@"update deviceIr set deviceIrId='%@',uid = \"%@\",deviceId='%@',bindOrder = \"%@\",deviceAddress= \"%@\",length=%d,ir=\"%@\",updateTime=\"%@\",delFlag=%d where deviceId = '%@' and uid =\"%@\" and bindOrder =\"%@\" ",self.deviceIrId,self.uid,self.deviceId,self.bindOrder,self.deviceAddress,self.length,self.ir,self.updateTime,self.delFlag,self.deviceId,self.uid,self.bindOrder];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceIr where deviceIrId = '%@' and uid = '%@'",self.deviceIrId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.deviceIrId forKey:@"deviceIrId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.deviceId forKey:@"deviceId"];
    [dic setObject:self.bindOrder forKey:@"order"];
    [dic setObject:self.deviceAddress forKey:@"deviceAddress"];
    [dic setObject:[NSNumber numberWithInt:self.length] forKey:@"length"];
    [dic setObject:self.ir forKey:@"ir"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

+ (NSArray *)getCorrespondingObjectByDevice:(HMDevice *)device
{
    NSArray * array = [[HMDatabaseManager shareDatabase] selectAllRecord:[HMDeviceIr class] withCondition:[NSString stringWithFormat:@"uid=\"%@\" and deviceId='%@' and delFlag=0 order by sequence asc",device.uid,device.deviceId]];
    return array;
}

+ (HMDeviceIr *)getCorrespondingObjectByOrder:(NSString *)order device:(HMDevice *)device
{
    NSArray * array = [[HMDatabaseManager shareDatabase] selectAllRecord:[HMDeviceIr class] withCondition:[NSString stringWithFormat:@"uid=\"%@\" and deviceId='%@' and delFlag=0 and bindOrder =\"%@\"",device.uid,device.deviceId,order]];
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    return nil;
}

+ (int)getMaxInfraredOrderByUID:(NSString *)uid deviceID:(NSString *)deviceId
{
    FMResultSet *set = [self executeQuery:[NSString stringWithFormat:@"select count(*) KeyNumber from deviceIr where uid =\"%@\" and deviceId = '%@'",uid,deviceId]];
    while ([set next]) {
        int existNum = [[set stringForColumn:@"KeyNumber"] intValue];
        
        [set close];
        return 370000 + existNum;
    }
    
    [set close];
    return 370000;
}

-(BOOL)sequenceChanged
{
    BOOL changed = (self.sequence != self.temporarySequence);
    return changed;
}

-(void)saveChangedSequence:(BOOL)save
{
    if (save) {
        self.sequence = self.temporarySequence;
        [self insertObject];
    }
}
@end
