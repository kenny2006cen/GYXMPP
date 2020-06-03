//
//  VihomeFloor.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFloor.h"

#import "HMConstant.h"
#import "HMTypes.h"

@implementation HMFloor
+(NSString *)tableName
{
    return @"floor";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("floorId","text","UNIQUE ON CONFLICT REPLACE"),
             column("familyId","text"),
             column("floorName","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}


+ (BOOL)createTrigger {
    
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_floor"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_floor BEFORE DELETE ON floor for each row"
                   " BEGIN "
                   
                   // 更新设备表房间信息，将房间里面的所有设备房间信息置空
                   "UPDATE device set roomId = '' where delFlag = 0 and roomId in (select roomId from room where floorId = old.floorId and delFlag = 0);"
                   
                   // room房间表
                   "DELETE FROM room where floorId = old.floorId;"
                   
                   "END"];
    
    return result;
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
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
    // 删除楼层
    NSString * deleteFloorSql = [NSString stringWithFormat:@"delete from floor where floorId = '%@' and delFlag = 0",self.floorId];
    BOOL result = [self executeUpdate:deleteFloorSql];
    
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+(void)saveFloorAndRoom:(NSDictionary *)dic
{
    // 保存楼层
    NSArray *floorArray = [dic objectForKey:@"floorList"];
    for (NSDictionary *floorDic in floorArray) {
        
        HMFloor * object = [HMFloor objectFromDictionary:floorDic];
        [object insertObject];
        
        // 保存房间
        NSArray *roomArray  = [floorDic objectForKey:@"roomList"];
        for (NSDictionary *roomDic in roomArray) {
            
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:roomDic];
            HMRoom *room = [HMRoom objectFromDictionary:newDic];
            [room insertObject];
        }
    }
}

+ (instancetype)objectFromUID:(NSString *)UID recordID:(NSString *)recordID
{
    NSString * selectSQL = [NSString stringWithFormat:@"select * from floor where floorId = '%@' and familyId = '%@'",recordID,userAccout().familyId];
    FMResultSet * sets = [self executeQuery:selectSQL];
    while ([sets next]) {
        
        HMFloor *fllor = [[self class] object:sets];
        
        [sets close];
        return fllor;
    }
    [sets close];
    return nil;
}

+ (NSMutableArray *)selectAllFloor{
    NSMutableArray *arr = [NSMutableArray new];

    NSString * selectSQL = [NSString stringWithFormat:@"select * from floor where familyId = '%@' and delFlag = 0 order by createTime asc",userAccout().familyId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        HMFloor *floor = [HMFloor object:rs];
        [arr addObject:floor];
    });
    
    arr = [[self class] reOrderTheFloorArr:arr];
    
    return arr;
}

+ (NSMutableArray <HMFloor *>*)selectAllFloorWithFamilyId:(NSString *)familyId {
    NSMutableArray *arr = [NSMutableArray new];
    
    NSString * selectSQL = [NSString stringWithFormat:@"select * from floor where familyId = '%@' and delFlag = 0 order by createTime asc",familyId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
        HMFloor *floor = [HMFloor object:rs];
        [arr addObject:floor];
    });
    
    arr = [[self class] reOrderTheFloorArr:arr];
    
    return arr;
}

+ (NSMutableArray *)reOrderTheFloorArr:(NSMutableArray *)arr{
    
    for (NSInteger i=0;i<arr.count;i++) {
        HMFloor *floor = arr[i];
        HMFloorOrderModel *orderModel = [HMFloorOrderModel readObjectByFloorId:floor.floorId AndIndex:i+1];
        floor.index = orderModel.sequence;
        
    }
    if (arr.count < 2) {
        return arr;
    }
    for (NSInteger i=0; i<arr.count-1; i++) {
        for (NSInteger j=i+1; j<arr.count; j++) {
            HMFloor *floor1 = arr[i];
            HMFloor *floor2 = arr[j];
            if (floor1.index>floor2.index) {
                [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    return arr;
}


+(HMFloor *)selectFloorByFloorId:(NSString *)floorId{
    __block HMFloor *floor;
    NSString * selectSQL = [NSString stringWithFormat:@"select * from floor where floorId = '%@' and delFlag = 0",floorId];
    queryDatabase(selectSQL, ^(FMResultSet *rs) {
    floor = [HMFloor object:rs];
    });
    return floor;
}

+(BOOL)deleteAllFloorsOfFamilyId:(NSString *)familyId {
    NSString *sql = [NSString stringWithFormat:@"delete from floor where familyId = '%@'",familyId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


-(NSString *)description{
    return [NSString stringWithFormat:@"floorId = %@,floorName = %@",self.floorId,self.floorName];
}
@end
