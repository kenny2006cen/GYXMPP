//
//  ActivateSceneSeviceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ActivateSceneSeviceCmd.h"

@implementation ActivateSceneSeviceCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_SCENE_SERVICE_EXECUTE;
}

- (NSDictionary *)payload {

    if (self.sceneNo.length) {
        [sendDic setObject:self.sceneNo forKey:@"sceneNo"];
    }

    [sendDic setObject:self.userName forKey:@"userName"];


    return sendDic;
}
@end
