import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:madad_advice/blocs/internet_bloc.dart';
import 'package:madad_advice/blocs/sing_up_bloc.dart';
import 'package:madad_advice/models/icons_data.dart';
import 'package:madad_advice/pages/home.dart';
import 'package:madad_advice/pages/sign_in.dart';
import 'package:madad_advice/pages/welcome_page.dart';
import 'package:madad_advice/styles.dart';
import 'package:madad_advice/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:madad_advice/generated/locale_keys.g.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:madad_advice/utils/snacbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool offsecureText = true;
  Icon lockIcon = LockIcon().lock;
  var emailCtrl = TextEditingController();
  var passCtrl = TextEditingController();
  var nameCtrl = TextEditingController();
  TextEditingController textEditingController = TextEditingController()
    ..text = "123456";
  var formKeyRegister = GlobalKey<FormState>();
  var formKeyPhoneValidate = GlobalKey<FormState>();
  var formKeyValidateCode = GlobalKey<FormState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  String email;
  String pass;
  String name;
  String lastName;
  String phoneNumber;
  String phoneNumberMasked;
  String validationCode;
  String smsCode;
  String prefix = '+';
  bool signUpStarted = false;
  bool signUpCompleted = false;
  bool phoneExists = false;
  bool hasError = false;
  void lockPressed() {
    if (offsecureText == true) {
      setState(() {
        offsecureText = false;
        lockIcon = LockIcon().open;
      });
    } else {
      setState(() {
        offsecureText = true;
        lockIcon = LockIcon().lock;
      });
    }
  }

  var label = 'Phone Number';
  PageController _controller = PageController(initialPage: 0, keepPage: false);
  var onTapRecognizer;
  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _controller.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      };
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: PageView(
          onPageChanged: (int index) {
            setState(() {
              signUpStarted = false;
              signUpCompleted = false;
              hasError = false;
              phoneExists = false;
            });
          },
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            signUpPhoneValidateUI(),
            enterVerificationCodeUI(),
            signUpUI(),
          ],
        ));
  }

  Widget enterVerificationCodeUI() {
    return Form(
      key: formKeyValidateCode,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              child: IconButton(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.keyboard_backspace),
                  onPressed: () {
                    _controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  }),
            ),
            Text(
              'Введите отправленный код подтверждения',
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: ThemeColors.dividerColor,
              thickness: 1,
            ),
            RichText(
              softWrap: true,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Код подтверждения отправлен на номер:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '  $phoneNumberMasked',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: ThemeColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            PinCodeTextField(
              length: 6,
              obsecureText: false,
              textInputType: TextInputType.phone,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                inactiveColor: ThemeColors.primaryColor,
                inactiveFillColor: Colors.transparent,
                activeColor: ThemeColors.primaryColor,
                selectedFillColor: Colors.transparent,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              animationDuration: Duration(milliseconds: 300),
              validator: (v) {
                if (v.length != 6) {
                  return 'Введите высланный код подтверждения';
                } else {
                  if (hasError) {
                    return 'Введен не правильный код';
                  }
                }
                return null;
              },
              enableActiveFill: true,
              //errorAnimationController: errorController,
              // controller: textEditingController,
              onCompleted: (v) {
                print("Completed");
              },
              onChanged: (value) {
                setState(() {
                  validationCode = value;
                  hasError = false;
                });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  text: 'Не получили код подтверждения? ',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                  children: [
                    TextSpan(
                        text: 'Повторить',
                        recognizer: onTapRecognizer,
                        style: TextStyle(
                            color: ThemeColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))
                  ]),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              width: double.infinity,
              child: RaisedButton(
                  color: ThemeColors.primaryColor,
                  child: signUpStarted == false
                      ? Text(
                          'Next', // LocaleKeys.signUp.tr(),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      : signUpCompleted == false
                          ? CircularProgressIndicator()
                          : Text(LocaleKeys.succesReg.tr(),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () {
                    handleEnterValidCode();
                    // handleSignUpwithEmailPassword();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget signUpPhoneValidateUI() {
    return Form(
      key: formKeyPhoneValidate,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.keyboard_backspace),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                Text(LocaleKeys.signUp.tr(),
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              ],
            ),
            Text(
              'Введите свой номер телефона',
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: ThemeColors.dividerColor,
              thickness: 1,
            ),
            SizedBox(
              height: 50,
            ),
            TextFormField(
              autofocus: false,
              decoration: InputDecoration(
                  prefix: Text(
                    prefix,
                    style: TextStyle(color: Colors.black),
                  ),
                  alignLabelWithHint: true,
                  hintText: '1234566789',
                  //prefixIcon: Icon(Icons.email),
                  labelText: label),
              controller: emailCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                PhoneInputFormatter(
                    onCountrySelected: (PhoneCountryData countryData) {
                  setState(() {
                    label = countryData != null ? countryData.country : '';
                  });
                })
              ],
              autocorrect: false,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Номер телефона не может быть пустым!';
                } else {
                  if (value.length >= 8) {
                    if (phoneExists) {
                      return 'Такой номер уже зарегистрирован в системе';
                    }
                  } else {
                    return 'Введите корректный номер';
                  }
                }

                return null;
              },
              onChanged: (String value) {
                if (value.length >= 3) {
                  setState(() {
                    prefix = '';
                  });
                }
                if (value.isEmpty) {
                  setState(() {
                    prefix = '+';
                  });
                }
                setState(() {
                  phoneExists = false;
                  phoneNumberMasked = value;
                  phoneNumber = value
                      .replaceFirst('+', '')
                      .replaceAll('(', '')
                      .replaceAll(')', '')
                      .replaceAll(' ', '');
                });
              },
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 45,
              width: double.infinity,
              child: RaisedButton(
                  color: ThemeColors.primaryColor,
                  child: signUpStarted == false
                      ? Text(
                          'Next', // LocaleKeys.signUp.tr(),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      : signUpCompleted == false
                          ? CircularProgressIndicator()
                          : Text(LocaleKeys.succesReg.tr(),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () {
                    handleEnterPhone();

                    // handleSignUpwithEmailPassword();
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  LocaleKeys.haveAnAcc.tr(),
                  style: TextStyle(fontSize: 12),
                ),
                FlatButton(
                  child: Text(
                    LocaleKeys.signIn.tr(),
                    style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                  onPressed: () {
                    nextScreenReplace(context, SignInPage());
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget signUpUI() {
    return Form(
      key: formKeyRegister,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              child: IconButton(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.keyboard_backspace),
                  onPressed: () {
                    _controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  }),
            ),
            Text(
              'Заполните необходимые поля для регистрации',
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: ThemeColors.dividerColor,
              thickness: 1,
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: LocaleKeys.enterName.tr(),
                hintText: LocaleKeys.enterName.tr(),
              ),
              validator: (String value) {
                if (value.length == 0) return LocaleKeys.nameCantBe.tr();
                return null;
              },
              onChanged: (String value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: LocaleKeys.enterLastName.tr(),
                hintText: LocaleKeys.enterLastName.tr(),
              ),
              validator: (String value) {
                if (value.length == 0) return LocaleKeys.enterLastName.tr();
                return null;
              },
              onChanged: (String value) {
                setState(() {
                  lastName = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                  hintText: 'username@mail.com',
                  //prefixIcon: Icon(Icons.email),
                  labelText: 'E-mail'),
              //controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (String value) {
                bool reg = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (value.isNotEmpty) {
                  if (reg) return null;
                  return 'не правильный E-mail';
                }
                return LocaleKeys.emailcant.tr();
              },
              onChanged: (String value) {
                setState(() {
                  email = value;
                });
              },
            ),
            TextFormField(
              obscureText: offsecureText,

              decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: lockIcon,
                    onPressed: () {
                      lockPressed();
                    }),

                labelText: LocaleKeys.enterPassword.tr(),
                hintText: LocaleKeys.enterPassword.tr(),
                //prefixIcon: Icon(Icons.vpn_key),
              ),
              //controller: passCtrl,
              validator: (String value) {
                if (value.isNotEmpty) {
                  if (value.length >= 8) {
                    return null;
                  }
                  return 'Минимальная длинна пароля 8 символов';
                }
                return LocaleKeys.passwordCantBe.tr();
              },
              onChanged: (String value) {
                setState(() {
                  pass = value;
                });
              },
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 45,
              width: double.infinity,
              child: RaisedButton(
                  color: ThemeColors.primaryColor,
                  child: signUpStarted == false
                      ? Text(
                          LocaleKeys.signUp.tr(),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      : signUpCompleted == false
                          ? CircularProgressIndicator()
                          : Text(LocaleKeys.succesReg.tr(),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () {
                    handleRegister();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  handleRegister() async {
    final ib = Provider.of<InternetBloc>(context);
    final signUp = Provider.of<SignUpBloc>(context);

    await ib.checkInternet();
    if (formKeyRegister.currentState.validate()) {
      formKeyRegister.currentState.save();
      FocusScope.of(context).requestFocus(FocusNode());
      if (ib.hasInternet == false) {
        openSnacbar(_scaffoldKey, LocaleKeys.noInternet.tr());
      } else {
        if (await signUp.register(
            email: email,
            phoneNumber: phoneNumber,
            password: pass,
            name: name,
            lastName: lastName)) {
          nextScreen(context, WelcomePage());
        } else {
          openSnacbar(_scaffoldKey, 'Произошла ошибка при регистрации');
        }
      }
    }
  }

  handleEnterValidCode() async {
    final ib = Provider.of<InternetBloc>(context);
    final signUp = Provider.of<SignUpBloc>(context);

    await ib.checkInternet();
    if (formKeyValidateCode.currentState.validate()) {
      formKeyValidateCode.currentState.save();
      FocusScope.of(context).requestFocus(FocusNode());
      if (ib.hasInternet == false) {
        openSnacbar(_scaffoldKey, LocaleKeys.noInternet.tr());
      } else {
        if (await signUp.checkVarificationCode(validationCode, smsCode)) {
          await _controller.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        } else {
          setState(() {
            hasError = true;
          });
          formKeyValidateCode.currentState.validate();
        }
      }
    }
  }

  handleEnterPhone() async {
    final ib = Provider.of<InternetBloc>(context);
    final signUp = Provider.of<SignUpBloc>(context);

    await ib.checkInternet();
    if (formKeyPhoneValidate.currentState.validate()) {
      formKeyPhoneValidate.currentState.save();
      FocusScope.of(context).requestFocus(FocusNode());

      if (ib.hasInternet == false) {
        openSnacbar(_scaffoldKey, LocaleKeys.noInternet.tr());
      } else {
        setState(() {
          signUpStarted = true;
        });
        if (await signUp.checkPhone(phoneNumber)) {
          var code = await signUp.sendVerificationCode(phoneNumber);
          setState(() {
            signUpCompleted = true;
            smsCode = code;
          });
          await _controller.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        } else {
          setState(() {
            phoneExists = true;
            signUpStarted = false;
          });
          formKeyPhoneValidate.currentState.validate();
        }
      }
    }
  }
}
