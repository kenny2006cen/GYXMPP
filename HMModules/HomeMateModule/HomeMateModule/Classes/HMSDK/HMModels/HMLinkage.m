//
//  VihomeLinkage.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLinkage.h"

#import "HMConstant.h"
#import "HMLinkageExtModel.h"
#import "HMDatabaseManager.h"


@interface HMLinkage ()

/**
 *  1 表示小方的场景，2表示其它场景
 */
@property (nonatomic, assign)int magicCubeLinkageFlag;

@end

@implementation HMLinkage

+ (NSString *)tableName {
    
    return @"linkage";
}

+ (NSArray *)columns {
    
    return @[column("linkageId", "text"),
             column("familyId", "text"),
             column("linkageName", "text"),
             column("isPause", "integer"),
             column("conditionRelation", "text"),
             column("createTime", "text"),
             column("updateTime", "text"),
             column("delFlag", "integer"),
             column("userId", "text"),
             column("uid", "text"),
             column("type", "integer"),
             column("mode", "integer"),
             ];
}
+ (NSArray<NSDictionary *> *)newColumns {
    return @[column("userId", "text default ''"),
             column("uid", "text default ''"),
             column("type", "integer default 0"),
             column("mode", "integer default 0")
             ];
}
+ (NSString *)constrains {
    
    return @"UNIQUE (linkageId) ON CONFLICT REPLACE";
}


+ (BOOL)createTrigger {
    
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_linkage"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_linkage BEFORE DELETE ON linkage for each row"
                   " BEGIN "
                   // 场景排序表 linkageExt
//                   "DELETE FROM linkageExt where linkageId = old.linkageId;"  // 不删掉排序
                   "DELETE FROM linkageCondition where linkageId = old.linkageId;"
                   "DELETE FROM linkageOutput where linkageId = old.linkageId;"
                   
                   "END"];
    
    return result;
}

