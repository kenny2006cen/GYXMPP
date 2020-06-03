//
//  QueryWeatherCmd.m
//  HomeMate
//
//  Created by Air on 15/11/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryWeatherCmd.h"

@implementation QueryWeatherCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QW;
}

-(NSDictionary *)payload
{
    if (self.cityName) {
        [sendDic setObject:self.cityName forKey:@"cityName"];
    }
    if (self.longitude) {
        [sendDic setObject:self.longitude forKey:@"longitude"];
    }
    
    if (self.latotide) {
        [sendDic setObject:self.latotide forKey:@"latotide"];
    }
    return sendDic;
}

@end
