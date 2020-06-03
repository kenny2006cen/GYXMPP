//
//  SetLinkageServiceCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2017/2/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SetLinkageServiceCmd : BaseCmd

@property (nonatomic,strong)NSString *linkageId;
@property (nonatomic,strong)NSString *linkageName;

@property (nonatomic,strong)NSArray * linkageConditionAddList;
@property (nonatomic,strong)NSArray * linkageConditionModifyList;
@property (nonatomic,strong)NSArray * linkageConditionDeleteList;

@property (nonatomic,strong)NSArray * linkageOutputAddList;
@property (nonatomic,strong)NSArray * linkageOutputModifyList;
@property (nonatomic,strong)NSArray * linkageOutputDeleteList;

@property (nonatomic,assign)int type;

/// and：表示条件进行“与”运算  or：表示条件进行“或”运算
@property (nonatomic,strong)NSString *conditionRelation;

@end
