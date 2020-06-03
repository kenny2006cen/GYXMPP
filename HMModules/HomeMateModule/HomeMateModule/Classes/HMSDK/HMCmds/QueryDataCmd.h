//
//  QueryData.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryDataCmd : BaseCmd

@property (nonatomic, assign)int LastUpdateTime;

@property (nonatomic, retain)NSString * TableName;

@property (nonatomic, assign)int PageIndex;

@property (nonatomic, retain)NSString * dataType;

@property (nonatomic, retain)NSString * deviceId;

@property (nonatomic, retain)NSString * familyId;

@property (nonatomic,strong)NSString *extAddr;

@end
