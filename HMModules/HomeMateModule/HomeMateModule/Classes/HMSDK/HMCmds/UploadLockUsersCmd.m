//
//  UploadLockUsersCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/4/19.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "UploadLockUsersCmd.h"

@implementation UploadLockUsersCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_APP_UPLOAD_LOCK_USERS;
}

-(NSDictionary *)payload
{
    if (self.userList) {
        [sendDic setObject:self.userList forKey:@"userList"];
    }
    
    return sendDic;

}
@end
