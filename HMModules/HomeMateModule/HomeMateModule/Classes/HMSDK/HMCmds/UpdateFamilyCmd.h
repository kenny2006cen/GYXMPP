//
//  UpdateFamilyCmd.h
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface UpdateFamilyCmd : BaseCmd

@property (nonatomic, strong)NSString  * _Nullable  userId;

@property (nonatomic, strong)NSString * _Nullable familyId;

@property (nonatomic, strong)NSString * _Nullable familyName;

//家庭位置

//地理围栏
@property (nonatomic, strong) NSString * _Nullable  geofence;
//家庭位置
@property (nonatomic, strong) NSString * _Nullable  position;
//经度
@property (nonatomic, strong) NSString * _Nullable  longitude;
//纬度  latitude
@property (nonatomic, strong) NSString * _Nullable  latotide;
@end
