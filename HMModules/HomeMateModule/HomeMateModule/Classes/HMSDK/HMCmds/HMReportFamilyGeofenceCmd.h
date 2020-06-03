//
//  HMReportFamilyGeofenceCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMReportFamilyGeofenceCmd : BaseCmd
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSArray *dataList;

@end
