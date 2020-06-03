//
//  HMChannelCollectionModel.m
//  HomeMate
//
//  Created by orvibo on 16/7/18.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMChannelCollectionModel.h"
#import "HMConstant.h"

@interface HMChannelCollectionModel ()

@property (nonatomic,strong)NSMutableArray *idArray;

@end

@implementation HMChannelCollectionModel

+ (NSString *)tableName {

    return @"channelCollection";
}

+ (NSArray*)columns
{
    return @[
             column("channelCollectionId", "text"),
             column("uid", "text"),
             column("deviceId", "text"),
             column("channelId", "integer"),
             column("isHd", "integer"),
             column("countryId", "text"),
             column("createTime", "text"),
             column("updateTime", "text"),
             column("updateTimeSec", "integer"),
             column("delFlag", "integer")
             ];
    
}

+ (NSString*)constrains
{
    return @"UNIQUE (channelCollectionId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {

    NSString *sql = [NSString stringWithFormat:@"delete from channelCollection where channelCollectionId = '%@'",_channelCollectionId];
    return [self executeUpdate:sql];
}

- (NSArray *)readAllCollectChannelWithDeviceId:(NSString *)deviceId {

    __weak typeof(self) weakSelf = self;
    __block NSMutableArray *dataArray;
    NSString *sql = [NSString stringWithFormat:@"select * from channelCollection where deviceId = '%@' and delFlag == 0",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!dataArray) {
            dataArray = [[NSMutableArray alloc] init];
        }
        HMChannelCollectionModel *model = [HMChannelCollectionModel object:rs];
        if (!weakSelf.idArray) {
            weakSelf.idArray = [NSMutableArray array];
        }
        [weakSelf.idArray addObject:@(model.channelId)];
        [dataArray addObject:model];
    });

    return [self sortArrayWithCreateTime:dataArray];
}

- (NSArray *)getAllCollectChannelId {
    return _idArray;
}

- (NSArray *)sortArrayWithCreateTime:(NSArray *)array {
    if (!array || array.count == 0) {
        return array;
    }
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:array];

    for (NSInteger i = 0; i < dataArray.count; i++) {
        for (NSInteger j = i + 1; j < dataArray.count; j++) {

            NSString *dateString = [dataArray[i] valueForKey:@"createTime"];
            NSString *nextDateString = [dataArray[j] valueForKey:@"createTime"];

            NSInteger value = [self transformDate:[dataArray[i] valueForKey:@"createTime"]];
            NSInteger nextValue = [self transformDate:[dataArray[j] valueForKey:@"createTime"]];

            DLog(@"%@:   %d----%@:    %d",dateString, value, nextDateString, nextValue);

            if (value < nextValue) {  // 由大到小排列
                [dataArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    return dataArray;
}


- (NSInteger)transformDate:(NSString *)dateTime {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:dateTime];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
        return [timeSp integerValue];
}



@end
