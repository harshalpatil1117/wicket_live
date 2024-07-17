import 'dart:convert';

import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network/network.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:wicket_live_apk/screens/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicket_live_apk/utils/constants.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';

class CoinTossPage extends StatefulWidget {
  const CoinTossPage({super.key});

  @override
  State<CoinTossPage> createState() => _CoinTossPageState();
}

class _CoinTossPageState extends State<CoinTossPage>
    with SingleTickerProviderStateMixin {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  late AnimationController animationCtrl;
  late Animation<double> verticalMovment;
  late Animation<double> rotation;
  final random = Random();
  late bool isHeads;
  String teamACaptain = '';
  String teamBCaptain = '';
  String winningTeam = '';
  bool tossCompleted = false;
  bool isBattingSelected = false;
  bool isBallingSelected = false;
  List<String> numOfMatch = ['1', '2', '3', '4', '5'];
  String selectNumOfMatch = "3";
  TextEditingController noOfOvers = TextEditingController(text: "6");

  void selectBatting() {
    setState(() {
      isBattingSelected = true;
      isBallingSelected = false;
    });
  }

  void selectBalling() {
    setState(() {
      isBattingSelected = false;
      isBallingSelected = true;
    });
  }

  final DB _databaseHelper = DB();
  int countRows = 0;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    animationCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    verticalMovment = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: -100),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -100, end: 0),
        weight: 50,
      ),
    ]).animate(animationCtrl);

    rotation = Tween<double>(
      begin: 0,
      end: 2 * pi * 10,
    ).animate(animationCtrl);

    isHeads = random.nextBool();

    teamACaptain = sharedPreferenceHelper.teamACaptain ?? '';
    teamBCaptain = sharedPreferenceHelper.teamBCaptain ?? '';
  }

  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    countRows = await _databaseHelper
        .createTeamCountRows(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    setState(() {});
  }

  void tossCoin() async {
    setState(() {
      isBattingSelected = false;
      isBallingSelected = false;
    });
    double stopPosition = random.nextBool() ? 0.0 : 0.5;
    animationCtrl.value = stopPosition;
    animationCtrl.forward(from: 0);
    setState(() {
      isHeads = random.nextBool();
      // Ensure the winning team's name corresponds to the coin face
      if (isHeads) {
        teamACaptain = sharedPreferenceHelper.teamACaptain ?? '';
        winningTeam = 'Team $teamACaptain';
      } else {
        teamBCaptain = sharedPreferenceHelper.teamBCaptain ?? '';
        winningTeam = 'Team $teamBCaptain';
      }
    });
    await Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        tossCompleted = true;
      });
    });
  }

  List<Map<String, dynamic>> matches = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Match",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
      ),
      body: Padding(
        padding: padding.symmetric(horizontal: Dimensions.small),
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Space(Dimensions.largest),
              Space(Dimensions.largest),
              AnimatedBuilder(
                animation: animationCtrl,
                builder: (BuildContext context, Widget? child) {
                  double verticalOffset = verticalMovment.value;
                  double value = rotation.value % (2 * pi);
                  return Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(value),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(2, 3),
                              color: Colors.blueGrey,
                            )
                          ],
                          shape: BoxShape.circle,
                          color: isHeads ? Colors.blueAccent : Colors.blueGrey,
                        ),
                        child: Center(
                          child: Text(
                            tossCompleted
                                ? winningTeam
                                : isHeads
                                    ? 'Team A'
                                    : 'Team B',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: envoiceColorsExtensions.background),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Space(Dimensions.large),
              Padding(
                padding: padding.symmetric(horizontal: Dimensions.small),
                child: SubmitButton(
                  onPressed: tossCoin,
                  isLoading: false,
                  childWidget: Text(Constant.tossCoin),
                ),
              ),
              tossCompleted
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '$winningTeam won the toss',
                        style: theme.textTheme.titleMedium,
                      ),
                    )
                  : SizedBox.shrink(),
              tossCompleted
                  ? Column(
                      children: [
                        Text(
                          "Choose Batting / Bowling",
                          style: theme.textTheme.titleMedium,
                        ),
                        Space(Dimensions.medium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: selectBatting,
                              child: Card(
                                elevation: 10,
                                color: isBattingSelected
                                    ? Colors.lightGreen
                                    : null,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      WicketLiveAssets.images.bat.image(
                                        width: 35,
                                        height: 35,
                                      ),
                                      Space(DimensionToken.small),
                                      Text(
                                        'Batting',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: selectBalling,
                              child: Card(
                                elevation: 10,
                                color: isBallingSelected
                                    ? Colors.lightGreen
                                    : null,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      WicketLiveAssets.images.ball.image(
                                        width: 35,
                                        height: 35,
                                      ),
                                      Space(DimensionToken.small),
                                      Text(
                                        'Balling',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              Space(Dimensions.large),
              isBattingSelected == true || isBallingSelected == true
                  ? Column(
                      children: [
                        RegularTextFormField(
                          needLabel: true,
                          isNumber: true,
                          controller: noOfOvers,
                          label: "Number Of Overs",
                          hintText: "",
                          validation: (value) {},
                        ),
                        const Space(Dimensions.small),
                        BaseDropDownFormField(
                          label: Constant.selectNumOfMatch,
                          value: selectNumOfMatch,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectNumOfMatch = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == Constant.selectNumOfMatch ||
                                value == null ||
                                value.isEmpty) {
                              return "Please select the number of the match";
                            }
                            return null;
                          },
                          options: numOfMatch,
                        ),
                        const Space(Dimensions.medium),
                        SubmitButton(
                          onPressed: () async {
                            List<String> teamAPlayers =
                                sharedPreferenceHelper.teamA ?? [];
                            List<String> teamBPlayers =
                                sharedPreferenceHelper.teamB ?? [];
                            String teamABatBall =
                                winningTeam == 'Team $teamACaptain'
                                    ? isBattingSelected
                                        ? "Batting"
                                        : "Balling"
                                    : winningTeam == 'Team $teamBCaptain' ? isBattingSelected
                                    ? "Balling"
                                    : "Batting" : "";
                            String teamBBatBall = teamABatBall == "Batting"
                                ? "Balling"
                                : "Batting";

                            String winningTeamBatBall = isBattingSelected
                                ? "Batting"
                                : "Balling";

                            if (countRows == 0) {

                              for(var count = 0 ; count < int.parse(selectNumOfMatch) ; count++){
                                boolList[count] = 'true';
                                setState(() {});
                              }

                              for(var count = int.parse(selectNumOfMatch) ; count < int.parse(10.toString()) ; count++){
                                boolList[count] = 'false';
                                setState(() {});
                              }

                              sharedPreferenceHelper.saveWinningTeam(winningTeam);
                              sharedPreferenceHelper.saveWinningTeamBatBall(winningTeamBatBall);
                              await _databaseHelper.initDatabase();
                              await _databaseHelper.createTeamInsert(
                                teamACaptain,
                                teamBCaptain,
                                teamABatBall,
                                teamBBatBall,
                                teamAPlayers.join(","),
                                teamBPlayers.join(","),
                                selectNumOfMatch,
                                noOfOvers.text,
                                "",
                                "",
                                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              );

                              int? lastRecordId =
                                  await _databaseHelper.getLastCreateTeamId();

                              for (var count = 0;
                                  count < int.parse(10.toString());
                                  count++) {
                                await _databaseHelper.addMatch(
                                  "Match - ${count + 1}",
                                  DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                  lastRecordId.toString(),
                                  count == 0 ? "0" : "1",
                                );
                              }

                              matches = await _databaseHelper.getMatchesByTodayDate(DateFormat('dd-MM-yyyy').format(DateTime.now()));
                              matches.forEach((match) {
                                _databaseHelper.InsertInningDetails("", DateFormat('dd-MM-yyyy').format(DateTime.now()), lastRecordId.toString(), match["id"].toString());
                                _databaseHelper.InsertInningDetails("", DateFormat('dd-MM-yyyy').format(DateTime.now()), lastRecordId.toString(), match["id"].toString());
                              });
                              setState(() {});

                              final createdTeam =
                                  _databaseHelper.getCreatedTeam();
                              final createdTeamData = _databaseHelper
                                  .getCreateTeamData(DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()));

                              print("Created team == ${createdTeam.then((value) => print(value))}");
                              print("Created team Date == ${createdTeamData.then((value) => print(value))}");

                              await _saveList(boolList);

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => DashboardScreen(),
                                  ),
                                  (route) => false);
                            } else {}
                          },
                          isLoading: false,
                          childWidget: Text(Constant.createMatch,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1,
                                color: envoiceColorsExtensions.background,
                              )),
                        ),
                      ],
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  List<String> boolList = ['false', 'false', 'false', 'false', 'false', 'false', 'false', 'false', 'false', 'false'];
  _saveList(List<String> passBoolList) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('stringList', passBoolList);
  }

  @override
  void dispose() {
    animationCtrl.dispose();
    super.dispose();
  }
}