- (void)prepareStatement {
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

- (void)setInsertWithDb:(FMDatabase *)db {
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    // 删除联动表
    NSString * deleLinkageSql = [NSString stringWithFormat:@"delete from linkage where linkageId = '%@'",self.linkageId];
    BOOL result = [self executeUpdate:deleLinkageSql];
    
    // 删除联动条件表
    NSString * deleLinkageConditionSql = [NSString stringWithFormat:@"delete from linkageCondition where linkageId = '%@'",self.linkageId];
    result = [self executeUpdate:deleLinkageConditionSql];
    
    // 删除output表
    NSString * deleLinkageOutputSql = [NSString stringWithFormat:@"delete from linkageOutput where linkageId = '%@'",self.linkageId];
    result = [self executeUpdate:deleLinkageOutputSql];
    
    
    return result;
}

+ (void)deleteSecurityWithDeviceId:(NSString *)deviceId {
   
    DLog(@"deleteSecurityWithDeviceId: %@",deviceId);
    
    NSString *selectSql = [NSString stringWithFormat:@"select linkageId from linkageCondition where deviceId = '%@' and linkageType = 0",deviceId];
    __block NSMutableArray *linkageIdArr;
    queryDatabase(selectSql, ^(FMResultSet *rs) {
        if (!linkageIdArr) {
            linkageIdArr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        NSString *linkageId = [rs stringForColumn:@"linkageId"];
        [linkageIdArr addObject:linkageId];
    });
    for (NSString *liId in linkageIdArr) {
        
        // 删除联动条件表
        NSString * deleLinkageConditionSql = [NSString stringWithFormat:@"delete from linkageCondition where linkageId = '%@' and deviceId = '%@'",liId,deviceId];
     __unused  BOOL result = [self executeUpdate:deleLinkageConditionSql];
        
    }

}

+ (void)deleteLinkageWithDeviceId:(NSString *)deviceId
{
    if (!deviceId || [deviceId isEqualToString:@""]){
        DLog(@"deleteLinkageWithDeviceId: %@",deviceId);
        return;
    }
    
    DLog(@"deleteLinkageWithDeviceId: %@",deviceId);
    
    __block NSMutableArray *linkageIdArr;
    NSString *selectSql = [NSString stringWithFormat:@"select linkageId from linkageCondition where deviceId = '%@' and linkageType = 0",deviceId];
    queryDatabase(selectSql, ^(FMResultSet *rs) {
        if (!linkageIdArr) {
            linkageIdArr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        NSString *linkageId = [rs stringForColumn:@"linkageId"];
        [linkageIdArr addObject:linkageId];
    });
    for (NSString *linkageId in linkageIdArr) {
        
        /** 需求变更：删除作为联动条件的设备时，联动不删除。修复bug：HM-3935*/
        // 删除联动表
        //NSString * deleLinkageSql = [NSString stringWithFormat:@"delete from linkage where linkageId = '%@' and familyId = '%@'",linkageId,userAccout().familyId];
        //BOOL result = [self executeUpdate:deleLinkageSql];
        // 删除 排序表
        //[HMLinkageExtModel deleteObjectWithLinkageId:linkageId];
        
        // 删除联动条件表
        NSString * deleLinkageConditionSql = [NSString stringWithFormat:@"delete from linkageCondition where linkageId = '%@'",linkageId];
        [self executeUpdate:deleLinkageConditionSql];
        
        // 删除output表
        NSString * deleLinkageOutputSql = [NSString stringWithFormat:@"delete from linkageOutput where linkageId = '%@'",linkageId];
        [self executeUpdate:deleLinkageOutputSql];

        
    }
}

+ (void)deleteLinkageWithLinkageId:(NSString *)linkageId {
    
    DLog(@"deleteLinkageWithLinkageId:%@",linkageId);
    
    if (!linkageId || [linkageId isEqualToString:@""]) return;

    // 删除联动表
    NSString * deleLinkageSql = [NSString stringWithFormat:@"delete from linkage where linkageId = '%@' and familyId = '%@'",linkageId,userAccout().familyId];
    BOOL result = [self executeUpdate:deleLinkageSql];

    // 删除联动条件表
    NSString * deleLinkageConditionSql = [NSString stringWithFormat:@"delete from linkageCondition where linkageId = '%@'",linkageId];
    result = [self executeUpdate:deleLinkageConditionSql];

    // 删除output表
    NSString * deleLinkageOutputSql = [NSString stringWithFormat:@"delete from linkageOutput where linkageId = '%@'",linkageId];
    result = [self executeUpdate:deleLinkageOutputSql];

    // 删除 排序表
    [HMLinkageExtModel deleteObjectWithLinkageId:linkageId];

}

- (id)copyWithZone:(NSZone *)zone
{
    HMLinkage *copySelf = [[HMLinkage alloc]init];
    copySelf.linkageId = self.linkageId;
    copySelf.linkageName = self.linkageName;
    copySelf.isPause = self.isPause;
    copySelf.conditionRelation = self.conditionRelation;

    return copySelf;
}
- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+ (NSArray *)allLinkagesArr {

    __block NSMutableArray *linkageArray;
    
    // 2.4 新需求，允许有空条件的联动存在
    NSString *sql = [NSString stringWithFormat:@"select * from linkage where delFlag = 0 and familyId = '%@' and (type = %ld or type is NULL) and length(linkageName) > 0 order by createTime asc",userAccout().familyId,(long)HMLinakgeTypeCommon];

    __block NSInteger sequence = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!linkageArray) {
            linkageArray = [[NSMutableArray alloc] init];
        }
        HMLinkage *linkage = [HMLinkage object:rs];
        NSArray * conditionArray = [HMLinkageCondition linkageConditionExcepCycletWithlinkageId:linkage.linkageId];
        if (conditionArray.count == 0) {//如果没有关于设备或定时的联动显示
            [linkageArray addObject:linkage];
        }else {
            for (HMLinkageCondition * condition in conditionArray) {
                if (condition.linkageType == 4 || condition.linkageType == 5 || condition.linkageType == 6 || condition.linkageType == 10) {// //如果没有关于定时/EP停车的联动显示
                    [linkageArray addObject:linkage];
                    break;
                }else {// 这里是关于设备的，要判断是不是存在
                    HMDevice * device = [HMDevice objectWithDeviceId:condition.deviceId uid:nil];
                    if (device) {
                        [linkageArray addObject:linkage];
                        break;
                    }
                }
            }
        }
        
//        [self setDefaultSequenceWithLinkageId:linkage.linkageId sequence:sequence];
        sequence ++;
    });
    return linkageArray;
}


///**
// 设置默认的排序 ，默认为 0
// */
//+ (void)setDefaultSequenceWithLinkageId:(NSString *)linkageId sequence:(NSInteger)sequence {
//
//    if (![HMLinkageExtModel objectWithLinakgeId:linkageId]) {
//        HMLinkageExtModel *linkageExt = [[HMLinkageExtModel alloc] init];
//        linkageExt.linkageId = linkageId;
//        linkageExt.sequence = (int)sequence;
//        [linkageExt updateObject];
//    }
//}

+ (NSInteger)getLinageConditionCountWithLinakgeId:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"select count() as count from linkageCondition where linkageId = '%@'", linkageId];
    __block int linkageConditionCount;
    queryDatabase(sql, ^(FMResultSet *rs) {
        linkageConditionCount = [rs intForColumn:@"count"];
    });
    return linkageConditionCount;
}


+ (BOOL)isAlloneLinkage:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"SELECT * from device where deviceId = (select deviceId from linkageCondition where linkageType = 3 and delFlag = 0 and linkageId = '%@' limit 1)",linkageId];

    __block BOOL isAlloneLinkage = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        KDeviceType deviceType = [rs intForColumn:@"deviceType"];
        if (deviceType == KDeviceTypeAllone) {
            isAlloneLinkage = YES;
        }
    });
    return isAlloneLinkage;
}

+ (HMLinkage *)objectWithLinkageId:(NSString *)linkageId {

    NSString *sql = [NSString stringWithFormat:@"select * from linkage where linkageId = '%@'",linkageId];
    __block HMLinkage *linkage = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        linkage = [HMLinkage object:rs];
    });
    return linkage;
}

@end
