//
//  HMTimingGroupModel.m
//  HomeMate
//
//  Created by Air on 16/7/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMTimingGroupModel.h"
#import "HMTiming.h"
#import "HMDevice.h"
#import "HMConstant.h"

@interface HMTimingGroupModel ()

@property (nonatomic, retain) NSString *initialName;
@property (nonatomic, assign) int initialIsPause; /* 0暂停，1生效 **/
@property (nonatomic, assign) int initialWeek;
@property (nonatomic,strong) NSString *initialBeginTime;
@property (nonatomic,strong) NSString *initialEndTime;

@end

@implementation HMTimingGroupModel
+ (NSString *)tableName {
    
    return @"timingGroup";
}

+ (NSArray*)columns
{
    return @[
             column("timingGroupId","text"),
             column("uid","text"),
             column("name","text"),
             column("deviceId","text"),
             column("isPause","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (timingGroupId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {
    
    NSString *updateTimingGroupSql  = [NSString stringWithFormat:@"delete from timing where timingGroupId = '%@'",self.timingGroupId];
    updateInsertDatabase(updateTimingGroupSql);
    
    NSString *sql = [NSString stringWithFormat:@"delete from timingGroup where timingGroupId = '%@'",self.timingGroupId];
    return [self executeUpdate:sql];
}

// 开始时间对应的 timer
-(HMTiming *)beginTimer
{
    HMTiming *timing = [self timingWithShowIndex:1];
    return timing;
}
-(NSString *)beginTime
{
    if (!_beginTime) {
        HMTiming *timing = [self beginTimer];
        if (timing) {
            _beginTime = [NSString stringWithFormat:@"%02d:%02d",timing.hour,timing.minute];
        }
    }
    return _beginTime;
}

-(HMTiming *)endTimer
{
    HMTiming *timing = [self timingWithShowIndex:2];
    return timing;
}
-(NSString *)endTime
{
    if (!_endTime) {
        HMTiming *timing = [self endTimer];
        if (timing) {
            _endTime = [NSString stringWithFormat:@"%02d:%02d",timing.hour,timing.minute];
        }
    }
    return _endTime;
}

                       
-(HMTiming *)timingWithShowIndex:(int)showIndex
{
    HMTiming *timing = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from timing where timingGroupId = '%@' and showIndex = %d",self.timingGroupId,showIndex];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        timing = [HMTiming object:rs];
    }
    [rs close];
    
    return timing;
    
}

+ (NSMutableArray *)allModels:(HMDevice *)device
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from timingGroup where deviceId = '%@' and delFlag = 0",device.deviceId];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMTimingGroupModel *timingGroup = [HMTimingGroupModel object:rs];
        [array addObject:timingGroup];
    }
    [rs close];
    
    NSSortDescriptor *sortBeginTime = [[NSSortDescriptor alloc]initWithKey:@"beginTime" ascending:YES];
    NSSortDescriptor *sortEndTime = [[NSSortDescriptor alloc]initWithKey:@"endTime" ascending:YES];
    [array sortUsingDescriptors:@[sortBeginTime,sortEndTime]];
    
    return array;
}

