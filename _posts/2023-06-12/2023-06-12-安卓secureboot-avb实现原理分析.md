---
layout: post
title: 安卓SecureBoot AVB实现原理分析
categories: [Tech]
tags:
    - Android
---

安卓的SecureBoot机制（Google官方叫Verified Boot）实现了完整的信任链，保护了系统完整性和合法性。先让AI帮我们介绍下，来自ChatGPT(4.0) 的回答如下：

>Q：介绍Andorid verify boot流程，从CPU上电开始，一步一步的介绍，以安卓4.4为例，暂不考虑安卓7.0以上的系统。
>
>A：Android 4.4（KitKat）的验证启动流程（Verify Boot）主要是为了确保设备在启动过程中加载和执行的代码和数据的完整性和安全性。以下是从CPU上电开始的详细步骤：
>
>1. 上电：当设备上电时，CPU从预定义的地址开始执行代码。这个地址通常是只读存储器（ROM）中的一个固定位置，包含了引导加载程序（Bootloader）的第一阶段。
>2. Boot ROM：Boot ROM是一个只读存储器，包含了一些基本的硬件初始化代码和安全引导代码。它首先执行硬件初始化，然后验证Bootloader的签名。
>3. Bootloader：Bootloader是一个小型程序，负责加载和启动Android操作系统。在Android 4.4中，Bootloader分为两个阶段：Primary Bootloader（PBL）和Secondary Bootloader（SBL）。
>a. Primary Bootloader（PBL）：PBL是Boot ROM加载的第一个程序，它负责初始化关键硬件组件（如处理器、内存控制器等），并验证SBL的签名。
>b. Secondary Bootloader（SBL）：SBL负责初始化更多的硬件组件（如显示、USB等），并验证Android Boot Image（包括内核和ramdisk）的签名。
>4. Android Boot Image：Android Boot Image包含了Linux内核、设备树（Device Tree）和ramdisk。SBL验证Boot Image的签名后，将内核和设备树加载到内存中，并启动内核。
>5. Linux内核启动：内核启动后，会解压缩并挂载ramdisk，然后执行init进程。init进程负责启动Android系统的其他关键组件，如Zygote、System Server等。
>6. dm-verity：Android 4.4引入了dm-verity，一种基于Merkle树的只读文件系统完整性检查机制。在系统启动过程中，init进程会启动dm-verity，确保/system分区的完整性。
>7. Android系统启动：在完成以上步骤后，Android系统将继续启动其他服务和应用程序，最终呈现给用户一个可操作的界面。
>总结：Android 4.4的验证启动流程从CPU上电开始，通过多个阶段确保设备启动过程中的代码和数据的完整性和安全性。这些阶段包括Boot ROM、Bootloader（PBL和SBL）、Android Boot Image、Linux内核启动和dm-verity。

我们看到，AI的“理解”和总结还是比较到位的。那么究竟具体是什么实现的呢，我们来结合代码展开简要分析一下其实现细节。

## 背景知识

1、 **OTP （One-Time Programmable）** 一次性烧写，在PCB生产阶段，我们会把公钥的哈希，写入硬件的OTP区域。

2、 **数字签名**：
数字签名是一种用于验证消息来源和完整性的技术，它使用公钥加密和哈希函数来实现。
1. 签名过程：<br/>
1、发送方使用哈希函数对消息进行哈希，得到消息的哈希值。<br/>
2、发送方使用自己的私钥对哈希值进行加密，得到数字签名。<br/>
3、发送方将消息和数字签名一起发送给接收方。<br/>
2. 验签过程：<br/>
1、接收方使用发送方的公钥对数字签名进行解密，得到哈希值。<br/>
2、接收方使用哈希函数对消息进行哈希，得到消息的哈希值。<br/>
3、接收方比较两个哈希值是否相等，如果相等，则说明消息来源可信且完整。

在数字签名的过程中，哈希函数用于保证消息的完整性，而公钥加密用于保证消息的来源可信。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/image_signature.png" attr="width:100%;" caption="Image Signing Verification" %}
## SecureBoot流程
在硬件上OTP区域，我们会写入一个密钥的哈希，也就是所谓的信任根。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/otp.png" attr="width:100%;" caption="Hardware OTP" %}

第一阶段：CPU上电
----------
按下电源按钮，CPU上电，首先进入Soc ROM，SocROM是固化在CPU里的一段代码，其流程是固定的，无法修改。

Soc ROM负责校验下一阶段bootloader的合法性与完整性。

其流程如下：
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/soc_rom_procedure.png" attr="width:100%;" caption="Soc ROM procedure" %}

从上述流程我们可以看到：
1. 首先系统确保了public key与CPU里固化的期望的public key是一致的，否则直接拒绝启动。
2. 其次在系统打包的时候，我们使用与public key对应的私钥，对uboot镜像进行了数字签名，Soc ROM的流程会对签名进行校验，校验不通过也拒绝启动。

由于数字签名无法伪造，这就确保了uboot的代码是可信且完整的（由哈希值来保证），至此第一阶段的信任链结束，系统开始执行uboot的代码。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/torvalds_talk-is-cheap-show-me-the-code.png" attr="width:100%;" %}

