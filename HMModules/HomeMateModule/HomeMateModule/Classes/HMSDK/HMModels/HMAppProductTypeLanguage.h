//
//  HMAppProductTypeLanguage.h
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAppProductTypeLanguage : HMBaseModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *productNameId;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productType;
@property (nonatomic, strong) NSString *preProductType;
@property (nonatomic, assign) int level;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *manualUrl;
@end
