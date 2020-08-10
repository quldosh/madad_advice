import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madad_advice/blocs/sign_in_bloc.dart';
import 'package:madad_advice/blocs/user_bloc.dart';
import 'package:madad_advice/models/config.dart';
import 'package:madad_advice/pages/data_usage.dart';
import 'package:madad_advice/pages/language.dart';
import 'package:madad_advice/pages/sign_in.dart';
import 'package:madad_advice/pages/welcome_page.dart';
import 'package:madad_advice/styles.dart';
import 'package:madad_advice/utils/myicons.dart';
import 'package:madad_advice/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madad_advice/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List subtitles = [
    Config().email,
    'Rate this app on Google Play',
    'App details',
    'Get source code of app and admin panel'
  ];

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  //final FacebookLogin fbLogin = new FacebookLogin();

  handleLogout() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          final isIos = Theme.of(context).platform == TargetPlatform.iOS;
          if (isIos) {
            return CupertinoAlertDialog(
              title: Text(
                '${LocaleKeys.signOut.tr()}?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Text(
                LocaleKeys.rlySignOut.tr(),
                style: TextStyle(fontSize: 12),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(LocaleKeys.yes.tr()),
                  onPressed: () async {
                    await sb.setLogIut();
                    nextScreenCloseOthers(context, WelcomePage());
                  },
                ),
                CupertinoDialogAction(
                  child: Text(LocaleKeys.no.tr()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          } else {
            return AlertDialog(
              title: Text(
                '${LocaleKeys.signOut.tr()}?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Text(
                LocaleKeys.rlySignOut.tr(),
                style: TextStyle(fontSize: 12),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(LocaleKeys.yes.tr()),
                  onPressed: () async {
                    await sb.setLogIut();
                    nextScreenCloseOthers(context, WelcomePage());
                  },
                ),
                FlatButton(
                  child: Text(LocaleKeys.no.tr()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
        });
  }

  openAboutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: Config().appName,
            applicationIcon: Image(
              image: AssetImage(Config().splashIcon),
              height: 30,
              width: 30,
            ),
          );
        });
  }

  openEmailPopup() async {
    await launch(
        'mailto:${Config().email}?subject=About ${Config().appName} App&body=');
  }

  bool checkUrl(url) {
    return url.contains('http');
  }

  @override
  Widget build(BuildContext context) {
    final ub = Provider.of<UserBloc>(context);
    final sp = Provider.of<SignInBloc>(context);
    print(sp.isSignedIn);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: ThemeColors.primaryColor,
            pinned: true,
            expandedHeight: 270,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: ThemeColors.primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: ThemeColors.primaryColor,
                      backgroundImage: (checkUrl(ub.imageUrl)
                          ? CachedNetworkImageProvider(ub.imageUrl)
                          : File(ub.imageUrl).existsSync()
                              ? FileImage(File(ub.imageUrl))
                              : AssetImage('assets/logo.png')),
                      radius: 45,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(ub.userName,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(ub.email,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60)),
                    SizedBox(height: 10),
                    sp.isSignedIn
                        ? FlatButton.icon(
                            color: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () => handleLogout(),
                            icon: Icon(Icons.exit_to_app),
                            label: Text(LocaleKeys.signOut.tr()),
                            textColor: Colors.grey[900],
                          )
                        : FlatButton.icon(
                            color: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () =>
                                nextScreenReplace(context, SignInPage()),
                            icon: Icon(Icons.exit_to_app),
                            label: Text(LocaleKeys.signIn.tr()),
                            textColor: Colors.grey[900],
                          ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: sp.isSignedIn
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListTile(
                                contentPadding: EdgeInsets.only(
                                  left: 15,
                                ),
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: ThemeColors.primaryColor
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.data_usage,
                                      color: Colors.white, size: 25),
                                ),
                                title: Text(
                                  'Использование памяти',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800]),
                                ),
                                onTap: () {
                                  nextScreen(context, DataUsage());
                                }),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListTile(
                              contentPadding: EdgeInsets.only(
                                left: 15,
                              ),
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: ThemeColors.primaryColor
                                        .withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.language,
                                    color: Colors.white, size: 25),
                              ),
                              title: Text(
                                LocaleKeys.lang.tr(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800]),
                              ),
                              onTap: () {
                                nextScreen(context, LanguageView());
                              },
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 40,
                            child: FlatButton.icon(
                                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                color: ThemeColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(16.0)),
                                icon: Icon(Icons.edit, color: Colors.white),
                                label: Text(LocaleKeys.editProfile.tr(),
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () => showBarModalBottomSheet(
                                      expand: false,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context, scrollController) =>
                                          ModalInsideModal(
                                              scrollController:
                                                  scrollController),
                                    )),
                          ),
                        ),
                      )
                    ],
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Text(
                      LocaleKeys.furtherActions.tr(),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(letterSpacing: 2),
                    )),
          )
        ],
      ),
    );
  }
}