关键流程代码：
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/uboot_1.png" attr="width:100%;" %}
校验签名的代码：
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/uboot_2.png" attr="width:100%;" %}

第二阶段：uboot
------------

uboot负责引导启动Linux内核，Linux内核与initramfs通常会一起打包在boot.img里。
第二阶段的启动流程跟第一阶段是非常类似的，其流程如下：

1. uboot读取上个流程传入的public key。
2. 校验该public key的哈希值是否与CPU里OTP存储的一致，不一致则启动失败。
3. 校验boot.img的数字签名得到哈希值是否与实际数据一致，不一致则启动失败。

uboot引导启动流程如下图：
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/uboot_3.png" attr="width:100%;" %}

我们从**boot_img_hdr**结构体中，可以看到uboot对boot.img的描述中，包含boot.img的签名信息。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/uboot_4.png" attr="width:100%;" %}

第三阶段：linux内核
------------
Linux内核负责启动rootfs的的第一个进程，即进程ID为1的init进程，是Linux系统中所有进程的父进程，再根据系统配置(init.rc文件)，把整个系统启动起来，最主要的是需要校验打包了rootfs的system.img。

到了这里事情就有点复杂了，因为uboot的镜像，以及linux内核的镜像一般体积比较小，可以直接计算哈希值，跟数字签名比对。但是system镜像一般数G大小，如采用一般的校验方法，比如挂载system.img前对system.img进行校验，会对系统的启动速度，以及性能造成影响。

那么有没有一种方案，不需要在系统挂载前校验，而是用到那个校验那个？答案是：有的。
安卓从4.4开始，在这里使用了Linux内核提供的dm-verity(device-mappper-verity)机制，以下简称DM-V。

DM-V这里用了一种[默克尔树](https://en.wikipedia.org/wiki/Merkle_tree)的数据结构，把固件镜像进行4K大小的切分，并对每个4K数据片进行hash计算，迭代多层，并生成对应的哈希树(30M以内)以及root hash。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/dmv.png" attr="width:100%;" caption="Merkle Tree" %}

举个例子，以1G的镜像为例：
1. 按照4k的大小划分，1G的镜像我们可以得到262144个4k大小的块，
2. 对这262144个块进行第一层(LAYER 0)的哈希计算，以SHA256为例，每个块计算出来的哈希值为256位即32字节，共占8M的内存空间(262144*32)，即2048个4K的块
3. 对第一层存储hash值的数据块进行第二层的计算(LAYER 1)，同理，第二层需要64K的内存空间，即16个4K的块
4. 对第二层存储hash值的数据块进行第三层的计算(LAYER 2)，同理，第三层需要512个字节，不足一个块，补0后直接得出 root hash，第三层即为最后一层。

我们只需要对root hash进行签名，并保存在system.img中。System分区的布局如下（简化版），可以看到除了system数据块之外，还有public key以及HashTree等信息，其中public key是与boot.img共享的。
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/system_image_partition.png" attr="width:100%;"  %}

创建基于DM-V机制的虚拟分区后，如有数据被访问时，会对数据所在的4K区块单独进行Hash校验，当校验出错，则返回IO错误，就像文件系统损坏一样。其过程，大致如下图所示：
{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/dmv_procedure.png" attr="width:100%;"  %}

DM-V机制适用于任意文件系统，但限制是该文件系统为只读文件系统，优点是固件越大，效果越明显，与读取文件的IO操作相比，DM-V引入的校验机制带来的耗时，hashtree层数较矮，且计算速度很快，其影响可以忽略，总体来说，该方法利大于弊。

但注意使用DM-V机制的一个前提是boot.img必须保证安全，boot.img中除了包含Linux内核，还包含一个ramdisk，ramdisk可以理解为一个非常精简的rootfs，包含dmsetup,veritysetup等工具，用于支持DM-V机制，这个由上一阶段的加载流程保证安全。

## 总结
综上所述，安卓上Secure Boot流程可以总结为：

1. Soc ROM校验引导启动uboot。
2. uboot校验boot.img，启动linux内核及ramfs。
3. Linux内核使用device-mapper-verity机制校验system.img，加载rootfs。 

以上一系列软硬结合的机制，完成了从硬件->bootloader->linux内核->文件系统的逐级信任链校验过程，保证了安卓系统ROM的完整性与合法性。

本文只是介绍了AVB（**A**nroid  **V**erified **B**oot）的核心机制，真正完整的流程还是复杂的，请参考Google的官方文档，随着安卓的发展，系统的安全机制也在不断的变化，从AVB 1.0 进化到AVB 2.0，不过万变不离其宗，核心的还是本文介绍的这些机制，并没有太大的改变。

{% include image.html img="2023-06-12-安卓secureboot-avb实现原理分析.assets/verified-boot-flow.png" attr="width:100%;"  caption="Android Verified Boot Flow" %}

### 参考文献
1. [Verified Boot](https://source.android.com/docs/security/features/verifiedboot ) 
2. [默克尔树](https://en.wikipedia.org/wiki/Merkle_tree)