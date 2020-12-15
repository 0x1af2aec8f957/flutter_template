# flutter-template

#### 目录结构

```bash
.
├── README.md # 目录描述文件
├── assets # 静态资源存放目录
│   ├── README.md # 目录自述文件
│   ├── fonts # 字体文件存放
│   │   └── iconfont.ttf # icon字体库
│   ├── images # 图片文件存放
│   │   ├── 2.0x
│   │   │   ├── flutter_background.png
│   │   │   └── no_data.png
│   │   ├── 3.0x
│   │   │   ├── flutter_background.png
│   │   │   └── no_data.png
│   │   ├── flutter_background.png
│   │   └── no_data.png
│   ├── json # json文件
│   │   └── country_code.json
│   └── locale # 国际化配合文件(文件解析逻辑翻译自Vue.i18n)
│       ├── common.yaml
│       └── home.yaml
├── flutter_template.iml # flutetr资源描述文件
├── lib # 主要的业务代码存放
│   ├── api # api文件模块存放
│   │   ├── README.md
│   │   └── test.dart
│   ├── components # 公用组件存放
│   │   ├── CustomFlatButton.dart # 自定义按钮组件
│   │   ├── CustomScrollBar.dart # 自定义滚动组件
│   │   ├── CustomWebView.dart # 自定义webview组件，支持jockey协议
│   │   ├── NativeAppBar.dart # 自定义AppBar组件，支持原生嵌套flutter项目自动判断路由历史栈堆长度
│   │   ├── NoData.dart # 无数据组件
│   │   ├── README.md # 自述文件
│   │   ├── SliderLess.dart # 百分比滑块组件
│   │   └── WebView.dart # 普通的webview，不包含任何协议
│   ├── lang # 国际化配置
│   │   └── i18n.dart # 国际化设置相关
│   ├── main.dart # 程序入口文件
│   ├── mixins # mixins混入组件
│   │   └── README.md # 自述文件
│   ├── models # provider数据管理model存放
│   │   ├── README.md # 自述文件
│   │   ├── count.dart # model局部示例
│   │   └── global.dart # model全局示例
│   ├── plugins # 自定义插件
│   │   ├── README.md # 自述文件
│   │   ├── dateFormat.dart # 时间格式化
│   │   ├── eventEmitter.dart # event全局事件
│   │   ├── http.dart # http模块封装，基于Dio二次封装
│   │   ├── jockey.dart # jockey协议实现
│   │   ├── mqtt.dart # mqtt协议实现
│   │   ├── screenUtil.dart # 屏幕自适应方案实现
│   │   ├── signer.dart # 接口或数据签名实现
│   │   └── smallProgram.dart # 小程序实现
│   ├── routes.dart # 路由配置文件
│   ├── setup # 主要的程序配置文件
│   │   ├── README.md # 自述文件
│   │   ├── config.dart # App配置文件
│   │   ├── lang.dart # 多语言配置文件
│   │   ├── providers.dart # provider的model集成汇总
│   │   └── router.dart # 全局的router实现
│   ├── template # 模板代码
│   │   └── README.md # 自述文件
│   ├── theme # 主题文件
│   │   └── index.dart # 主题切换基类
│   ├── utils # 常用方法
│   │   ├── README.md # 自述文件
│   │   ├── common.dart # 公用方法
│   │   ├── constant.dart # 常量
│   │   ├── dialog.dart # 弹窗
│   │   ├── iconFont.dart # 项目中的iconFont
│   │   └── types.d.dart # 常用的类型申明
│   └── views # 页面组件(已存放部分示例页面组件)
│       ├── About.dart
│       ├── ApplicationDir.dart
│       ├── Browser.dart
│       ├── Count.dart
│       ├── CustomCachedNetworkImage.dart
│       ├── Example.dart
│       ├── FormTest.dart
│       ├── FullScreen.dart
│       ├── Home
│       │   ├── Drawer.dart
│       │   ├── Index.dart
│       │   ├── View1.dart
│       │   ├── View2.dart
│       │   └── View3.dart
│       ├── LoadingJson.dart
│       ├── README.md
│       ├── SmallProgramTest.dart
│       ├── SubRouter.dart
│       └── Transform.dart
├── pubspec.yaml # flutter配置文件
└── test # 单元测试
    └── widget_test.dart
```

#### 配置文件文档参考地址

