import 'package:flutter/material.dart';

import '../plugins/dialog.dart';

class FormTest extends StatefulWidget{
  final String title;

  const FormTest({Key? key, required this.title}): super(key : key);
  @override
  State<StatefulWidget> createState() => _FormTest();
}

class _FormTest extends State<FormTest>{

  TextEditingController _nameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  GlobalKey _formKey= GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = '0000000000@google.cn'; // 可设置初始值
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Form(
          key: _formKey, // 设置globalKey，用于后面获取FormState
          autovalidateMode: AutovalidateMode.always, // 开启自动校验
          child: Column(
            children: <Widget>[
              TextFormField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: "用户名",
                      hintText: "用户名或邮箱",
                      icon: Icon(Icons.person)
                  ),
                  // 校验用户名
                  validator: (v) {
                    return v
                        !.trim()
                        .length > 0 ? null : "用户名不能为空";
                  }

              ),
              TextFormField(
                  controller: _pwdController,
                  decoration: InputDecoration(
                      labelText: "密码",
                      hintText: "您的登录密码",
                      icon: Icon(Icons.lock)
                  ),
                  obscureText: true,
                  //校验密码
                  validator: (v) {
                    return v
                        !.trim()
                        .length > 5 ? null : "密码不能少于6位";
                  }
              ),
              // 登录按钮
              Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: Size(88, 36),
                          padding: EdgeInsets.all(15.0),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        child: Text("登录"),
                        onPressed: () {
                          //在这里不能通过 Form.of(context) 获取 FormState, context 不对

                          // 通过_formKey.currentState 获取FormState后，
                          // 调用validate()方法校验用户名密码是否合法，校验
                          // 通过后再提交数据。

                          FormState _form = _formKey.currentState as FormState;
                          if(/*(_form as FormState)*/_form.validate()){
                            _form.save();
                            Talk.log('_nameController.value.text: ${_nameController.text}', name: 'View.FormTest'); // 用户名
                            Talk.log('_pwdController.value.text: ${_pwdController.text}', name: 'View.FormTest'); // 密码
                            //验证通过提交数据
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}