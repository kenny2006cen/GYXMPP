//
//  HMKKIr.m
//  HomeMate
//
//  Created by orvibo on 16/4/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMKKIr.h"

@implementation HMKKIr

+ (NSString *)tableName
{
    return @"kkIr";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("kkIrId","text","primary key asc on conflict replace"),
             column("uid","text"),
             column("deviceId","text"),
             column("rid","integer"),
             column("fid","integer"),
             column("fKey","text"),
             column("fName","text"),
             column("sCode","text"),
             column("dCode","text"),
             column("format","integer"),
             column("pluse","text"),
             column("freq","integer"),
             column("keyType","integer"),
             column("bindDeviceId","text"),
             column("sequence","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}


+ (instancetype)object:(FMResultSet *)rs
{
    HMKKIr *kkir = [super object:rs];
    kkir.temporarySequence = kkir.sequence;
    return kkir;
}
-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (BOOL)deleteObjectWithKKIrId:(NSString *)kkIrId
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from kkIr where kkIrId = '%@'",kkIrId];
    BOOL result = [self executeUpdate:deleteSql];
    return result;
}

+ (BOOL)deletePluseWithKKIrId:(NSString *)kkIrId
{
    NSString *updateSql = [NSString stringWithFormat:@"update kkIr set pluse = '' where kkIrId = '%@'",kkIrId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

-(id)copyWithZone:(NSZone *)zone
{
    HMKKIr *kkIr = [[HMKKIr alloc] init];
    kkIr.kkIrId = self.kkIrId;
    kkIr.rid = self.rid;
    kkIr.fid = self.fid;
    kkIr.fKey = self.fKey;
    kkIr.fName = self.fName;
    kkIr.sCode = self.sCode;
    kkIr.dCode = self.dCode;
    kkIr.format = self.format;
    kkIr.pluse = self.pluse;
    kkIr.createTime = self.createTime;
    kkIr.updateTime = self.updateTime;
    kkIr.delFlag = self.delFlag;
    kkIr.freq = self.freq;
    kkIr.deviceId = self.deviceId;
    kkIr.sequence = self.sequence;
    kkIr.temporarySequence = self.temporarySequence;
    
    return kkIr;
}

+ (NSArray *)irArrayWithDeviceId:(NSString *)deviceId
{
    __block NSMutableArray *irArray;
    NSString *sql = [NSString stringWithFormat:@"select * from kkIr where deviceId = '%@' and delFlag = 0 order by sequence asc",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!irArray) {
            irArray = [[NSMutableArray alloc] init];
        }
        HMKKIr *obj = [HMKKIr object:rs];
        [irArray addObject:obj];
    });
    return irArray;
}

+ (HMDevice *)bindDeviceWithDeviceId:(NSString *)deviceId uid:(NSString *)uid fid:(int)fid
{
    HMKKIr *tempKKIr = [self bindKKIrWithDeviceId:deviceId fid:fid];
    HMDevice *tempDevice;
    if (tempKKIr) {
        HMDevice *device = [HMDevice objectWithDeviceId:tempKKIr.bindDeviceId uid:nil];
        tempDevice = device;
    }
    return tempDevice;
}

+ (HMKKIr *)bindKKIrWithDeviceId:(NSString *)deviceId fid:(int)fid
{
    NSString *sql = [NSString stringWithFormat:@"select * from kkIr where deviceId = '%@' and keyType = 1 and fid = %d and delFlag = 0",deviceId, fid];
    __block HMKKIr *kkIr;
    queryDatabase(sql, ^(FMResultSet *rs) {
        kkIr = [HMKKIr object:rs];
    });
    return kkIr;
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId rid:(int)rid fid:(int)fid
{
    NSString *sql = [NSString stringWithFormat:@"select * from kkIr where deviceId = '%@' and keyType = 0 and fid = %d and rid = %d and delFlag = 0",deviceId, fid, rid];
    __block HMKKIr *kkIr;
    queryDatabase(sql, ^(FMResultSet *rs) {
        kkIr = [HMKKIr object:rs];
    });
    return kkIr;
}


+ (BOOL)updatefNameAndKeyName:(NSString *)name kkIrId:(NSString *)kkIrId
{
    NSString *sql = [NSString stringWithFormat:@"update kkIr set fKey = '%@', fName = '%@' where kkIrId = '%@'",name, name, kkIrId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"delete from kkIr where deviceId = '%@' or bindDeviceId = '%@'",deviceId, deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
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





