//
//  HMSecurityDeviceSort.h
//  HomeMateSDK
//
//  Created by Feng on 2017/12/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMSecurityDeviceSort : HMBaseModel
@property (copy, nonatomic) NSString * sortUserId;
@property (copy, nonatomic) NSString * sortDeviceId;
@property (copy, nonatomic) NSString * sortFamilyId;
@property (assign, nonatomic) int sortTime;
@end
