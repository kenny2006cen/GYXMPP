//
//  VihomeRoom.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMRoom.h"
#import "HMConstant.h"

@implementation HMRoom
+(NSString *)tableName
{
    return @"room";
}

+ (NSArray*)columns
{
    return @[
             
             column_constrains("roomId","text","UNIQUE ON CONFLICT REPLACE"),
             column("familyId","text"),
             column("roomName","text"),
             column("floorId","text"),
             column("roomType","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}


+ (BOOL)createTrigger {
    
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_room"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_room BEFORE DELETE ON room for each row"
                   " BEGIN "
                   
                   // 更新设备表房间信息，将房间里面的所有设备房间信息置空
                   "UPDATE device set roomId = '' where delFlag = 0 and roomId = old.roomId;"
                   
                   "END"];
    
    return result;
}

- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from room where roomId = '%@'",self.roomId];
    return [self executeUpdate:sql];
}


- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+ (instancetype)objectWithRecordId:(NSString *)recordID
{
    NSString * selectSQL = [NSString stringWithFormat:@"select * from room where roomId = '%@' and delFlag = 0",recordID];
    FMResultSet * sets = [self executeQuery:selectSQL];
    while ([sets next]) {
        
        HMRoom *room = [[self class] object:sets];
        [sets close];
        return room;
    }
    [sets close];
    return nil;
}

+ (HMRoom *)objectWithRoomId:(NSString *)recordID {
    
    if (!recordID.length
        || [recordID isEqualToString:@""]
        || [recordID isEqualToString:@"0"]) { // 传入是空值，则当做默认房间
        return [HMRoom defaultRoom];
    }else{
        
        HMRoom *room = [self objectWithRecordId:recordID];
        if (room) {
            return room;
        }else{
            return [HMRoom defaultRoom];
        }
    }
}

+ (NSString *)selectFloorIdByRoomId:(NSString *)recordID{
    __block NSString *floorId;
    NSString *roomId = [self objectWithRoomId:recordID].roomId;
    NSString * selectSQL = [NSString stringWithFormat:@"select floorId from room where roomId = '%@' and delFlag = 0",roomId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        floorId = [rs stringForColumn:@"floorId"];
    });
    return floorId;
}

+ (HMRoom *)defaultRoom
{
    __block HMRoom *room = nil;
    NSString * selectSQL = [NSString stringWithFormat:@"select * from room where roomtype = -1 and delFlag = 0 and familyId = '%@' and floorId in (select floorId From floor where familyId = '%@' and delFlag = 0)", userAccout().familyId, userAccout().familyId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        room = [HMRoom object:rs];
    });
    return room;
}
+ (NSString *)defaultRoomId {
    return [HMRoom defaultRoom].roomId;
}



- (id)copyWithZone:(NSZone *)zone
{
    HMRoom *object = [[HMRoom alloc]init];
    
    object.roomId = self.roomId;
    object.floorId = self.floorId;
    object.roomName = self.roomName;
    object.roomType = self.roomType;
    object.imgUrl = self.imgUrl;
    object.index = self.index;
    object.beSelected = self.beSelected;
    
    return object;
}

-(BOOL)hasDevice
{
    NSString * selectSQL = [NSString stringWithFormat:@"select count() as count from device where roomId = '%@' and delFlag = 0",self.roomId];
    FMResultSet * sets = [self executeQuery:selectSQL];
    while ([sets next]) {
        
        int count = [sets intForColumn:@"count"];
        
        [sets close];
        return count > 0;
    }
    [sets close];
    return NO;
}

-(BOOL)isValidRoom
{
    // 如果房间存在并且房间里面有设备，则认为这个房间有效
    HMRoom *room = [[self class]objectFromUID:self.uid recordID:self.roomId];
    if (room && room.hasDevice) {
        return YES;
    }
    return NO;
}

+ (NSArray *)selectAllRoom {
    NSMutableArray *arr = [NSMutableArray new];
    NSString * selectSQL = [NSString stringWithFormat:@"select * from room where floorId in (select floorId From floor where familyId = '%@' and delFlag = 0) and delFlag = 0 order by createTime asc",userAccout().familyId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        HMRoom *room = [HMRoom object:rs];
        [arr addObject:room];
    });
    return arr;
}

+(NSDictionary *)defaultRoomSequenceInfo
{
    // 与HMCommons中的定义顺序一致 key:value roomType:sequence
    return @{@"15":@(1),@"0":@(2),@"3":@(3),@"1":@(4),@"2":@(5),@"7":@(6),@"6":@(7),@"11":@(8),@"16":@(9),@"4":@(10),@"8":@(11),@"17":@(12),@"14":@(13)};
}

/**
 查询房间排序逻辑修改：
 
 1.如果是默认房间直接插入到sortedArray的首位
 
 2.非默认房间再区分本地是否有排序，分别添加到两个数组中
 
 3.如果有未排序的房间，则先按照预设顺序排序，再把未排序的房间添加到已排序的房间后面
 
 4.如果满足条件3，再按数组的索引顺序更新一次所有房间的顺序（因为新增的排序和旧的排序数字可能重复或者倒序）批量插入到数据库中
 */
