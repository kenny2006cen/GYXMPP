//
//  HMMusicModel.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/3/4.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMMusicModel.h"
#import "HMBaseModel+Extension.h"
#import "HMConstant.h"

@implementation HMMusicModel
+(NSString *)tableName
{
    return @"music";
}

+ (NSArray*)columns
{
    return @[
             column("favoriteId", "text"),
             column("musicId", "text"),
             column("source", "integer"),
             column("title", "text"),
             column("singer", "text"),
             column("albums", "text"),
             column("imageUrl", "text"),
             column("duration", "integer"),
             column("songSize", "integer"),
             column("sequence", "integer"),
             column("like", "integer"),
             column("favoriteMusicId", "text"),
             column("listType", "integer"),
             column("type", "text"),
             column("updateTime", "text"),
             column("createTime", "text"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (musicId) ON CONFLICT REPLACE";
}

- (instancetype)init {
    if (self=[super init]) {
        self.isSelect = 0;
        self.like = 0;
    }
    return self;
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
- (void)setAllSelect:(NSNumber *)number {
    _isSelect = number.intValue;
}

- (NSDictionary *)dictionaryFromObject {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (!isBlankString(self.musicId)) {
        [dict setObject:self.musicId forKey:@"musicId"];
    }
    if (!isBlankString(self.title)) {
        [dict setObject:self.title forKey:@"title"];
    }
    if (!isBlankString(self.singer)) {
        [dict setObject:self.singer forKey:@"singer"];
    }
    if (!isBlankString(self.albums)) {
        [dict setObject:self.albums forKey:@"albums"];
    }
    if (!isBlankString(self.imageUrl)) {
        [dict setObject:self.imageUrl forKey:@"imageUrl"];
    }
    
    [dict setObject:@(self.source) forKey:@"source"];
    [dict setObject:@(self.duration) forKey:@"duration"];
    [dict setObject:@(self.songSize) forKey:@"songSize"];
    [dict setObject:@(self.sequence) forKey:@"sequence"];

    return dict;
}

- (NSDictionary *)simpleDictionary {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (!isBlankString(self.musicId)) {
        [dict setObject:self.musicId forKey:@"musicId"];
    }
    if (!isBlankString(self.title)) {
        [dict setObject:self.title forKey:@"title"];
    }
    if (!isBlankString(self.singer)) {
        [dict setObject:self.singer forKey:@"singer"];
    }
    if (!isBlankString(self.albums)) {
        [dict setObject:self.albums forKey:@"albums"];
    }
    if (!isBlankString(self.imageUrl)) {
        [dict setObject:self.imageUrl forKey:@"imageUrl"];
    }
    return dict;
    
}

- (BOOL)deleteObject {
    NSString * sql = [NSString stringWithFormat:@"delete from music where  musicId = '%@'",self.musicId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)deleteMusicSource:(int)listType
                     type:(NSString *)type
               favoriteId:(NSString *)favoriteId {
    NSString * sql =  @"";
    if (isBlankString(type)) {
        sql =[NSString stringWithFormat:@"delete from music where listType = %d and favoriteId = '%@'",listType,favoriteId];
    }else {
        sql =[NSString stringWithFormat:@"delete from music where listType = %d and favoriteId = '%@' and type = '%@'",listType,favoriteId,type];

    }
    
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSMutableArray *)musicForSource:(int)listType
                              type:(NSString *)type
                        favoriteId:(NSString *)favoriteId {
    
    NSMutableArray * array = [NSMutableArray array];
    
    NSString * sql =  @"";
    if (isBlankString(type)) {
        sql = [NSString stringWithFormat:@"select * from music where listType = %d and  favoriteId = '%@'" ,listType,favoriteId];
    }else {
        sql = [NSString stringWithFormat:@"select * from music where listType = %d and  favoriteId = '%@' and type = '%@'" ,listType,favoriteId,type];

    }
    
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMMusicModel * model = [HMMusicModel object:rs];
        model.title = [self handleParenthesesString:model.title];
        [array addObject:model];
    }
    [rs close];
    return array;
    
}


+ (NSString *)handleParenthesesString:(NSString *)str
{
    if(!str) return nil;
    NSMutableString* muStr = [NSMutableString stringWithString:str];
    while(1) {
        NSRange range = [muStr rangeOfString:@"("];
        NSRange range1 = [muStr rangeOfString:@")" options:NSBackwardsSearch];
        if(range.location != NSNotFound && range1.location != NSNotFound && (range1.location > range.location)) {
            NSInteger loc = range.location;
            NSInteger len = range1.location - range.location;
            [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
        }else{
            break;
        }
    }
    return muStr;
}
@end
