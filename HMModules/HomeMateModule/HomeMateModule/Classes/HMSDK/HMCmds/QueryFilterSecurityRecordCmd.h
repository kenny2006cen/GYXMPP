//
//  QueryFilterSecurityRecordCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryFilterSecurityRecordCmd : BaseCmd

@property (nonatomic, copy)NSString * familyId;

@property (nonatomic, assign)int readCount;

@property (nonatomic, strong)NSArray * conditionList;


@end
