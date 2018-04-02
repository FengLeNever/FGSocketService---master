//
//  ViewController.m
//  FGSocketService
//
//  Created by FengLe on 2018/4/2.
//  Copyright © 2018年 FengLe. All rights reserved.
//

#import "ViewController.h"
#import "FGSocketService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    //用户登录,满足了可以连接Socket的条件,内部自动调用连接方法
    [[FGSocketService shareSocketService] appLogin];
    //发送数据包,传递协议号和数据
    [[FGSocketService shareSocketService] sendPacketWithPacketType:kSocetMsgType content:@{
                                                                                           //组装数据
                                                                                           }];
    //退出登录,清理数据,断开连接,禁止重连
    [[FGSocketService shareSocketService] appLogout];
    */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
