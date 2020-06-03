//
//  HMGroupMember.m
//  HomeMate
//
//  Created by liqiang on 16/11/14.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMGroupMember.h"
#import "HMConstant.h"

@implementation HMGroupMember

+(NSString *)tableName
{
    return @"groupMember";
}

+ (NSArray*)columns
{
    return @[
             column("groupMemberId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("groupId","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("uid","text")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (groupMemberId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (instancetype)deviceObject:(FMResultSet *)rs
{
    HMGroupMember * object = [[HMGroupMember alloc] init];
    
    [object setBindProperty:rs];
    
    return object;
}
+ (instancetype)bindObject:(FMResultSet *)rs {
    HMGroupMember * object = [[HMGroupMember alloc] init];
    
    [object setBindProperty:rs];
    
    return object;
}
-(void)setBindProperty:(FMResultSet *)rs
{
    self.deviceId = [rs stringForColumn:@"deviceId"];
    self.deviceName = [rs stringForColumn:@"deviceName"];
    self.deviceType = [rs intForColumn:@"deviceType"];
    self.subDeviceType = [rs intForColumn:@"subDeviceType"];
    self.roomId = [rs stringForColumn:@"roomId"];

    self.floorRoom = floorAndRoom([HMDevice objectWithDeviceId:self.deviceId uid:self.uid]);

    self.selected = NO;
    
}
- (BOOL)changed {
    return NO;
}
- (BOOL)isLearnedIR {
    return YES;
}
+ (NSArray <HMGroupMember *>*)groupMembers:(NSString *)groupId {
    NSString * sql = [NSString stringWithFormat:@"select * from groupMember where groupId = '%@' and delFlag = 0",groupId];
    NSMutableArray * array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMGroupMember * groupMember = [HMGroupMember object:rs];
        [array addObject:groupMember];
    });
    return array;
}
+ (NSArray <HMDeviceStatus *> *)groupMemberStatusForGroupId:(NSString *)groupId {
    NSMutableArray * devices = [NSMutableArray array];

    NSString * sql = [NSString stringWithFormat:@"select * from deviceStatus where deviceId in (select deviceId from groupMember where groupId = '%@' and delFlag = 0) and delFlag = 0 and deviceId in (select deviceId from device where uid in %@ and delFlag = 0)",groupId,[HMUserGatewayBind uidStatement]];
    
    if(!userAccout().isAdministrator) {
        sql = [NSString stringWithFormat:@"select * from deviceStatus where deviceId in (select deviceId from groupMember where groupId = '%@' and delFlag = 0) and delFlag = 0",groupId];
    }
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDeviceStatus * deviceStatus = [HMDeviceStatus object:rs];
        [devices addObject:deviceStatus];
    });
    //这里是为了将主机离线的设备统计为离线
    if (devices.count) {
        NSSet * array = [NSSet setWithArray:[devices valueForKey:@"uid"]];
        NSArray * hubOnlineArray = [HMHubOnlineModel hubOnlineModelWithUids:[array allObjects]];
        NSArray * offLineArray = [hubOnlineArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"online = NO"]];
        if (offLineArray.count) {
            NSArray * offLineUidArray = [offLineArray valueForKey:@"uid"];
            if (offLineUidArray.count) {
                NSPredicate * pre = [NSPredicate predicateWithFormat:@"uid in %@",offLineUidArray];
                NSArray * offLineStatus = [devices filteredArrayUsingPredicate:pre];
                if (offLineStatus.count) {
                    for (HMDeviceStatus * status in offLineStatus) {
                        status.online = NO;
                    }
                }
            }
        }
    }
    
    return devices;
}

// device widget 使用
+ (NSArray <NSMutableDictionary *> *)groupMemberStatusDictWithGroupId:(NSString *)groupId {
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    NSString * sql = [NSString stringWithFormat:@"select * from deviceStatus where deviceId in (select deviceId from groupMember where groupId = '%@' and delFlag = 0) and delFlag = 0",groupId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        [array addObject:[@{@"deviceId":[rs stringForColumn:@"deviceId"]?:@"ExceptionDeviceId"
                            ,@"uid":[rs stringForColumn:@"uid"]?:@"ExceptionUid"
                            ,@"value1":[rs stringForColumn:@"value1"]?:@(1)
                            ,@"online":[rs objectForColumn:@"online"]?:@(1)} mutableCopy]];
    });
    
    return array;
}

+ (BOOL)deleteGroupMemberGroupId:(NSString *)groupId uids:(NSArray *)uids {
    
    NSString * sql = [NSString stringWithFormat:@"delete from groupMember where groupId = '%@' and uid in (%@)",groupId,stringWithObjectArray(uids)];
    
    BOOL result = [self executeUpdate:sql];
    
    return result;
    
}

@end
