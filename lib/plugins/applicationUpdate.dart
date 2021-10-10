import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pub_semver/pub_semver.dart' show Version;

import '../setup/config.dart';
import '../utils/dialog.dart';

final BuildContext globalContext = AppConfig.navigatorKey.currentState.overlay.context;
/// 应用版本更新
abstract class AppUpgrade {
  static bool _isInit = false; // 是否已经完成初始化
  /// 设备版本更新时需要初始化的，在这里进行初始化
  static Future<void> init() async { // 初始化，注意是异步方法
    if (_isInit) return; // 已经初始化完成

    if (Platform.isAndroid){ // 安卓升级插件 FlutterXUpdate，初始化
      await FlutterXUpdate.init(
        ///是否输出日志
          debug: !AppConfig.isProduction,
          ///是否使用post请求
          isPost: false,
          ///post请求是否是上传json
          isPostJson: true,
          ///是否开启自动模式
          isWifiOnly: false,
          ///是否开启自动模式
          isAutoMode: false,
          ///需要设置的公共参数
          supportSilentInstall: false,
          ///在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
          enableRetry: false
      ).catchError((error){
        Talk.toast(error);
      });

      FlutterXUpdate.setUpdateHandler(
          onUpdateError: (Map<String, dynamic> message)async {
            if (message["code"] == 4000) Talk.toast('下载失败');
          }/*,
            onUpdateParse: (String json) async {//这里是自定义json解析
              final AboutVersion remoteInfo = VersionDetails.fromJson(jsonDecode(json));
              final PackageInfo localeInfo = await AppConfig.packageInfo;
              return UpdateEntity(
                  hasUpdate: localeInfo.version != remoteInfo.version,
                  isIgnorable: !remoteInfo.cover,
                  versionCode: int.tryParse(localeInfo.buildNumber),
                  versionName: remoteInfo.version,
                  updateContent: remoteInfo.messages,
                  downloadUrl: remoteInfo.url,
                  apkSize: null
              );
            }*/
      );

      _isInit = true; // 初始化完成
    }
    // Talk.toast("设备暂不被支持更新");
  }

  static Future<bool> inspectCanUpdate(String version) async { // 检查应用是否需要更新
    final PackageInfo localeInfo = await AppConfig.packageInfo; // 应用包信息
    return Version.prioritize(Version.parse(version), Version.parse('${localeInfo.version}+${localeInfo.buildNumber}')) == 1; // 需要升级（远程发布的版本比本地版本高）
  }

  static Future<void> checkUpdate(version /* 远程版本 */, { // 检查版本并更新
    @required String link, // 下载链接
    String content = '修复已知BUG，优化应用体验', // 升级内容
    bool isForce = false, // 是否强制更新
    bool hasUpdateToast = false, // 是否使用弹框提示错误
    int packageSize, // 包大小
    String packageMd5, // 包MD5值
  }) async {
    final bool canUpdate = await inspectCanUpdate(version); // 需要升级（远程发布的版本比本地版本高）

    if(hasUpdateToast && !canUpdate){
      Talk.toast('没有新版本');
      return;
    }

    if (Platform.isAndroid) { // 安卓更新及更新提示
      androidUpdate(version, link: link, isForce: isForce, content: content);
      return;
    }

    if (Platform.isIOS && await canLaunch(link)){ // ios更新及更新提示
      iosUpdate(version, link: link, isForce: isForce, content: content);
      return;
    }

    Talk.toast('更新服务尚不支持你的设备，请及时下载最新版本的程序');
  }

  static Future<void> androidUpdate(String version, { // 安卓升级方法
    @required String content, // 升级内容
    @required String link, // 下载链接
    @required isForce // 是否强制升级
  }) async {
    final PackageInfo localeInfo = await AppConfig.packageInfo; // 应用包信息

    FlutterXUpdate.updateByInfo(updateEntity: UpdateEntity(
      hasUpdate: await inspectCanUpdate(version),
      versionCode: int.tryParse(localeInfo.buildNumber),
      versionName: version,
      updateContent: content,
      downloadUrl: link,
      isForce: isForce,
      // apkSize: apkSize,
      // isIgnorable: !isForce,
    ));
  }

  static Future<bool> iosUpdate(String version, { // ios升级方法
    @required content, // 升级内容
    @required String link, // 下载链接
    @required isForce // 是否强制升级
  }) async {
    if (!await inspectCanUpdate(version)) return false; // 不需要升级

    return showDialog<bool>(
      context: globalContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double constrainWidth = constraints.constrainWidth(); // 获取父元素约束宽度
                return Container(
                    padding: EdgeInsets.only(top: constrainWidth * 0.49),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                          image: AssetImage("assets/images/update_background.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter
                      ),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadiusDirectional.only(bottomStart: Radius.circular(6), bottomEnd: Radius.circular(6))
                        ),
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '是否升级到$version版本？',
                                style: TextStyle(fontSize: 18, color: Colors.grey[900], decoration: TextDecoration.none,),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Text(
                                  content,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[800], decoration: TextDecoration.none,),
                                  textAlign: TextAlign.left,
                                )
                            ),
                            Divider(height: 1, color: Colors.grey[600].withOpacity(0.5)),
                            Container(
                              margin: const EdgeInsets.only(bottom: 6.0),
                              child: IntrinsicHeight( // 使垂直分割线正常展示
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    if (!isForce) Expanded(
                                      child: TextButton(
                                        child: Text(
                                          "下次再说",
                                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: Navigator.of(globalContext).pop, //关闭对话框
                                      ),
                                    ),
                                    if (!isForce) VerticalDivider(color: Colors.grey[600].withOpacity(0.5), width: 1, indent: 10, endIndent: 10,),
                                    Expanded(
                                      child: TextButton(
                                        child: Text(
                                          "立即前往",
                                          style: TextStyle(color: Color(0xff1677FF), fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () => launch(link), //关闭对话框
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                    )
                );
              }),
        );
      },
    );
  }
}