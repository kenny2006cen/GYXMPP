//
//  FirmwareVersionUploadCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/2/1.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface FirmwareVersionUploadCmd : BaseCmd
@property (nonatomic, copy) NSString *hardwareVersion;
@property (nonatomic, copy) NSString *softwareVersion;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *coordinatorVersion;
@property (nonatomic, assign) int versionID;
@property (nonatomic, copy) NSString *hostUid;
@end
