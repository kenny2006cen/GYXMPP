//
//  HMAppMyCenter.h
//  HomeMateSDK
//
//  Created by liqiang on 17/5/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAppMyCenter : HMBaseModel
@property (nonatomic, strong) NSString *myCenterId;
@property (nonatomic, strong) NSString *factoryId;
@property (nonatomic, assign) int groupIndex;
@property (nonatomic, assign) int sequence;
@property (nonatomic, assign) int verCode;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *viewId;


@property (nonatomic, strong) NSString *myCenterName;
@property (nonatomic, strong) NSString *iconRealUrl;

@property (nonatomic, strong) UIImage *adImage;
@property (nonatomic, strong) NSString *adUrl;

@end
