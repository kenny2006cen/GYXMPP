//
//  HMFamily.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//


#import "HMFamily.h"
#import "HMConstant.h"


@implementation HMFamily

+ (NSString *)tableName {
    
    return @"family";
}

+ (NSArray*)columns
{
    return @[
             column("familyId","text"),
             column("familyName","text"),
             column("pic","text"),
             column("creator","text"),
             column("email","text"),
             column("phone","text"),
             column("userName","text"),
             column("userId","text"),
             column("showIndex","integer"),
             column("isAdmin","integer"),
             column("userType","integer"),
             column("familyType","integer default 0"),
             column("geofence","text"),
             column("position","text"),
             column("longitudeN","float"),
             column("latotideN","float"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer"),
             ];
}


+ (NSArray<NSDictionary *> *)newColumns {
    return @[
             column("familyType","integer default 0"),
             column("geofence","text"),
             column("position","text"),
             column("longitudeN","text"),
             column("latotideN","text"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (familyId,userId) ON CONFLICT REPLACE";
}



- (void)prepareStatement {
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.updateTime) {
        self.updateTime = @"-1";
    }
    if (!self.createTime) {
        self.createTime = @"-1";
    }
    if (!self.userId) {
        self.userId = userAccout().userId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from family where familyId = '%@' and userId = '%@'",self.familyId,self.userId];
    BOOL result = [self executeUpdate:sql];
    
    // 删除旧的familyExt数据
    executeUpdate([NSString stringWithFormat:@"delete from familyExt where familyId = '%@' and userId = '%@'",self.familyId,self.userId]);
    return result;
}

-(void)setFamilyName:(NSString *)familyName
{
    if (stringContainString(familyName, @"\n")) {
        _familyName = [familyName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }else{
        _familyName = familyName;
    }
}

+ (NSMutableArray *)familysWithUserId:(NSString *)userId;
{
    NSMutableArray *array = [NSMutableArray array];
    NSString * sql = [NSString stringWithFormat:@"select * from family where userId = '%@' and delFlag = 0 order by createTime asc",userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMFamily *family = [HMFamily object:rs];
        [array addObject:family];
    });
    return array;
}


+(BOOL)updateFamilyName:(NSString *)familyName byFamilyId:(NSString *)familyId
 {
    NSString *updateSql = [NSString stringWithFormat:@"update family set familyName = '%@' where familyId = '%@'", familyName ,familyId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}


+ (NSMutableArray *)readAllFamilys{
    
    return [HMFamilyExtModel readAllFamilys];
}

+ (HMFamily *)defaultFamily{
    
    return [HMFamilyExtModel defaultFamily];
}


+ (instancetype)familyWithId:(NSString *)familyId
{
    return [self familyWithFamilyId:familyId userId:userAccout().userId];
}

+ (instancetype)familyWithFamilyId:(NSString *)familyId userId:(NSString *)userId
{
    __block HMFamily *family = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from family where familyId = '%@' and userId = '%@' and delFlag = 0",familyId,userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        family = [HMFamily object:rs];
    });
    
    return family;
}


+ (BOOL)deleteFamilyId:(NSString *)familyId ofUserId:(NSString *)userId
{
    NSString *sql = [NSString stringWithFormat:@"delete from family where familyId = '%@' and userId = '%@'",familyId,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (void )loadPicFromDataBaseWithFamily:(HMFamily *)family callBack:(GetLocalImage)localImage{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/FamilyIcon"];
    
    // 目录不存在则创建
    if (![fileManager fileExistsAtPath:dir]) {
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.png",dir,[family.pic componentsSeparatedByString:@"/"].lastObject];
    
    UIImage * image =  [UIImage imageWithContentsOfFile:path];
    if (!image) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:family.pic]];
            if (data) {
                [data writeToFile:path atomically:YES];
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        localImage (image);
                    });
                }
            }
        });
        
    }else{
        localImage (image);
    }
}


+ (NSUInteger)familyCount
{
    __block NSUInteger count = 0;
    
    NSString *sql = [NSString stringWithFormat:@"select count() as count from family where userId = '%@' and delFlag = 0",userAccout().userId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return count;
}
@end
