//
//  CommonDeviceModel.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMCommonDeviceModel.h"

@implementation HMCommonDeviceModel

+(NSString *)tableName
{
    return @"deviceCommon";
}

+ (NSArray*)columns
{
    return @[column_constrains("deviceId", "text","UNIQUE ON CONFLICT REPLACE"),
             column("commonFlag", "integer")
             ];
    
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceCommon where deviceId = '%@'",self.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
@end
