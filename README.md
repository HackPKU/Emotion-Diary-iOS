# Emotion-Diary-iOS

Emotion Diary is a lightweight personal diary APP focused on privacy and convenience. Based on the technology of face identification, users can use their face as the key to open the APP. At the same time the smile on your face can also be detected and used as the realtime emotional information, which will be part of their diary notes. After days of recording, you can review your statistics of your emotions, as well as your meaningful life.

## 开发者

* 范志康

## 配置与运行

* 从 GitHub 上下载整个项目
* 打开 `Emotion Diary.xcworkspace`
* 将 `FaceppSDK_ARC` 文件夹下的 `APIKey+APISecret.sample.h` 文件复制为 `APIKey+APISecret.h` 添加进项目中
* 向开发者索取 `API_KEY` 和 `API_SECRET` 填入 `APIKey+APISecret.h`
* 编译并运行程序

> 在 DEBUG 模式下，进入 App 无需自拍自动解锁以方便测试，任意选择照片后会被替换为 `DEBUG_IMAGE`，该图片可在 `WelcomeViewController` 中修改

## 主要进度记录

* 2016/04/25 完成功能构思和UI、图标概念设计
* 2016/04/29 完成服务器 API 的编写
* 2016/05/02 完成本地日记 App 的功能

## 重要类说明

#### `EmotionDiary`

* 日记类，遵循 `NSCoding` 协议，可实现对本地和在线日记的封装和存储

#### `EmotionDiaryManager`

* 考虑到用户使用后日记数量可能很多，每次都从磁盘读取日记数据会导致极低的效率，因此建立一个专门的管理类用于大量日记数据的处理
* 使用单例模式 `sharedManager`
* 完成获取心情的统计数据功能，单例有一个内存中的 `diaries` 变量，与 `NSUserDefaults` 保持同步，可以极大地提高查询的效率
* 完成对本地和在线单篇日记的存储

#### `ActionPerformer`

* 用于执行一些网络和本地动作，所有函数均为类函数，网络动作使用 block 与其它函数通讯
* 总体上分为服务器通讯模块，人脸识别模块，本地功能模块

#### `Utilities`

* 用于实现一些常用的功能，例如加密，图片处理，文件管理等
* 具体功能在注释中有详细说明

## 第三方库说明

* `AFNetworking` 网络库，用于与服务器的通信
* `KVNProgress` 进度指示器库，用于用户交互的提示
* `FSCalendar` 日历库，用于主界面的日历显示
* `BEMSimpleLineGraph` 图表库，用于统计界面的统计图
* `SDWebImage` 网络图片库，用于日记的头像和图片的加载和显示
* `CTAssetsPickerController` 照片选择库，用于记录日记界面选择图片
* `MWPhotoBrowser` 照片浏览库，用于记录日记和查看日记界面的图片浏览