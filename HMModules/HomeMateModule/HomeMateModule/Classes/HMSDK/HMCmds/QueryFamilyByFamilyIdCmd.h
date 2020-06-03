//
//  QueryFamilyByFamilyId.h
//  HomeMateSDK
//
//  Created by peanut on 2017/7/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

/**
 通过familyId查询具体的家庭
 */
@interface QueryFamilyByFamilyIdCmd : BaseCmd

/**
 必填
 */
@property (nonatomic, copy) NSString *familyId;

@end