+ (instancetype)activeModel:(HMDevice *)device
{
    HMTimingGroupModel *timingGroup = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from timingGroup where deviceId = '%@' and delFlag = 0 and isPause = 1",device.deviceId];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        timingGroup = [HMTimingGroupModel object:rs];
    }
    [rs close];
    
    return timingGroup;
}
- (void)active:(int)active
{
//    // 当前模式激活
//    if (active == 1) {
//        // 因模式互斥，所以要关掉其他的模式
//        NSString *updateOtherTimingSql  = [NSString stringWithFormat:@"update timingGroup set isPause = %d where deviceId = '%@' and timingGroupId in (select timingGroupId from timingGroup where delFlag = 0 and deviceId = '%@' and timingGroupId != '%@')"
//,!active,self.deviceId,self.deviceId,self.timingGroupId];
//        updateInsertDatabase(updateOtherTimingSql);
//
//        // 关掉其他模式对应的定时
//        NSString *updateTimingGroupSql  = [NSString stringWithFormat:@"update timing set isPause = %d where deviceId = '%@' and timingGroupId in (select timingGroupId from timingGroup where delFlag = 0 and deviceId = '%@' and timingGroupId != '%@')",!active,self.deviceId,self.deviceId,self.timingGroupId];
//        updateInsertDatabase(updateTimingGroupSql);
//    }
    
    
    // 激活当前模式
    NSString *updateTimingSql  = [NSString stringWithFormat:@"update timingGroup set isPause = %d where timingGroupId = '%@'",active,self.timingGroupId];
    updateInsertDatabase(updateTimingSql);
    
    
    // 激活对应的定时
    NSString *updateTimingGroupSql  = [NSString stringWithFormat:@"update timing set isPause = %d where timingGroupId = '%@'",active,self.timingGroupId];
    updateInsertDatabase(updateTimingGroupSql);
}

- (id)copyWithZone:(NSZone *)zone
{
    HMTimingGroupModel *object = [[HMTimingGroupModel alloc]init];
    
    object.timingGroupId = self.timingGroupId;
    object.uid = self.uid;
    object.deviceId = self.deviceId;
    object.name = self.name;
    object.isPause = self.isPause;
    object.beginTime = self.beginTime;
    object.endTime = self.endTime;
    object.week = self.week;
    [object copyInitialValue];
    return object;
}

+ (instancetype)object:(FMResultSet *)rs
{
    HMTimingGroupModel *obj = [super object:rs];
    obj.week = obj.beginTimer.week;
    [obj copyInitialValue];
    return obj;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMTimingGroupModel *obj = [super objectFromDictionary:dict];
    obj.week = obj.beginTimer.week;
    [obj copyInitialValue];
    return obj;
}
-(void)copyInitialValue
{
    self.initialName = self.name;
    self.initialIsPause = self.isPause;
    self.initialWeek = self.week;
    self.initialBeginTime = self.beginTime;
    self.initialEndTime = self.endTime;
}

-(BOOL)isChanged
{
    return self.isNameChanged || self.isTimingChanged || self.isBeginTimeChanged || self.isEndTimeChanged;
}

-(BOOL)isNameChanged
{
    // 模式名称变化
    return (![self.initialName isEqualToString:self.name]);
}

-(BOOL)isBeginTimeChanged
{
    // 开始时间变化
    return (![self.initialBeginTime isEqualToString:self.beginTime]);
}

-(BOOL)isEndTimeChanged
{
    // 结束时间变化
    return (![self.initialEndTime isEqualToString:self.endTime]);
}

-(BOOL)isTimingChanged
{
    if ((self.initialIsPause != self.isPause)                        // 激活状态变化
        || (self.initialWeek != self.week)) {                           // 周期发生变化
        
        return YES;
    }
    return NO;
}

-(BOOL)isConflict
{
    // 开启
    //if (self.isPause == 0) {
        
        if ([self isTimingConflict:self.beginTime]) {
            
            DLog(@"开始时间与已有定时冲突");
            
            return YES;
        }
        if ([self isTimingConflict:self.endTime]) {
            
            DLog(@"结束时间与已有定时冲突");
            
            return YES;
        }
    //}
    
    return NO;
}

-(BOOL)isTimingConflict:(NSString *)theTiming
{
    NSArray *timingArray = [theTiming componentsSeparatedByString:@":"];
    
    int minute = [[timingArray lastObject]intValue];
    int hour = [[timingArray firstObject]intValue];
    
    HMTiming *timing = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from timing where deviceId = '%@' and delFlag = 0 and isPause = 1 and (showIndex == 0 or showIndex == -1) and minute = %d and hour = %d",self.deviceId,minute,hour];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        timing = [HMTiming object:rs];
    }
    [rs close];
    
    // 查询到冲突的定时
    if (timing) {
        return YES;
    }
    
    return NO;
}
@end
