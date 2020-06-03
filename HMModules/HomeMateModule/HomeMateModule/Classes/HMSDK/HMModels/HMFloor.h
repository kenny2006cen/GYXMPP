//
//  VihomeFloor.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMFloor : HMBaseModel

@property (nonatomic, retain)NSString *         floorId;

@property (nonatomic, retain)NSString *         floorName;

@property (nonatomic, assign)BOOL         hidden;

@property (nonatomic, assign)NSInteger    index;//顺序

@property (nonatomic, assign)BOOL               beSelected;


+(void)saveFloorAndRoom:(NSDictionary *)dic;
+(NSMutableArray *)selectAllFloor;
+(HMFloor *)selectFloorByFloorId:(NSString *)floorId;

+(NSMutableArray <HMFloor *>*)selectAllFloorWithFamilyId:(NSString *)familyId;


/**
 删除某一家庭的所有楼层

 @param familyId 家庭id
 @return 返回删除成功与否
 */
+(BOOL)deleteAllFloorsOfFamilyId:(NSString *)familyId;


@end
