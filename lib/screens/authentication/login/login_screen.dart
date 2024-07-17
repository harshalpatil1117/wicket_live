import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/authentication/login/widgets/header.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../dashboard/dashboard_screen.dart';
import 'widgets/custom_clippers/blue_top_clipper.dart';
import 'widgets/custom_clippers/grey_top_clipper.dart';
import 'widgets/custom_clippers/white_top_clipper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  LoginScreenState();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var username = TextEditingController();
  var password = TextEditingController();

  bool _isObscurPassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              ClipPath(
                clipper: const WhiteTopClipper(),
                child: Container(color: kBlack),
              ),
              ClipPath(
                clipper: const GreyTopClipper(),
                child: Container(color: kBlue.withOpacity(0.9)),
              ),
              ClipPath(
                clipper: const BlueTopClipper(),
                child: Container(color: kGrey),
              ),
              Positioned(
                top: 10,
                left: 40,
                child: const Header(),
              ),
              Padding(
                padding: padding.symmetric(horizontal: Dimensions.smallest),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      //const Header(),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Space(Dimensions.largest),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: kPaddingL),
                        child: Column(
                          children: [
                            RegularTextFormField(
                              autoFocus: true,
                              controller: username,
                              label: '',
                              hintText: Constant.username,
                              validation: (v) {},
                              prefixIcon: Icon(Icons.person),
                            ),
                            Space(Dimensions.medium),
                            BaseFormField(
                              label: '',
                              enabled: true,
                              validation: (v) {},
                              isPasswordField: true,
                              isNumber: false,
                              hintText: Constant.password,
                              controller: password,
                              prefixIcon: Icon(
                                Icons.lock,
                              ),
                            ),
                            Space(Dimensions.medium),
                            SubmitButton(
                              onPressed: () {
                                if(username.text == "Admin" && password.text == "Admin@123"){
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const DashboardScreen()));
                                }
                                else{
                                  Fluttertoast.showToast(
                                      msg: "Authentication Failed",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              isLoading: false,
                              childWidget: Text(Constant.loginToContinue),
                            ),
                            Space(Dimensions.medium),
                            SubmitButton(
                              onPressed: () {},
                              isLoading: false,
                              childWidget:
                                  Text(Constant.createACricketClubAccount),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
