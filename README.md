# Emotion-Diary-iOS

Emotion Diary is a lightweight personal diary APP focused on privacy and convenience. Based on the technology of face identification, users can use their face as the key to open the APP. At the same time the smile on your face can also be detected and used as the realtime emotional information, which will be part of their diary notes. After days of recording, you can review your statistics of your emotions, as well as your meaningful life.

## 开发者

* 范志康

## 配置与运行

* 从 GitHub 上下载整个项目
* 打开 `Emotion Diary.xcworkspace`
* 将 `APIKey+APISecret.sample.h` 文件复制为 `APIKey+APISecret.h` 添加进项目中
* 向开发者索取 `API_KEY` 和 `API_SECRET`
* 运行程序

## 重要类说明

#### `ActionPerformer`

* 用于执行一些网络和本地动作，所有函数均为类函数，网络动作使用 block 与其它函数通讯
* 总体上分为服务器通讯模块，人脸识别模块，本地功能模块

#### `Utilities`

* 用于实现一些常用的功能，例如加密处理，图片处理等
* 具体功能在注释中有详细说明

## 第三方库说明

* `AFNetworking` 网络库，用于与服务器的通信
* `KVNProgress` 进度指示器库，用于用户交互的提示
* `FSCalendar` 日历库，用于主界面的日历显示
* `BEMSimpleLineGraph` 图表库，用于统计界面的统计图
* `SDWebImage` 网络图片库，用于日记的头像和图片的加载和显示
* `CTAssetsPickerController` 照片选择库，用于记录日记界面选择图片
* `MWPhotoBrowser` 照片浏览库，用于记录日记和查看日记界面的图片浏览