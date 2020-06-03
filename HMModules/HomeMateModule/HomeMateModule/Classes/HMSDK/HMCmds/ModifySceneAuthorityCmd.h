//
//  ModifySceneAuthorityCmd.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/19.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifySceneAuthorityCmd : BaseCmd

@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * familyId;
@property (nonatomic, assign) int  authorityType;//-1为不带该字段
@property (nonatomic, strong)NSArray *dataList;

@end
