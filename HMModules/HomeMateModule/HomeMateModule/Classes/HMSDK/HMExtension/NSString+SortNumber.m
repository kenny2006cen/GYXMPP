//
//  NSString+SortNumber.m
//  Vihome
//
//  Created by Ned on 4/29/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NSString+SortNumber.h"

@implementation NSString (SortNumber)

- (NSString *)sortNumber
{
    NSMutableString *numberString = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < [self length]; i++) {
        unichar c = [self characterAtIndex:i];
        if (c >= '0'  && c <= '9') {
            [numberString appendFormat:@"%c",c];
        }
    }
    
    if (numberString.length > 0) {
        return numberString;
    }
    return @"";
}

@end
