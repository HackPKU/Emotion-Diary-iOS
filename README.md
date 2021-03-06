# Emotion-Diary-iOS

Emotion Diary is a lightweight personal diary APP focused on privacy and convenience. Based on the technology of face identification, users can use their face as the key to open the APP. At the same time the smile on your face can also be detected and used as the realtime emotional information, which will be part of their diary notes. After days of recording, you can review your statistics of your emotions, as well as your meaningful life.

## 功能与特点

* 自拍或者 Touch ID 解锁，App 进入后台后自动锁定
* 人脸识别得出心情指数
* 可以本地使用或者在线使用，两者功能独立，也可互通数据
* 以日历方式或者时间线方式查看日记
* 支持用户注册、登录、登出、修改个人信息
* 登录后，无网络情况下也可查看日记的本地缓存版本
* 支持分享日记，分享后将创建公开链接
* 用户体验完善，支持 3D Touch

## 创新之处

* 人脸识别，自拍解锁 App
* 可分别作为本地 App 和在线 App 使用
* 可查看心情的变化统计

## 使用说明

<img src="Docs/流程.png" alt="流程" width="400">

* 打开 App，点击 Logo 自拍解锁
* 记录日记（或者直接进入主界面）
 * 人脸识别出心情值（可手动调整）
 * 键入正文，选择图片
* 主界面可以在日历上查看每天的日记

<img src="Docs/解锁.PNG" alt="解锁" width="200">
<img src="Docs/记录心情.PNG" alt="记录心情" width="200">
<img src="Docs/主界面.PNG" alt="主界面" width="200">

* 日记详情界面
 * 可以查看正文和图片等
 * 删除和分享日记
* 时间线界面
 * 按时间顺序查看所有日记

<img src="Docs/日记详情.PNG" alt="日记详情" width="200">
<img src="Docs/时间线.PNG" alt="时间线" width="200">
<img src="Docs/心情统计.PNG" alt="心情统计" width="200">

* 心情统计界面
 * 查看一周或一月的心情统计
 * 账户管理：注册、登录、登出、修改个人信息
 * 分享管理（需要登录）：删除或者取消分享
 * 上传管理（需要登录）：开始或停止上传
 * 软件设置
 * 查看软件信息

<img src="Docs/账户.PNG" alt="账户" width="200">
<img src="Docs/分享管理.PNG" alt="分享管理" width="200">
<img src="Docs/上传管理.PNG" alt="上传管理" width="200">

## 尚未实现的功能

* 搜索日记功能
* 日记中附带地点、天气、标签信息
* 忘记密码功能（服务器尚未实现）
* 更优美的分享网页（服务器尚未实现）

## 配置与运行

* 从 GitHub 上下载整个项目
* 打开 `Emotion Diary.xcworkspace`
* 将 `FaceppSDK_ARC` 文件夹下的 `APIKey+APISecret.sample.h` 文件复制为 `APIKey+APISecret.h` 添加进项目中
* 向开发者索取 `API_KEY` 和 `API_SECRET` 填入 `APIKey+APISecret.h`
* 编译并运行程序

> `DEBUG` 模式下，日志和网络错误会被详细地输出，可在 `Emotion Diary-Prefix.pch` 中取消定义 `DEBUG` 模式

> 在 `DEBUG` 模式以及宏定义了 `DEBUG_IMAGE` 的情况下，进入 App 无需自拍自动解锁以方便测试，进入后台恢复后会自动退出验证界面，任意选择照片后会被替换为 `DEBUG_IMAGE`，该宏定义可在 `WelcomeViewController.m` 中修改或去除

> 在 `DEBUG` 模式以及宏定义了 `LOCALHOST` 的情况下，使用 localhost 调试程序，如果需要使用在线的服务器，请在 `ActionPerformer.m` 中取消定义 `LOCALHOST`

## 已测试平台

* 环境：
 * OS X El Capitan 10.11.4 +
 * Xcode 7.3 +
 * CocoaPods 1.0.0 +
* 运行：
 * iOS 8.4 模拟器（iPhone + iPad）
 * iOS 9.0 模拟器（iPhone + iPad）
 * iOS 9.3 真机（iPhone） + 模拟器（iPhone + iPad）

## 可能的问题

* 模拟器经常会输出 `KVNProgress` 的警告，是因为提示状态变化太快，前一个状态的显示时间未到默认的最短时间，该警告可忽略
* 发邮件反馈在模拟器上可能无法打开并提示 `MailCompositionService` 意外退出，这是模拟器的 Bug，真机上不会出现
* 日记正文如果有电话、网站、邮件等，在 iOS9 系统下长按不会跳出对话框，并且模拟器会输出警告，回到 RootViewController 后对话框才出现，这是 iOS9 系统的 Bug，目前没有较好的解决方案

## 主要进度记录

* 2016/04/25 完成功能构思和UI、图标设计
* 2016/04/29 完成服务器基本 API 的编写
* 2016/05/03 完成本地日记 App 的基本功能
* 2016/05/09 完成注册和登录功能
* 2016/05/14 完成日记上传和同步功能
* 2016/05/15 使用 CocoaPods 1.0.0 新版本
* 2016/05/20 完成日记的分享和自动上传功能
* 2016/05/22 完成编辑用户信息功能
* 2016/06/01 完成用户引导提示界面
* 2016/06/14 修复一系列 Bug，提升程序稳定性

## 重要类说明

#### `EmotionDiary`

* 日记类，遵循 `NSCoding` 协议，可实现对本地和在线日记的封装、存储、读取、上传、删除等管理

#### `EmotionDiaryManager`

* 考虑到用户使用后日记数量可能很多，每次都从磁盘读取日记数据会导致极低的效率，因此建立一个专门的管理类用于大量日记数据的处理
* 使用单例模式 `sharedManager`，该单例有一个内存中的 `diaries` 变量，与 `NSUserDefaults` 保持同步，可以极大地提高查询的效率
* 完成获取心情的统计数据功能
* 完成对本地和在线日记的记录
* 完成日记的同步功能

#### `ActionPerformer`

* 用于执行一些网络和本地动作，所有函数均为类函数，网络部分使用 block 与其它函数通讯
* 总体上分为服务器通讯模块，面部识别模块，本地功能模块

#### `Utilities`

* 用于实现一些常用的功能，例如加密、验证、图片处理、文件管理等，所有函数均为类函数
* 具体功能在注释中有详细说明

## 第三方库说明

* `AFNetworking` 网络库，用于与服务器的通信
* `KVNProgress` 进度指示器库，用于用户交互的提示
* `FSCalendar` 日历库，用于主界面的日历显示
* `BEMSimpleLineGraph` 图表库，用于统计界面的统计图
* `SDWebImage` 网络图片库，用于头像和图片的加载和显示
* `CTAssetsPickerController` 照片选择库，用于记录日记界面选择图片
* `MWPhotoBrowser` 照片浏览库，用于多个界面的图片浏览
* `ZYBannerView` 照片轮播器，用于查看日记界面的图片轮播

## 服务器端

* [GitHub链接及服务器配置文档](https://github.com/HackPKU/Emotion-Diary-Web)
* [API文档](https://github.com/HackPKU/Emotion-Diary-Web/tree/master/api)

## 感谢支持开发者！

<img src="Docs/捐助.JPG" alt="捐助" width="200">