+ (NSMutableArray *)selectAllRoomWithFloorId:(NSString *)floorId{
    NSMutableArray *sortedArray = [[NSMutableArray alloc]init];
    NSMutableArray *noSortedArray = [[NSMutableArray alloc]init];
    
    NSString * selectSQL = [NSString stringWithFormat:@"select room.*, roomExt.sequence, roomExt.imgUrl from room left join roomExt on room.roomId = roomExt.roomId where floorId = '%@' and delFlag = 0 order by sequence asc, createTime asc",floorId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        HMRoom *room = [HMRoom object:rs];
        // 1.处理imgUrl
        // 如果未设置过本地图片，则给一个默认值："0"，兼容旧逻辑
        if ([rs columnIsNull:@"imgUrl"]) {
            room.imgUrl = @"0";
        }
        // 2.处理sequence
        
        // 没有排序的房间
        if ([rs columnIsNull:@"sequence"]) {
            // 默认房间
            if (room.roomType == -1) {
                room.index = 0;
                [noSortedArray insertObject:room atIndex:0];
            }else{
                NSString *roomType = [NSString stringWithFormat:@"%d",room.roomType];
                room.index = [[self defaultRoomSequenceInfo][roomType]integerValue];
                [noSortedArray addObject:room];
            }
        }else{// 有排序的房间
            room.index = [rs intForColumn:@"sequence"];
            [sortedArray addObject:room];
        }
    });
    
    // 找出未排序的房间，并排序
    if (noSortedArray.count > 0) {
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        [noSortedArray sortUsingDescriptors:@[sort]];
        
        // 把未排序的房间附加到有顺序的房间后面
        [sortedArray addObjectsFromArray:noSortedArray];
        
        [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
            
            // 如果需要更新房间排序表的顺序，则统一更新一次
            for (NSInteger i = 0;i < sortedArray.count;i++) {
                HMRoom *room = sortedArray[i];
                HMRoomOrderModel *orderModel = [[HMRoomOrderModel alloc]init];
                orderModel.roomId = room.roomId;
                orderModel.sequence = i+1;
                orderModel.imgUrl = room.imgUrl;
                [objectArray addObject:orderModel];
            }
            
        } completion:^{}];
        
    }
    
    return sortedArray;
}


+ (NSInteger )selectRoomCountWithFloorId:(NSString *)floorId{
    __block NSInteger count;
    NSString * selectSQL = [NSString stringWithFormat:@"select count() as count from room where floorId = '%@' and delFlag = 0",floorId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return count;
}




+ (BOOL)isDefaultRoom:(NSString *)roomId {
    if (roomId.length < 32) {
        return YES;
    }
    HMRoom *room = [HMRoom objectWithRoomId:roomId];
    if (room.roomType == -1) {
        return YES;
    }
    return NO;
}

+ (BOOL)shouldShowDefaultRoom {
    
    // 默认房间只要修改过，就一直显示出来
    // 否则按原来的规则显示
    HMRoom *room = [HMRoom defaultRoom];
    if (room && (![room.createTime isEqualToString:room.updateTime])) {
        return YES;
    }
    NSString *familyId = userAccout().familyId;
    NSString *abnormalRoomSql = [NSString stringWithFormat:@"(length(roomId) < 32 or roomId is null or roomId not in (select roomId from room where familyId = '%@' and delFlag = 0) or roomId in (select roomId from room where roomType = -1 and delFlag = 0 and familyId = '%@'))", familyId, familyId];
    NSString *deviceCountSql = [NSString stringWithFormat:@"select count() as count from device where uid in %@ and delFlag = 0 and %@",[HMUserGatewayBind uidStatement],abnormalRoomSql];
    
    NSString *deviceGroupCountSql = [NSString stringWithFormat:@"select count() as count from deviceGroup where familyId = '%@' and delFlag = 0 and %@",familyId,abnormalRoomSql];
    
    // 只要满足两个条件之一，则返回yes。1：有设备在默认房间；2：家庭中没有其他房间
    __block BOOL inDefaultRoom = NO;
    // 家庭中是否有设备在默认房间
    NSString *sql1 = [NSString stringWithFormat:@"select (%@) + (%@) as count",deviceCountSql,deviceGroupCountSql];
    queryDatabase(sql1, ^(FMResultSet *rs) {
        if ([rs intForColumn:@"count"] > 0) {
            inDefaultRoom = YES;
        }
    });
    
    if (!inDefaultRoom) {
        // 家庭中是否有除默认房间外的其他房间
        NSString *sql = [NSString stringWithFormat:@"select count() as count from room where roomtype != -1 and delFlag = 0 and familyId = '%@' and floorId in (select floorId From floor where familyId = '%@' and delFlag = 0)",familyId, familyId];
        queryDatabase(sql, ^(FMResultSet *rs) {
            if ([rs intForColumn:@"count"] == 0) {
                inDefaultRoom = YES;
            }
        });
    }
    return inDefaultRoom;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"roomName=%@ roomType=%d sequence=%ld",self.roomName,self.roomType,(long)self.index];
}
@end
