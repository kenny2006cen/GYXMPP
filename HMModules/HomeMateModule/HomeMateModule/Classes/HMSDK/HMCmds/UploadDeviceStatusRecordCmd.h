//
//  uploadDeviceStatusRecord.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface UploadDeviceStatusRecordCmd : BaseCmd
@property(nonatomic,copy)NSString * uploadDeviceId;
@property(nonatomic,assign)KDeviceType uploadDeviceType;
@property(nonatomic,assign)int uploadTPage;
@property(nonatomic,assign)int uploadPageIndex;
@property(nonatomic,assign)int uploadCount;
@property(nonatomic,strong)NSArray * allList;
@end
