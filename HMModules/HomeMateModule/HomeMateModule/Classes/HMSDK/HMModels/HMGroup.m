//
//  HMGroup.m
//  HomeMate
//
//  Created by liqiang on 16/11/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMGroup.h"
#import "HMDevice.h"
#import "HMBaseModel+Extension.h"
#import "HMConstant.h"

@implementation HMGroup

+(NSString *)tableName
{
    return @"deviceGroup";
}

+ (NSArray*)columns
{
    return @[
             column("groupId","text"),
             column("groupName","text"),
             column("userId","text"),
             column("familyId","text"),
             column("roomId","text"),
             column("pic","text"),
             column("groupNo","integer"),
             column("groupType","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}
+ (BOOL)createTrigger {
    
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_group"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_group BEFORE DELETE ON deviceGroup for each row"
                   " BEGIN "
                   
                   "DELETE FROM groupMember where groupId = old.groupId;"
                   
                   "END"];
    
    return result;
}
+ (NSString*)constrains
{
    return @"UNIQUE (groupId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

/// 设备组成员的数量
/// @param device 设备组转成的device对象
+ (int)groupMemberCountForGroup:(HMDevice *)device {
    __block int count = 0;
    
    NSString * sql = [NSString stringWithFormat: @"select count() as count from groupMember where groupId = '%@' and deviceId in (select deviceId from device where uid in %@ and delFlag = 0)  and delFlag = 0",device.deviceId,[HMUserGatewayBind uidStatement]];
    if (!userAccout().isAdministrator) {
        sql = [NSString stringWithFormat: @"select count() as count from groupMember where groupId = '%@' and delFlag = 0",device.deviceId];
    }
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    
    return count;
    
}


/// 家庭下面所有组
+ (NSArray <HMDevice *>*)allGroups {
    
//    NSArray * allRooms = [HMRoom selectAllRoom];
    
//    NSString * sql = @"select * from deviceGroup order by case groupType \
                                                        when 1 then 0  \
                                                        when 2 then 1  \
                                                        when 3 then 2  \
                                                        when 4 then 3  \
                                                        when 5 then 4  \
                                                        when 6 then 5  \
                                                        ";
    
    NSMutableArray * groups = [NSMutableArray  array];
    
    NSString * sql = [NSString stringWithFormat:@"select * from deviceGroup where familyId = '%@' and delFlag = 0 order by createTime desc",userAccout().familyId];

    FMResultSet * set = [self executeQuery:sql];
    while ([set next]) {
        HMGroup * group = [HMGroup object:set];
        HMDevice * device = [HMGroup deviceFromGroup:group];
        if(device){
          [groups addObject:device];
        }
        
    }
    [set close];
    
    return groups;
}

/// 根据groupId查组,并转成device对象
/// @param group
+ (HMDevice *)deviceFromGroupId:(NSString *)groupId {
    NSString * sql = [NSString stringWithFormat:@"select * from deviceGroup where familyId = '%@' and groupId = '%@' and delFlag = 0 order by createTime desc",userAccout().familyId,groupId];
    
    FMResultSet * set = [self executeQuery:sql];
    if([set next]) {
       HMGroup * group = [HMGroup object:set];
       HMDevice * device = [HMGroup deviceFromGroup:group];
       if(device){
           [set close];
           return device;
       }
    }
    [set close];
    return nil;
}

/// 为了方便处理，这个查出来的组转化成device对象
+ (NSArray <HMDevice *>*)groupsInDefaultRoomId:(NSString *)roomId {
    
    NSString *sql = [NSString stringWithFormat:@"select * from deviceGroup where \
     (length(roomId) < 32 or roomId is null or roomId not in (select roomId from room where familyId = '%@' and delFlag = 0) or roomId in (select roomId from room where roomType = -1 and delFlag = 0 and familyId = '%@'))  and delFlag = 0 and familyId = '%@' order by createTime desc",userAccout().familyId,userAccout().familyId,userAccout().familyId];
    NSMutableArray * groups = [NSMutableArray  array];
    FMResultSet * set = [self executeQuery:sql];
       while ([set next]) {
           HMGroup * group = [HMGroup object:set];
           HMDevice * device = [HMGroup deviceFromGroup:group];
           if(device){
             [groups addObject:device];
           }
       }
       [set close];
       
       return groups;
}

/// 为了方便处理，这个查出来的组转化成device对象
+ (NSArray <HMDevice *>*)groupsInRoomId:(NSString *)roomId {
    
    NSMutableArray * groups = [NSMutableArray  array];
    
    NSString * sql = [NSString stringWithFormat:@"select * from deviceGroup where familyId = '%@' and roomId = '%@' and delFlag = 0 order by createTime desc",userAccout().familyId,roomId];

    FMResultSet * set = [self executeQuery:sql];
    while ([set next]) {
        HMGroup * group = [HMGroup object:set];
        HMDevice * device = [HMGroup deviceFromGroup:group];
        if(device){
          [groups addObject:device];
        }
        
    }
    [set close];
    
    return groups;
}

+ (HMDevice *)deviceFromGroup:(HMGroup *)group {
    HMDevice * device = [[HMDevice alloc] init];
    device.deviceId = group.groupId;
    device.deviceName = group.groupName;
    device.roomId = group.roomId;
    device.deviceType = KDeviceTypeDeviceGroup;
    device.subDeviceType = group.groupType;
    return device;
}

+ (BOOL)updateGroupDevice:(HMDevice *)device {
    
    HMGroup * group = [[HMGroup alloc] init];
    group.groupId = device.deviceId;
    group.groupName = device.deviceName;
    group.roomId = device.roomId;
    group.groupType = device.subDeviceType;
    group.userId = userAccout().userId;
    group.familyId = userAccout().familyId;
    return [group insertObject];
    
}

/// 将组对象转为device对象
/// @param group
+ (HMGroup *)groupFromDevice:(HMDevice *)device {
    HMGroup * group = [[HMGroup alloc] init];
    group.groupId = device.deviceId;
    group.groupName = device.deviceName;
    group.roomId = device.roomId;
    group.groupType = device.subDeviceType;
    group.userId = userAccout().userId;
    group.familyId = userAccout().familyId;
    return group;
}

+ (BOOL)deleteGroupDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from deviceGroup where familyId = '%@'  and groupId = '%@'",userAccout().familyId,device.deviceId];

     BOOL result = [self executeUpdate:sql];
    
    return result;
}

@end
