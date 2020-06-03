//
//  HMFloorOrderModel.h
//  HomeMate
//
//  Created by user on 16/9/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMFloorOrderModel : HMBaseModel

@property (nonatomic, assign) NSInteger sequence;//楼层排序

@property (nonatomic, copy) NSString *floorId;//楼层ID

+(HMFloorOrderModel *)readObjectByFloorId:(NSString *)floorId AndIndex:(NSInteger )index;

@end