1. [添加依赖包](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
2. [静态资源打包](https://flutter.dev/docs/development/ui/assets-and-images)

#### 模板中使用到的技术栈

1. [国际化](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)，官方文档只有基础资源加载实现，在模板中有完整的全局应用切换实现
2. [iconFont](https://pub.dev/packages/cupertino_icons)，本模板有附加的自定义iconFont完整实现
3. [webView](https://pub.dev/packages/webview_flutter)，本模板中附加jockey通讯协议完整实现
4. [计算精度](https://pub.dev/packages/calculate)，该库由本模板作者书写提供，如由问题可直接在模板仓库中提交`issue`
5. [图片缓存](https://pub.dev/packages/cached_network_image)
6. [应用程序目录](https://pub.dev/packages/path_provider)，模板中大量实现依赖此库，如小程序就非常依赖该库
7. [http请求](https://pub.dev/packages/dio)
8. [数据持久化](https://pub.dev/packages/shared_preferences)，模板中多个场景都在使用，如国际化中记住语言选择会依赖
9. [App包信息](https://pub.dev/packages/package_info)，模板中的应用程序升级功能依赖此包进行版本对照
10. [yaml解析器](https://pub.dev/packages/yaml)，模板中大部分配置文件都需要它提供解析支持，比如国际化支持
11. [内存文件系统](https://pub.dev/packages/file)
12. [encrypt](https://pub.dev/packages/encrypt)，模板中涉及数据加解密都依赖此库提供的数据计算支持，模板中实现的接口动态加解密就依赖此库，模板中基于它实现完整的加密生命周期
13. [(解)压缩](https://pub.dev/packages/archive)，模板中小程序实现依赖此库
14. [安卓动态权限请求](https://pub.dev/packages/permission_handler)
15. [web服务](https://pub.dev/packages/shelf)，模板中涉及启动服务的地方都依赖此库
16. [web服务的静态资源中间件](https://pub.dev/packages/shelf_static)
17. [数据管理](https://pub.dev/packages/provider)，模板中的数据和视图层均为分开状态

#### 模板中独有的技术栈

1. 时间格式化
2. 全局事件总栈
3. jockey通讯协议
4. 样式数字跟随屏幕自适应大小
5. 数据签名
6. 小程序（H5服务模式）
7. 全局对话框（涵盖弹窗及提示等，无键盘遮挡相关问题）
8. 全局国际化
9. 原生嵌套与独立应用通讯（包括路由跳转、国际化等）
10. 全局主题切换
11. 自定义iconFont
12. 自定义受控`Button`视图组件
13. 自定义无数据状态
14. 自定义滚动组件（包含下来刷新、上拉加载更多）
15. 自定义`AppBar`视图组件，该组件可供原生嵌套与本地独立包的返回等功能产生的行为一致
16. 自定义滑块进度组件

#### 扩展构建桌面应用（开发移动平台的项目请跳过此处）

> 项目模板基础功能支持在桌面环境运行（如：全局的路由、国际化、数据存储、网络请求、数据签名等）

```bash
flutter channel dev # 桌面应用支持仍处于实验环节中
flutter upgrade # 确保你的flutter是最新版本
flutter config --enable-windows-desktop # 添加对Windows桌面的支持
flutter config --enable-macos-desktop # 添加对MacOS桌面的支持
flutter config --enable-linux-desktop # 添加对Linux桌面的支持
```

```bash
flutter devices # 通过该命令查看你的桌面设备是否出现在列表中，如果没有请运行 `flutter doctor` 排查错误
```

#### 使用说明

> 通过[flutter.dev-doc](https://flutter.dev/docs/get-started/install)教程安装flutter，建议选择`stable`通道。

> 模板中存在常用的方法封装，可直接使用。

> 模板结构同[vue-template](http://192.168.100.214:5580/quanchuan/vue-template)一样，包含国际化等配置文件、路由解析及使用方法均一致。

```bash
git clone ssh://git@192.168.100.214:5522/quanchuan/flutter-template.git flutter_template # 需要重命名至flutter_template命名空间才能符合规范
flutter create . # 创建android、ios原生仓库目录，模板中某些示例需要文件、http网络等权限的支持，请分别在文件`AndroidManifest.xml`及`Info.plist`中配置权限
flutter pub get # 安装依赖
flutter run # 运行项目，需要设备支持(可通过`flutter devices`获取设备列表)
```

#### 无法摆脱的意外

在Android上执行`flutter build apk`，在当前仓库上传时的最新`flutter`版本有致命的`BUG`，但官方尚未修复。

```bash
This application cannot tree shake icons fonts. It has non-constant instances of IconData at the following locations:
...文件地址
```

通过增加选项`--no-tree-shake-icons`获得临时解决方案(这将不会分析iconFontData的数据)。
```bash
flutter build apk --no-tree-shake-icons
```