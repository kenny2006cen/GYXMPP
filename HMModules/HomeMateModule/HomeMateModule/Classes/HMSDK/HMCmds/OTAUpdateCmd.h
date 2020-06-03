//
//  OTAUpdateCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2018/8/20.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface OTAUpdateCmd : BaseCmd
@property (nonatomic,assign) int type;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSString * md5;
@property (nonatomic,assign) int size;
@property (nonatomic,assign) BOOL isServerResponse;
@end
