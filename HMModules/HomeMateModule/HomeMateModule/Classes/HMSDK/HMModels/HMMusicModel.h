//
//  HMMusicModel.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/3/4.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

typedef NS_ENUM(NSInteger,HMMusicSource) {
    HMMusicSourceUnknown = 0,
    HMMusicSourceMIGu = 1,
    HMMusicSourceQQ = 2,
    HMMusicSourceXiaMi = 3,
    HMMusicSourceMixPadLocal = 10000,
};

@interface HMMusicModel : HMBaseModel
@property (nonatomic, strong) NSString * favoriteId;
@property (nonatomic, strong) NSString * musicId;
@property (nonatomic, assign) HMMusicSource source;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * singer;
@property (nonatomic, strong) NSString * albums;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int position;
@property (nonatomic, assign) int songSize;
@property (nonatomic, assign) int sequence;

@property (nonatomic, assign) int like;
@property (nonatomic, strong) NSString * favoriteMusicId;
@property (nonatomic, assign) int isSelect;

@property (nonatomic, assign) int listType;
@property (nonatomic, strong) NSString * type;

- (void)setAllSelect:(NSNumber *)number;

- (NSDictionary *)simpleDictionary;

+ (NSMutableArray *)musicForSource:(int)listType
                              type:(NSString *)type
                        favoriteId:(NSString *)favoriteId;

+ (BOOL)deleteMusicSource:(int)listType
                     type:(NSString *)type
                favoriteId:(NSString *)favoriteId;


/// 去除文本中（）的内容
/// @param str 要去除的文本
+ (NSString*)handleParenthesesString:(NSString*)str;

@end
