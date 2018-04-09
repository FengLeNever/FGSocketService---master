
> 虽然CocoaAsyncSocket已经非常的成熟，但是由于项目，业务，协议等不同导致tcp模块的公用性不高，需要根据协议重新订制调整，不能直接拷贝框架使用。
有感于以前项目中通信框架的十分臃肿（...每个协议号对应着一个Model类的架构，怎么吐槽），对项目的Tcp框架重新梳理，拿出来和大家分享一下，肯定有不完善之处，希望各位大佬指点。

###### [简书地址](https://www.jianshu.com/p/bce3b905fbd6)

######文件目录：

![文件目录.png](https://upload-images.jianshu.io/upload_images/1637319-a6e1503af5b88284.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)


######逻辑文件说明：

![逻辑文件.png](https://upload-images.jianshu.io/upload_images/1637319-7f86d7a328175de9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1.  FGSocketService类：这个类位于最上层，负责对整个APP提供接口，供外部调用。
2.  FGSocketConnection类：只负责socket网络的连接通信，内部使用GCDAsyncSocket；
3. FGSocketChannel类：继承FGSocketConnection类，负责向FGSocketService类提供接口，负责数据的分发，但FGSocketService不直接使用FGSocketChannel类，而是使用子类FGSocketChannelDefault。
4. FGSocketChannelDefault类：继承自FGSocketChannel类，主要负责TCP状态监控和重连。
5. FGSocketConnectionDelegate.h：对FGSocketConnection方法声明的封装。
6. FGSocketPacketDecode和FGSocketPacketEncode类：负责对数据进行编解码，对粘包，分包进行处理。
7. FGSocketConnectParam类：连接socket的配置数据Model。

######数据文件说明：

![数据.png](https://upload-images.jianshu.io/upload_images/1637319-5f367ba5568dc386.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

FGSocketPacket声明协议类型和数据，子类通过初始化方法填充数据。
这里的注意点：
1. 每个公司定的数据包格式不同，所以解析方法也不同，需要作出修改。
2. 数据有大小端之分，而iOS采用小端，如果服务器采用大端格式传递数据，那要做出相应转换。
3. 代码中数据包组装方式：包大小（short）+  协议号（int）+  无意义数据（short）+ json 数据；

######调用接口说明：

```
//用户登录,满足了可以连接Socket的条件,内部自动调用连接方法
[[FGSocketService shareSocketService] appLogin];
//发送数据包,传递协议号和数据
[[FGSocketService shareSocketService] sendPacketWithPacketType:kSocetMsgType content:@{
//组装数据
}];
//退出登录,清理数据,断开连接,禁止重连
[[FGSocketService shareSocketService] appLogout];
```
######感谢：
#### [RHSocketKit](https://github.com/zhu410289616/RHSocketKit) 感谢开源作者贡献
