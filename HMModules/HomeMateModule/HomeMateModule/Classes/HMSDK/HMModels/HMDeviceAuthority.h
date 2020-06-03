//
//  HMDeviceAuthority.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDeviceAuthority : NSObject
//@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) BOOL isAuthorized;
@end
