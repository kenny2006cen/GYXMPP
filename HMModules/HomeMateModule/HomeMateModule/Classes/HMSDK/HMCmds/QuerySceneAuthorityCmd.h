//
//  QuerySceneAuthorityCmd.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/19.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QuerySceneAuthorityCmd : BaseCmd

@property (nonatomic, copy) NSString * familyId;
@property (nonatomic, copy) NSString * userId;

@end
