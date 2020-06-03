//
//  ThemeSettingCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/6/8.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "ThemeSettingCmd.h"

@implementation ThemeSettingCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_THEME_SETTING;
}

-(NSDictionary *)payload
{
    if (self.themeParameter) {
        [sendDic setObject:self.themeParameter forKey:@"themeParameter"];
    }
    return sendDic;
}


@end
