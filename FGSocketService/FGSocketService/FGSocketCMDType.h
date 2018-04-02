//
//  PZSocketCMDHeader.h
//  PrizeClaw
//
//  Created by FengLe on 2017/9/29.
//  Copyright © 2017年 FengLe. All rights reserved.
//

#ifndef FGSocketCMDType_h
#define FGSocketCMDType_h

/**
 在这里书写与服务端约定的协议号...
 */
typedef NS_ENUM(NSUInteger, FGSocketMsgType) {

    FGSocket_Msg_Heartbeat                    = 1000, //客户端响应ping
    FGSocket_Msg_HostHeartbeat                = 1001, //主机响应ping
    
    FGSocket_Msg_NoticeReminder               = 1003, //提示
    FGSocket_Msg_Auth                         = 2000, //鉴权
    FGSocket_Msg_HostAuth                     = 2001, //主机鉴权

};

#endif /* PZSocketCMDHeader_h */
