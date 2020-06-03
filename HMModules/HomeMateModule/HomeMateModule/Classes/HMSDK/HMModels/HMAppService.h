//
//  HMAppService.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/12/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAppService : HMBaseModel

@property (nonatomic,strong) NSString * id;
@property (nonatomic, strong) NSString *factoryId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, assign) int groupIndex;
@property (nonatomic, assign) int sequence;
@property (nonatomic, assign) int verCode;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *viewId;

@end