class ModalInsideModal extends StatefulWidget {
  final ScrollController scrollController;
  final bool reverse;

  const ModalInsideModal({Key key, this.scrollController, this.reverse = false})
      : super(key: key);

  @override
  _ModalInsideModalState createState() => _ModalInsideModalState();
}

class _ModalInsideModalState extends State<ModalInsideModal> {
  String uName;
  String uLastName;
  String uPass;
  String uEmail;
  String uGender;
  String uPhotoUrl;
  int initialGenderIndex;
  @override
  Widget build(BuildContext context) {
    final ub = Provider.of<UserBloc>(context);

    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(LocaleKeys.edit.tr()),
        leading: SizedBox.shrink(),
        trailing: InkWell(
          child: DuoTonIcon(
            FontAwesomeIcons.duotoneCamera,
            primaryColor: ThemeColors.primaryColor,
            secondaryColor: ThemeColors.primaryColor.withOpacity(0.6),
          ),
          onTap: () => showMaterialModalBottomSheet(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context, scrollController) =>
                ModalFit(scrollController: scrollController),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
            reverse: widget.reverse,
            shrinkWrap: true,
            controller: widget.scrollController,
            physics: ClampingScrollPhysics(),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: ub.userName,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.enterName.tr(),
                        hintText: LocaleKeys.enterName.tr(),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return LocaleKeys.nameCantBe.tr();
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          uName = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ub.userLastName,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.enterLastName.tr(),
                        hintText: LocaleKeys.enterLastName.tr(),
                        //prefixIcon: Icon(Icons.vpn_key),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return LocaleKeys.enterLastName.tr();
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          uLastName = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ub.email,
                      decoration: InputDecoration(
                          hintText: 'username@mail.com',
                          //prefixIcon: Icon(Icons.email),
                          labelText: 'E-mail'),
                      //controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String value) {
                        if (value.isEmpty) return LocaleKeys.emailcant.tr();
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          uEmail = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: LocaleKeys.enterPassword.tr(),
                        hintText: LocaleKeys.enterPassword.tr(),
                        //prefixIcon: Icon(Icons.vpn_key),
                      ),
                      //controller: passCtrl,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return LocaleKeys.passwordCantBe.tr();
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          uPass = value;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        color: ThemeColors.primaryColor,
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text(LocaleKeys.save.tr(),
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => ub
                            .updateUserData(
                                uName, uLastName, uEmail, uPhotoUrl, uGender)
                            .then((_) async {
                          ub.getUserData();
                          Navigator.pop(context);
                        }),
                      )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              )
            ]),
      ),
    ));
  }
}

class ModalFit extends StatefulWidget {
  final ScrollController scrollController;

  const ModalFit({Key key, this.scrollController}) : super(key: key);

  @override
  _ModalFitState createState() => _ModalFitState();
}

class _ModalFitState extends State<ModalFit> {
  File _image;
  final picker = ImagePicker();

  Future getImageCamera() async {
    final ub = Provider.of<UserBloc>(context);
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await ub.setImage(_image).then((_) async {
        ub.getUserData();
      });
    }
  }

  Future getImageGallery() async {
    final ub = Provider.of<UserBloc>(context);

    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await ub.setImage(_image).then((_) async {
        ub.getUserData();
      });
      print(_image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(LocaleKeys.takePhoto.tr()),
            leading: Icon(EvilIcons.camera),
            onTap: () => getImageCamera(),
          ),
          ListTile(
            title: Text(LocaleKeys.chooseFromGallery.tr()),
            leading: Icon(EvilIcons.image),
            onTap: () => getImageGallery(),
          ),
          ListTile(
            title: Text(LocaleKeys.deletePhoto.tr()),
            leading: Icon(EvilIcons.trash),
            onTap: () => print('del photo'),
          )
        ],
      ),
    ));
  }
}