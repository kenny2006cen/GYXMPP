//
//  ViewController.m
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "ViewController.h"
#import "GYXMPP.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[GYXMPP sharedInstance]xmppUserLogin:^(XMPPResultType type) {
        
        if (type==XMPPResultTypeLoginSuccess) {
            
            NSLog(@"登陆成功");
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
