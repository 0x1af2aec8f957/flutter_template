import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'dart:math' as math;

abstract class Signer { // 对象接口
  late String key; // 加密使用的key
  late String iv; // 加密使用的iv
  late Encrypter encrypter;

  // bool verify(); // 校验
  String generateKey(String urlPath); // 生成key
  String generateIv(String key); // 生成iv
  String encrypt({required String data}); // 加密方法
  String decrypt({required String data}); // 解密方法
}

class Crypto implements Signer{
  late String key;
  late String iv;
  late Encrypter encrypter;

  Key get _key => key.isNotEmpty ? Key.fromUtf8(key.substring(0, 16)) : Key.fromLength(8);
  IV get _iv => iv.isNotEmpty ? IV.fromUtf8(iv.substring(0, 16)) : IV.fromLength(8);

  Crypto(Uri urlStr) {
    final String path = urlStr.path.split('/').last;

    key = generateKey(path);
    iv = generateIv(key);
    encrypter = Encrypter(AES(_key, mode: AESMode.cbc)/*Salsa20(_key))*/);
  }

  String generateKey(String urlPath) {
    final content = Utf8Encoder().convert(urlPath);
    final digest = crypto.md5.convert(content);
    return hex.encode(digest.bytes);
  }

  String generateIv(String key) {
    final array = <String>[];

    for (int idx = 1; idx <= key.length; idx += 1) {
      // 生成二叉树数组层级

      if ((idx & idx + 1) == 0) {
        // 是否处于二叉树节点上[即是不是2的幂运算结果，附加已遍历过的二叉树节点数据]
        final index = idx - 1;
        final row = math.log(idx + 1) / math.log(2); // 当前行数[2的对数]

        array.add(
          idx == 1
              ? key[index]
              : key.substring((math.pow(2, row.ceil() /* 二叉树当前行数 */ - 1)).toInt() - 1, idx),
        );
      }
    }

    for (int index = 0; index < array.length; index += 1) {
      if (index == 0) continue;

      String str = '';

      for (int idx = 1; idx <= array[index].length; idx += 1) {
        if (idx.isEven) {
          // 偶数反转
          final int eq = idx - 1;
          str += array[index][eq] + array[index][eq - 1]; // 交换元素位置
        }
      }

      array[index] = str;
    }

    return array.join('');
  }

  String encrypt({required String data}) {
    // 加密方法
    return encrypter.encrypt(data, iv: _iv).base64;
  }

  String decrypt({required String data}) {
    // 解密方法
    return encrypter.decrypt(Encrypted.fromBase64(data), iv: _iv);
  }
}
