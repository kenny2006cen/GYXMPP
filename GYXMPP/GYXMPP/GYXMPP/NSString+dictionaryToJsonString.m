//
//  NSString+dictionaryToJsonString.m
//  GYXMPP
//
//  Created by User on 16/6/20.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "NSString+dictionaryToJsonString.h"

@implementation NSString (dictionaryToJsonString)


+ (NSString *)dictionaryToJsonString:(NSDictionary *)dic
{
    if (!dic) return nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (error)
    {
        return nil;
    }
    return string;
}

@end
