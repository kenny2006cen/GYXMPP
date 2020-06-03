//
//  HMCustomPicture.m
//  HomeMate
//
//  Created by liqiang on 16/9/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMCustomPicture.h"
#import "HMConstant.h"


@implementation HMCustomPicture

+ (NSString *)tableName
{
    return @"customPicture";
}


+ (NSArray*)columns
{
    return @[column("imageInfoId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("customId","text"),
             column("imageURL","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
    
}

+ (NSString*)constrains
{
    return @"UNIQUE (imageInfoId, customId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

+ (HMCustomPicture *)objectFromDictionary:(NSDictionary *)dict {
    HMCustomPicture * customPic = [[HMCustomPicture alloc] init];
    customPic.imageInfoId = [dict objectForKey:@"imageInfoId"];
    customPic.userId = [dict objectForKey:@"userId"];
    customPic.imageURL = [dict objectForKey:@"imageURL"];
    customPic.customId = [dict objectForKey:@"customId"];
    customPic.createTime = [dict objectForKey:@"createTime"];
    customPic.updateTime = [dict objectForKey:@"updateTime"];
    customPic.delFlag = [[dict objectForKey:@"delFlag"] intValue];

    
    return customPic;
}
@end
