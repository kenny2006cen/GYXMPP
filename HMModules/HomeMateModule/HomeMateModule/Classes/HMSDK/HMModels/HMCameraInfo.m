//
//  VihomeCameraInfo.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMCameraInfo.h"
#import "HMUserGatewayBind.h"

@implementation HMCameraInfo
+(NSString *)tableName
{
    return @"cameraInfo";
}

+ (NSArray*)columns
{
    return @[column("cameraInfoId", "text"),
             column("uid","text"),
             column("deviceId","text"),
             column("url","text"),
             column("port","integer"),
             column("type","integer"),
             column("cameraUid","text"),
             column("user","text"),
             column("password","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag", "integer")
             ];
    
}
+ (NSString*)constrains
{
    return @"UNIQUE (cameraInfoId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from cameraInfo where cameraInfoId = '%@' and uid = '%@'",self.cameraInfoId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+ (int )selectTypeByUid:(NSString *)uid{
    __block  int type ;
    NSString * sql = [NSString stringWithFormat:@"select * from cameraInfo where uid = '%@'",uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        type = [rs intForColumn:@"type"];
    });
    return type;

}

+ (NSArray *)deviceIdArrayWithType:(int)type
{
    __block NSMutableArray *deviceIdArr;
    NSString *sql = [NSString stringWithFormat:@"select deviceId from cameraInfo where type = %d and delFlag = 0 and uid in (select uid from device where delFlag = 0 and uid in %@)", type, [HMUserGatewayBind uidStatement]];
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!deviceIdArr) {
            deviceIdArr = [[NSMutableArray alloc] init];
        }
        NSString *deviceId = [rs stringForColumn:@"deviceId"];
        [deviceIdArr addObject:deviceId];
    });
    return deviceIdArr;
}


+ (NSArray *)UIDArrayWithType:(int)type
{
    __block NSMutableArray *uidArr;
    NSString *sql = [NSString stringWithFormat:@"select uid from cameraInfo where type = %d and delFlag = 0 and uid in (select uid from device where delFlag = 0 and uid in %@)", type, [HMUserGatewayBind uidStatement]];
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!uidArr) {
            uidArr = [[NSMutableArray alloc] init];
        }
        NSString *uid = [rs stringForColumn:@"uid"];
        [uidArr addObject:uid];
    });
    return uidArr;
}

@end
