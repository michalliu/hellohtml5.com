---
layout: post
title: 不吹不擂，一文看懂鸿蒙
categories:
tags:
---

导语：华为鸿蒙OS是否Android套皮，有什么创新，是否自主研发完全开源，本文带你深入鸿蒙的世界。

（阅读本文大约耗时20分钟。)

# 一、初识鸿蒙

中国在计算机基础核心领域缺乏建树，更一直没有自主知识产权的操作系统。之前又出过多起诸如[汉芯](https://zh.wikipedia.org/zh-hk/汉芯)，[红芯浏览器](https://zh.wikipedia.org/wiki/红芯浏览器)等造假事件，犹如现实世界的“狼来了”，使国人对任何打着自主知识产权宣传的产品都会戴着放大镜去看。那么鸿蒙到底是不是个例外。

鸿蒙是个很泛的概念，鸿蒙不仅一个操作系统，还是一个生态。鸿蒙这个词在不同的场景下指代不同的东西。根据华为官方IDE[ DevEco Studio ](https://developer.huawei.com/consumer/cn/deveco_studio)的应用模板可以看出，目前鸿蒙支持的设备有手机，平板，电视，手表，汽车，以及相机等小家电等等，不同的技术栈开发的应用支持的设备种类也不同。其中Java类型的应用支持的设备类型最为丰富，JS类型的应用其次，C++应用支持的类型最少。

{% include image.html img="app_template.png" attr="width:100%;" %}

这些设备大体上可以分为嵌入式和非嵌入式两种。根据应用所需内存大小又可以分为L0-L5六个级别

{% include image.html img="device_level.png" attr="width:100%;" %}

**在嵌入式领域，**鸿蒙指是一款嵌入式操作系统，鸿蒙的核心为LiteOS，系统只能在配套的硬件（开发板）上运行，并非通用的操作系统，OpenHarmony是其对外开源的版本，在2020年9月在gitee上开源OpenHarmony 1.0，关于这款系统华为自身的文档比较欠缺，这里有较为详细的[开发者文档](https://www.bookstack.cn/read/openharmony-1.0-zh-cn/Readme-CN.md)。

**在非嵌入式领域，**鸿蒙指的是一款叫鸿蒙的手机操作系统，最近网上热议的[“此应用专为旧版鸿蒙打造”](https://www.zhihu.com/question/435444581)令人疑窦丛生。

{% include image.html img="old_harmony.png" attr="width:100%;" %}

因为截至目前鸿蒙只发布了一个版本，根本不存在所谓的旧版鸿蒙。由于鸿蒙的手机版操作系统并未开源，提示语又与android如此类似，不得不令人怀疑是字符串批量替换。那么事实真是字符串替换如此简单吗？下文将会予以分析。

总的来说，鸿蒙绝不仅仅指的是操作系统，华为的野心也绝不止于此，华为是要打造一个叫鸿蒙的生态，我们不排除未来会有鸿蒙SDK植入其它厂商的设备，使这些设备也具备运行鸿蒙应用的能力，甚至是运行在传统的Windows、Linux上的设备，那么这些设备也可以说是一个鸿蒙设备，是鸿蒙生态的一部分。

# 二、鸿蒙核心

鸿蒙生态的核心是以下四点

## 1、多设备兼容

即开发出来的应用，可以覆盖多种类型的设备，屏蔽底层OS的差异，类似目前火热的[Flutter](https://flutter.dev/)所解决的问题。

{% include image.html img="device_compatibility.png" attr="width:100%;" %}

## 2、卡片式应用

在多设备兼容的基础上带来一致的，高性能的交互体验。可以理解为跨设备，跨平台，跨网络的轻量Widget。

{% include image.html img="card_ui.png" attr="width:100%;" %}

{% include image.html img="card_ui_2.png" attr="width:100%;" %}

## 3、软总线

在以上两点的基础上，降低设备间互联互通的门槛。主要基于以下三点改进

|                    | **传统设备**                             | **鸿蒙设备** |
| ------------------ | ---------------------------------------- | ------------ |
| 设备间的发现和连接 | 手动扫描发现                             | 自动发现     |
| 设备间组网通信     | 蓝牙、WiFi不互通，各自组网，无法直接通信 | 异构组网     |
| 数据传输协议       | 无统一规范标准                           | 统一极简协议 |

（1）设备间的发现和连接：从手动发现，进化成自发现
{% include image.html img="softbus_1.jpg" attr="width:100%;" %}

（2）多设备互联后的组网技术：软总线组网-异构网络组网
{% include image.html img="softbus_2.png" attr="width:100%;" %}

（3）多设备多协议间的高效传输技术
{% include image.html img="softbus_3.jpg" attr="width:100%;" %}

## 4、通信安全

要实现设备间的互联互通，那么安全无疑是特别重要的环节。这里的问题是如何保证正确的人使用正确的设备，消费正确的数据。即要解决如下三个问题：

（1）如何保证消费者对设备的鉴权是安全的，保证设备是原厂生产，没有被篡改的？（正确的设备）  
（2）如何保证消费者操作设备数据是安全的？ (正确的人)  
（3）如何保证消费者数据安全?（正确使用数据）  

鸿蒙在系统和数据通信安全方面有较为完善的考虑。
{% include image.html img="security.png" attr="width:100%;" %}

# 三、系统层分析

基于鸿蒙已经开源的[openharmony](https://gitee.com/openharmony)源码统计，openharmony包含C代码2KW行，C++ 500W行。

{% include image.html img="code_statistics.png" attr="width:100%;" %}

## 1、内核部分

鸿蒙宣传的微内核，并未说明是哪个鸿蒙，华为目前已经发布的内核包括：  
1、Linux 面向手机 (L5级别设备)  
2、LiteOS-a 面向有MMU的设备 (>=L1级别)   
3、LiteOS-m 面向无MMU的嵌入式设备 (L0级别)  

目前行业内对内核进行分类主要是：  

| **内核类型**               | **操作系统代表**                  |
| -------------------------- | --------------------------------- |
| 宏内核（单内核）           | Linux、BSD Unix、LiteOS-A         |
| 微内核                     | MiniX、L4、QNX                    |
| 混合内核                   | Windows、MacOS X                  |
| 外内核（是一种极简微内核） | 主要是学术性研究，例如：MIT Aegis |

{% include image.html img="kernel_type.png" attr="width:100%;" %}

微内核的优点：  
1、代码量小，可以形式化验证，可以减少bug量，几乎可以0 bug，另外更加方便移植。  
2、各个系统组件或者服务如果存在问题可以直接重启服务，减少核心组件异常对整个系统的破坏，并按需组织系统服务。  
3、各组件可以按需加载（现在宏内核也支持模块动态加载卸载）。  
4、可以规避GPL协议。  

微内核缺点：  
1、所有资源获取都需要通过IPC，IPC又必须陷入内核，所以会导致频繁的陷入内核，或者多次拷贝，导致性能下降。当然IPC通信效率随着深入研究与技术发展逐步提高。  
2、对于中断响应，需要映射到用户空间再处理，效率较低。  
3、大量使用某些系统服务的时候，会导致进程上下文切换，增加系统负担。  

{% include image.html img="kernel_type_2.png" attr="width:100%;" %}

而目前开源出来的鸿蒙代码 LiteOS-a按照业界对内核分类依旧是宏内核。至于华为是否存在微内核但没有开源，还是在实现鸿蒙过程中，又重新选择了宏内核，我们不得而知。

### 1.1 LiteOS-M

LiteOS-M和HW以前开源的Lite OS基本相同，进行部分结构性调整，当前只适用于cortex-m3、cortex-m4、cortex-m7、risc-v芯片架构，是纯粹的RTOS系统，通过KAL与上层服务匹配。

{% include image.html img="liteos_m.png" attr="width:100%;" %}

### 1.2 LiteOS-A

LiteOS-A是HW基于LiteOS进行演进的，进行 多进程，多核，虚拟内存，IPC等重新封装，尽量类似于Linux，但是尽量简化内核实现。OpenHarmony LiteOS-A内核架构图

{% include image.html img="liteos_a.png" attr="width:100%;" %}

LiteOS-A是HW基于LiteOS进行演进的，进行 多进程，多核，虚拟内存，IPC等重新封装，尽量类似于Linux，但是尽量简化内核实现。

LiteOS-A相对于纯粹的RTOS增强关键特性简介：  
**多进程：**基于task进行封装，较为简单的进程与线程调度（支持时间片和FIFO调度）；  
**多核：**全局链表、所有CPU共享，支持空闲轮询调度（不支持负载均衡），可支持亲和设置，可绑定核运行。  
**虚拟内存**：内核静态映射，静态映射提升虚实转换效率，最有区间分布（０－１G用户空间，１－４G内核空间，减少用户态进程页表项），用户态通过缺页异常按需获取内存。  
**动态链接：**按需加载，多应用共享代码段，加载最小单元为页，符号绑定，支持立即和延时绑定，加载地址随机化，进程代码段，数据段，堆栈段地址随机化。并且运行标准ELF文件。  
**进程通信（IPC）：**支持标准的posix进程间通信，如Mqueue,pipe,fifo.signal。同时添加了Lite IPC（类似与Android binder但是简单得多），ROM和RAM占用不超过30K，达到轻量，基于白名单控制的服务访问权限，提升安全，通过内存映射实现单次拷贝，实现高效。  
**系统调用：**通过MUSL实现系统调用支持syscall API和VDSO API。VDSO是减少系统调用开销的方式，Linux也支持。保证服务与内核分离。并且服务和应用不能随意访问内核。  
**权限管理：**进程粒度的权限划分与管理，完成DAC访问控制，以进程UID的配置，灵活划分文件资源归属与管控，提供UGO（user,group,other）的权限分配，满足基本的文件共享需求和Posix规范。  
**虚拟文件系统：**VFS管理根目录，挂载点内目录有FS管理。通过BCache和PCache提升文件系统读写速度。  
**POSIX标准库：**基于Musl C的posix标准库，当前支持1000+的标准Posix接口。用户态使用全量Musl，C++使用libC++，内核使用部分Musl。  
以上特性都基本上基于Linux的简化版本，保持内核小型化，并且尽量拥有Linux的功能特性。  

|                              | **优点**                                                     | **缺点**                                                     |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 业界RTOS方案                 | 1、内存占用小<br/>2、启动速度快<br/>3、实时性高                 | 1、生态不完善，移植第三方库和驱动复杂工作量较大<br/>2、应用和内核不能隔离，应用代码异常容易引发内核挂死。应用和产品无法解耦。 |
| Linux方案                    | 1、生态完善<br/>2、开发方便，应用与内核隔离，应用安全，可支持复杂的交互体验。 | 1、内存占用大<br/>2、启动速度慢<br/>3、实时性稍弱                    |

 LiteOS-A（鸿蒙方案）设计目标：  
 1、生态软件兼容：支持1000+的Posix接口复用GNU/Linux生态。  
 2、内核机制增强：增加多进程，虚拟内存，系统调用，实现应用与应用隔离，内核与应用隔离，VFS虚拟文件系统等。支持复杂交互体验设备开发。  
 3、生态器件统一：使用HDF统一驱动开发。  

### 1.3 Linux

鸿蒙OS Linux内核基于Linux 4.19版本内核，添加如下功能。

- CVE补丁

补丁所涉及的CVE(Common Vulnerabilities and Exposures)安全漏洞是通过NVD (https://nvd.nist.gov/)官方机构收集，且补丁已经进入LTS 4.19.y分支或主线，主要涉及存储(btrfs/scsi/)、网络(net/bpf/mwifiex) 、驱动(xen/nfc)，对应CVE列表参考commit信息中CVE字段信息。

- OpenHarmony特性

HDF驱动、binder ipc转发功能等特性支持。

- 特定芯片架构驱动补丁（比如Hi3516DV300）

vendor厂商提供的特定芯片架构驱动代码：

hisi_linux-4.19_hos_l2.patch: 在Hi3516DV300芯片上支持arm架构的内核启动（DTS等）及对应的drm/mmc等驱动的支持。

## 2、子系统

openharmony LiteOS-A包含如下子系统：

- 系统基本能力子系统集：为分布式应用在多设备上的运行、调度、迁移等操作提供了基础能力，由分布式软总线、分布式数据管理、分布式任务调度、公共基础库、多模输入、图形、安全、AI等子系统组成。
- 基础软件服务子系统集：提供公共的、通用的软件服务，由事件通知、电话、多媒体、DFX（Design For X） 等子系统组成。
- 增强软件服务子系统集：提供针对不同设备的、差异化的能力增强型软件服务，由智慧屏专有业务、穿戴专有业务、IoT专有业务等子系统组成。
- 硬件服务子系统集：提供硬件服务，由位置服务、生物特征识别、穿戴专有硬件服务、IoT专有硬件服务等子系统组成。

根据不同设备形态的部署环境，基础软件服务子系统集、增强软件服务子系统集、硬件服务子系统集内部可以按子系统粒度裁剪，每个子系统内部又可以按功能粒度裁剪。

## 3、多内核支持

{% include image.html img="multi_kernel.png" attr="width:100%;" %}

如上图所示，对于鸿蒙OS，其可以支持各种内核（目前支持Liteos-m,LiteOS-a,Linux）。其通过KAL层对上层提供统一的API接口能力。
我们可以清楚的看到KAL 支持统一是通过支持POSIX和CMSIS（针对arm Cotex-m 的抽象，做到在RTOS层面的尽量统一）对底层内核进行统一封装。做到基于上层API的程序可以在相应的CPU下编译通用，强调只能**编译通用**。  
其中兼容POSIX的库是Musl-libc。该库是一个轻量级的C标准库，设计作为GNU C library (glibc)、 uClibc或Android Bionic的替代用于嵌入式操作系统和移动设备。它遵循POSIX 2008规格和 C99 标准，采用MIT许可证授权，使用Musl的Linux发行版和项目包括sabotage，bootstrap-linux，LightCube OS等等
然后通过HDF来统一驱动模块的编写调试过程。以此来兼容驱动设备。

POSIX表示可移植操作系统接口（Portable Operating System Interface of UNIX，缩写为 POSIX ），POSIX标准定义了操作系统应该为应用程序提供的接口标准。POSIX标准意在期望获得源代码级别的软件可移植性。换句话说，为一个POSIX兼容的操作系统编写的程序，应该可以在任何其它的POSIX操作系统（即使是来自另一个厂商）上编译执行。

CMSIS（Cortex Microcontroller Software Interface Standard）标准，它是ARM同各个微控制器供应商、工具供应商和软件解决方案一起开发的Cortex微控制器软件接口标准。它使得微控制器和软件供应商可以使用一致的软件结构来开发Cortex微控制器的软件。

CMSIS-RTOS是CMSIS的一部分，它本身是一种API规范，各厂商可以基于CMSIS-RTOS构建自己的实时操作系统（RTOS）。由于基于CMSIS-RTOS的API是标准化的，所以基于这些API开发的应用软件，不需要进行额外的移植开发工作，就可跑在任何支持CMSIS-RTOS的OS上。随着基于CMSIS-RTOS的中间件越来越多，支持CMSIS-RTOS后的OS也会因此获得更多的中间件。

## 4、HDF驱动架构

OpenHarmony驱动主要部署在内核态，当前主要采用静态链接方式，随内核子系统编译和系统镜像打包。
{% include image.html img="hdf_1.png" attr="width:100%;" %}

驱动框架交互流程

{% include image.html img="hdf_2.png" attr="width:100%;" %}

如上图所示，发布设备服务，即在VFS创建固定的目录或者设备节点，并且通过HDI进行抽象。
下列是相关系统的适配层，让相应的内核支持HDF能力。然后驱动开发工程师通过　drivers_framework　提供的相关框架能力，编写HDF支持的各种驱动，所以HDF统一驱动，是建立在对各种内核集成的HDF　内核支持驱动作为转换层。
所以如果有新的内核需要适配，那么khdf需要根据相应的内核，进行移植，具有较大工作量。

相关源码目录是：

{% include image.html img="hdf_3.png" attr="width:100%;" %}

下图是HDF-Framework层。用于支持HDF统一驱动的开发，加载生效或者卸载。
{% include image.html img="hdf_4.png" attr="width:100%;" %}

通过代码中的uhdf/uhdf2可以看到，鸿蒙OS也在尝试将部分驱动放入用户空间，也就是向微内核（或者混合内核）方向演进。但如果是使用Linux内核，通常也可以使用标准的Linux内核驱动模型编写驱动。只是不方便移植到其他的鸿蒙非Linux内核的设备。不过不同的设备，其CPU与外设可能并不相同，分别编写也可能。

# 四、软总线分析

鸿蒙提供的标准软件总线框架图

{% include image.html img="softbus_detail_1.png" attr="width:100%;" %}

主要代码目录如下图，lite和standard有一定差异。针对lite设备，只有发现，认证传输。

{% include image.html img="softbus_detail_2.png" attr="width:100%;" %}

针对标准系统，则添加了组网，并且以client(SDK目录)+Server(core目录)的方式设计。

{% include image.html img="softbus_detail_3.png" attr="width:100%;" %}

现在开源出来的openharmony方案总体约束为在同一局域网下进行软总线互通。目前开源出来的还是TCP/IP协议建立的局域网。鸿蒙发布会描述的极简协议统一层，我们并没有看到。

软总线的时序图如下，Module可以看成分布式调度服务等，即其他使用软总线的模块。

{% include image.html img="softbus_detail_4.png" attr="width:100%;" %}

对于pubulicService 对服务进行发布，实际同时对 软总线进行初始化。（前提是WiFi已经接入了WiFi的局域网）

{% include image.html img="softbus_detail_5.png" attr="width:100%;" %}

传输在上面的publicService过程中创建的会话服务 CreateSessionServer（）就是后续进行基于session会话服务的基础。
调用者并不需要关心IP等，只需要使用创建的sessionID 进行通信即可。

- g_sessionMgr->serverListenerMap[i] 用于存储session。serverListenerMap结构中，最重要的是listener成员：onSessionOpened，是在会话创建时被回调的函数。
- onSessionClosed：是在会话结束时被回调的函数。
- onBytesReceived：是会话的数据到达的回调函数，注册的模块可以通过这个函数接收会话的报文，按照自己的格式进行解析，并执行会话要求的动作。例如：在分布式调度模块中，接收的数据解析后，可能是START_FA的命令。

相关的代码：

{% include image.html img="softbus_detail_6.png" attr="width:100%;" %}

在StartBus()函数会调用StartSession()函数创建基于TCP的socket的会话管理服务。

{% include image.html img="softbus_detail_7.png" attr="width:100%;" %}

循环监听服务来连接，数据传输。

{% include image.html img="softbus_detail_8.png" attr="width:100%;" %}

简单总结，就是软总线的传输，是基于COAP发布服务，等待超级终端通过softbus的session进行传输。当client要访问某个设备（可以是远程，可以是本地）的服务，首行连接远程服务的session服务器，并发送数据。远程的session服务通过onBytesRecived接收到数据，并回调给module。而是用module的目的。发送数据调用SendBytes，就可以基于sessionID发送。

{% include image.html img="softbus_detail_9.png" attr="width:100%;" %}

这个过程中，module也好，还是远程client的应用也好，都不需要知道服务在哪个地方，有软件总线进行处理即可，目前服务的发布只支持WiFi下的COAP。

在代码中可以看到，未来支持的软总线设备有BLE，COAP，USB三种类型。
{% include image.html img="softbus_detail_10.png" attr="width:100%;" %}

推测软件总线之下应该还有一个针对复杂设备支持多层连接的适配层，以便屏蔽底层差异（当前只开源了WiFi和BT），包括支持上述设备的组网，路由以便构建一张局域网。根据当前的开源代码来看，主要还是基于wifi的局域网连接，其他形式自组网还未看到，但华为在通信这块有很深的功底，这里相信这个目标可以达成。

基于目前公开的信息，软总线架构推测如下图：
{% include image.html img="softbus_detail_11.png" attr="width:100%;" %}

其中底层连接协议包括以太网、红外线、4G/5G/WiFi、BT、NFC等各种通信能力。目前NFC主要用于华为Card的认证，协助多设备之间的认证。

| 通信方式   | 描述                                                         |
| ---------- | ------------------------------------------------------------ |
| wifi-ap    | wifi热点                                                     |
| wifi-sta   | wifi客户端，如手机                                           |
| wifi-p2p   | wifi 无热点的点对点，点对多点的传输                          |
| wifi-aware | wifi快速发现协议，支持NAN的自组网。发现阶段是无加密通信，介入后进行加密通信 |
| BT-BLE     | 可以支持mesh自组网和广播的蓝牙短消息协议                     |
| BT-A2DP    | 蓝牙音频协议 可以与BLE组成双模                               |
| NFC        | 近场通信协议，可以支持数据传输，也可以支持刷卡业务           |

# 五、应用层分析

分别编写了鸿蒙的JS及Java应用，结合开放出来的部分源码及文档，对App安装包进行了简单的逆向分析。

## **1、开发环境**

官方IDE DevEco Studio是基于开源的intellij的改造，能够用于本地调试的模拟器只支持JS应用。Java应用截止目前只支持远程模拟器（所谓分布式模拟器）不支持本地模拟器。运行远程模拟器都需要账号密码登录，账号密码需要注册华为ID并实名认证，而实名认证需要上传身份证照片或者银行卡资料，远程调试由于网络和资源分配原因并不流畅，流畅度和画质方面不尽人意，开发体验有点儿糟糕。

当然如果有真机，也可以使用真机进行开发调试，但华为这里又设了两道门槛，开发鸿蒙应用需要双重签名认证，除了应用本身的签名，还要对应用工程进行签名。这两个签名都需要在鸿蒙开发者网站上注册，生成相应证书后方可安装到真机，步骤相当繁琐。笔者搞这个签名走各种注册流程前后耗时一小时，对开发者不是很友好，好在配置完成后，后续可以直接使用，算是一次性劳动。

从目前的应用开发流程上看，以后开发鸿蒙应用有可能会对签名服务进行收费，笔者不禁回想起了诺基亚，摩托罗拉时代，J2ME应用证书签名外包给第三方公司，一个应用签名收费2000元否则无法安装到用户手机，搞死生态的事情。生态还没起来，应用开发流程搞的如此复杂，希望华为借鉴这个历史教训。

## **2、应用框架**

鸿蒙应用UI框架有两套，支持Java、JS，IDE里有默认的模板。这两套框架的区别是，Java框架只支持鸿蒙Android系统，JS应用既支持鸿蒙Android系统，也支持鸿蒙嵌入式系统。鸿蒙JS应用在鸿蒙Android上是套了个Android应用的壳，这个壳会构建一个类似小程序的渲染环境，转换为Android的原生控件渲染，下文有展开分析。JS应用相比Java应用，在排版能力，扩展性，兼容性方面存在一定的局限性，更适合做信息展示类的应用。

对应的也有，Java和JS两套SDK，鸿蒙系统提供的名为Ability的应用框架也分别有Java和JS的实现。应用支持哪些设备，可以在应用的config.json中声明。


## 3、**应用格式**

无论是js应用还是java应用，代码最终编译出来包均为hap后缀，这个hap是未经hack的zip格式，可以使用标准的zip解压工具进行解压。

具体hap包的具体安装使用上，SDK提供命令行工具 hdc

{% highlight shell %}
hdc shell am force-stop com.example.myapplication
hdc shell bm uninstall com.example.myapplication
hdc file send ~/DevEcoStudioProjects/MyApplication/entry/build/outputs/hap/debug/entry-debug-unsigned.hap /sdcard/entry-debug-unsigned.hap
hdc shell bm install -p /sdcard/
hdc shell rm -rf /sdcard/xxx
hdc shell am start -n "com.example.myapplication/com.example.myapplication.MainAbilityShellActivity" -D
hdc app install xxx.hap
{% endhighlight%}

### **3.1、Java应用**

java应用在开发时依赖以下SDK包，只能用来编译代码，SDK反编译看不到源码，也未开源。

{% include image.html img="app_detail_1.png" attr="width:100%;" %}

根据文件命名，对其功能推测如下

| 文件名                     | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| ability shell_ide_java.jar | Java版的ability应用框架，PageSlice等                         |
| ace_ide_java.jar           | aceUI层框架。ace框架在android上搭建一个类似微信小程序的运行环境，用来运行卡片式应用。 |
| ohos.jar                   | open harmony 基础库，包含rpc等                               |
| ohos-annotations.jar       | java sdk用到的注解                                           |
| ohos_intellitv.jar         | 智能电视相关                                                 |
| ohos_ivi.jar               | 车载相关的代码                                               |
| ohos_wearable.jar          | 穿戴式应用代码                                               |

Java应用解压后的产物如下：

{% include image.html img="app_detail_2.png" attr="width:100%;" %}

这些文件的作用如下：

| 文件                         | 描述                                 |
| :--------------------------- | :----------------------------------- |
| config.json                  | 应用配置文件                         |
| assets/*                     | 资源文件                             |
| classes.dex                  | 编译后的鸿蒙应用程序代码             |
| entry_debug_signed_entry.apk | 安卓的壳，用来运行鸿蒙App即class.dex |

Java应用起来后用MainAbilityShellActivity承载，根据反编译后的壳代码分析，主要由HarmonyApplication完成对ability应用运行环境的初始化。

{% include image.html img="app_detail_3.png" attr="width:100%;" %}

Java应用布局文件及显示效果如下图：

{% include image.html img="app_detail_4.png" attr="width:100%;" %}

dump出UI的绘制方式(adb shell uiautomator dump)，可以看到鸿蒙虽然定义了一套应用开发的DSL，但绘制部分还是用Android的UI控件来承载，非自绘UI。

{% highlight xml %}
<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<hierarchy rotation="0">
 <node index="0" text="" resource-id="" class="android.widget.FrameLayout" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,0][1176,2328]">
 <node index="0" text="" resource-id="android:id/decor_content_parent" class="android.view.ViewGroup" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,0][1176,2328]">
 <node index="0" text="" resource-id="android:id/action_bar_container" class="android.widget.FrameLayout" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,72][1176,240]">
 <node index="0" text="" resource-id="android:id/action_bar" class="android.view.ViewGroup" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,72][1176,240]">
 <node index="0" text="entry_MainAbility" resource-id="" class="android.widget.TextView" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[48,115][528,196]" /></node>
 </node>
 <node index="1" text="" resource-id="android:id/content" class="android.widget.FrameLayout" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,240][1176,2328]">
 <node index="0" text="" resource-id="" class="android.view.ViewGroup" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,240][1176,2328]">
 <node index="0" text="你好，世界" resource-id="" class="android.widget.TextView" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[288,1160][888,1320]" />
 <node index="1" text="javaApp" resource-id="" class="android.widget.TextView" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[366,1320][809,1480]" /></node>
 </node>
 </node>
 <node index="1" text="" resource-id="android:id/statusBarBackground" class="android.view.View" package="com.michalliu.myapplication" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,0][1176,72]" /></node>
</hierarchy>
{% endhighlight%}

由此可以看出，鸿蒙Android版要脱离Android体系难度还比较高，毕竟核心的UI部分非自绘。

Java应用的运行环境示意图：

{% include image.html img="app_detail_5.png" attr="width:100%;" %}

这里理解鸿蒙Android从设计上更类似QT跟Windows的关系，可以理解为在Android操作系统的基础上搭了一套自己的应用程序框架。

{% include image.html img="app_detail_6.png" attr="width:100%;" %}

目前鸿蒙是跟Android深度绑定的，鸿蒙切换操作系统的可能性不是完全没有，但成本相当高，应该说鸿蒙Android的这个设计思路是既然摆脱不了安卓，基于这个前提，那么就充分利用它。

### **3.2、Js应用**

从目前已经开源出来的部分上来看基于js开发的应用是一种类似小程序的开发方式，html,js,css首先会编译成jsbundle（编译工具本身未开源），jsbundle的执行不同的鸿蒙系统上有所区别。

- Js应用在鸿蒙嵌入式系统上执行分析

经过对openharmony代码分析，在openharmony里Js应用是以自绘的方式渲染，支持的UI组件看起来还比较完善（从源码里看绘制部分似乎参考了部分flutter代码），使用三星的Jerry Js引擎，猜测是挖的三星的人？因为这个Js引擎实在太小众，Google V8他不香吗？

UI组件框架在 [ace_engine_lite ](https://gitee.com/openharmony/ace_engine_lite)里，从开源的代码我们看出支持的UI组件还比较丰富，除了常规的控件，还包含列表，动画等复杂控件的实现。

{% include image.html img="app_detail_7.png" attr="width:100%;" %}

ace_engine_lite 负责维护UI组件的生命周期，事件通信，数据更新等，是逻辑层

{% include image.html img="app_detail_8.png" attr="width:100%;" %}

UI组件的显示层在 [graphic_ui ](https://gitee.com/openharmony/graphic_ui)工程中，例如下图为UIButton绘制的实现：
{% include image.html img="app_detail_9.png" attr="width:100%;" %}

目前这个自绘的工程只有嵌入式的的实现，没有Android对应的实现。

实际在Android工程上，鸿蒙走的并不是自绘的方案，而是类似ReactNative的控件转换，ReactNative采用的是React的语法，而鸿蒙Android采用的是Vue的语法，从国内的开发者生态上来看，这是个正确的选择。

鸿蒙的这个用C++实现类[VUE](https://vuejs.org/)语法，在嵌入式上自绘，Android上控件转换的Js跨平台渲染框架属于原创，可惜的是鸿蒙Android这块并未开源，不能深入研究。

- Js应用在鸿蒙Android上执行分析

Js应用在鸿蒙Android上会转换成Android的UI控件，Js应用解压后的产物如下：

{% include image.html img="app_detail_10.png" attr="width:100%;" %}

这些文件的作用如下

| 文件                         | 描述                                 |
| :--------------------------- | :----------------------------------- |
| config.json                  | 应用配置文件                         |
| assets/*                     | ace框架jsbundle编译结果              |
| classes.dex                  | 主要是aceAbility用来执行jsbundle     |
| entry_debug_signed_entry.apk | 安卓的壳，用来运行鸿蒙App即class.dex |

对于Js应用来说核心逻辑由ohos.aafwk.ace.ability.AceAbility完成jsbundle的加载和运行工作。

（注意：虽然java应用和js应用在解压后目录结构似乎差不多，文件命名也差不多，但其工作原理完全不同。在Java应用里class.dex已经是鸿蒙应用的真正可执行代码。在js应用里class.dex还是一个壳，这个壳用于打造执行Js应用的运行环境，真正的业务逻辑在app.js里。)

js应用布局文件及显示效果:

{% include image.html img="app_detail_11.png" attr="width:100%;" %}

dump出UI的绘制方式，可以看到Js应用的UI绘制，在鸿蒙Android上是用Android的UI控件来承载，非自绘UI。

{% highlight xml %}
<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<hierarchy rotation="0">
 <node index="0" text="" resource-id="" class="android.widget.FrameLayout" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,0][1176,2328]">
 <node index="0" text="" resource-id="android:id/decor_content_parent" class="android.view.ViewGroup" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,0][1176,2328]">
 <node index="0" text="" resource-id="android:id/action_bar_container" class="android.widget.FrameLayout" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,72][1176,240]">
 <node index="0" text="" resource-id="android:id/action_bar" class="android.view.ViewGroup" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,72][1176,240]">
 <node index="0" text="entry_MainAbility" resource-id="" class="android.widget.TextView" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[48,115][528,196]" /></node>
 </node>
 <node index="1" text="" resource-id="android:id/content" class="android.widget.FrameLayout" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="false" enabled="true" focusable="false" focused="false" scrollable="false" long-clickable="false" password="false" selected="false" bounds="[0,240][1176,2328]">
 <node index="0" text="" resource-id="" class="android.view.ViewGroup" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="true" enabled="true" focusable="true" focused="false" scrollable="true" long-clickable="true" password="false" selected="false" bounds="[0,240][1176,2328]">
 <node index="0" text="您好 世界" resource-id="" class="android.widget.TextView" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="true" enabled="true" focusable="true" focused="false" scrollable="true" long-clickable="true" password="false" selected="false" bounds="[331,1173][844,1332]" />
 <node index="1" text="Js Application" resource-id="" class="android.widget.TextView" package="com.example.myapplicationjs" content-desc="" checkable="false" checked="false" clickable="true" enabled="true" focusable="true" focused="false" scrollable="true" long-clickable="true" password="false" selected="false" bounds="[301,1347][874,1452]" /></node>
 </node>
 </node>
 </node>
</hierarchy>
{% endhighlight%}

鸿蒙应用层在设计上，基于自己的DSL和应用运行框架，在嵌入式设备上以自绘的方式渲染，在鸿蒙Android上通过适配层转换为Android原生控件渲染。这样的设计优势是减轻了工作量，组件方面可以复用Android的生态，能力会更丰富，毕竟从零再打造一套完整且庞大的UI体系成本太高，体验还不一定有Android做的好，而劣势则是牺牲了可维护性，两套方案要各自独立维护，维护成本较高，另外还可能带来兼容性的问题。从openharmony源码上看，基于自绘方案并没有预留给Android的扩展接口，targetos仅包含linux和liteos两种，因为渲染层架构不同，未来的改成一致的可能性也较低。

# 六、总结

鸿蒙OS并不定位于对Windows、Android进行替代，而是剑指万物互联时代全场景、多终端的操作系统，与此相对应，鸿蒙OS（及大华为体系）所有的生态布局也将围绕万物互联展开。鸿蒙OS在完成细分场景的拓展与跑马圈地后，鸿蒙OS将完善华为AIoT生态，进一步在智慧城市、车联网（深化）、工业互联网三方面发力推进。中长期来看，鸿蒙OS与华为“云+端”芯片形成强大合力，进军产业物联网。华为优质网络设备是IoT的连接基础，连接获得了大量数据，但只有通过智能分析才能够形成杀手级应用。华为已在云侧和端测拥有昇腾、鲲鹏、麒麟等芯片，具备强大算力，叠加鸿蒙OS高效、灵活的执行力，将培育大量高价值应用。基于近景和远景的生态蓝图，当前鸿蒙OS的发力抓手仍是以移动端为核心的HMS产业链。

{% include image.html img="eco_system.png" attr="width:100%;" %}