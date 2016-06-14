//
//  ViewController.m
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "ViewController.h"
#import "GYXMPP.h"
#import <MagicalRecord/MagicalRecord.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"登录";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setFrame:CGRectMake(100, 200, 100, 100)];
    
    [button setTitle:@"登录" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button2 setFrame:CGRectMake(100, 100, 100, 100)];
    
    [button2 setTitle:@"发送消息" forState:UIControlStateNormal];
    
    [button2 addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button2];
}

-(void)loginAction{

    [[GYXMPP sharedInstance]xmppUserLogin:^(XMPPResultType type) {
        
        if (type==XMPPResultTypeLoginSuccess) {
            
            NSLog(@"登陆成功");
            
            
        }
        
    }];
    
}

-(void)sendAction{

    GYMessage *message =[GYMessage MR_createEntity];
    
    message.msgFromUser =@"";
    message.msgToUser =@"m_e_0603211000000260000@im.gy.com";
    message.msgType =@1;
    
    NSDictionary *dic =@{@"msg_content":@"测试",
                         @"msg_type":@"2",
                         @"msg_icon":@"",
                         @"msg_note":@"系统操作员",
                         @"msg_code":@"00"};
    
    
    message.msgBody =[self dictionaryToString:dic];
    
    [[GYXMPP sharedInstance]sendMessage:message];
    
}

- (NSString *)dictionaryToString:(NSDictionary *)dic
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
