//
//  UpdateFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "UpdateFamilyCmd.h"

@implementation UpdateFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.familyName) {
        [sendDic setObject:self.familyName forKey:@"familyName"];
    }
    
    if (self.geofence) {
        [sendDic setObject:self.geofence forKey:@"geofence"];
    }
    
    if (self.position) {
        [sendDic setObject:self.position forKey:@"position"];
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
