import 'package:flutter/material.dart';
import '../../../../utils/constants.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: kSpaceS * 3),
        Text(Constant.welcomeToWicketLive,
          style: Theme.of(context).textTheme.headline5!.copyWith(color: kBlack, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kSpaceS),
        Text(Constant.loginHereUsingYourUsernameAndPassword,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: kBlack.withOpacity(0.5)),
        ),
      ],
    );
  }
}
