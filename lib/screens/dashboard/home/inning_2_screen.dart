import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/network.dart';
import 'package:wicket_live_apk/screens/dashboard/dashboard_screen.dart';
import 'package:wicket_live_apk/screens/dashboard/home/home_screen.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';
import 'package:intl/intl.dart';
import 'match_collected_fund_screen.dart';

class Inning2Screen extends StatefulWidget {
  const Inning2Screen({
    super.key,
    required this.matchId,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.targetScore,
    required this.maxOvers,
    required this.createTeamId,
    required this.matchesId,
  });

  final String matchId;
  final String matchesId;
  final String battingTeam;
  final String bowlingTeam;
  final int targetScore;
  final int maxOvers;
  final String createTeamId;

  @override
  State<Inning2Screen> createState() => _Inning2ScreenState();
}

class _Inning2ScreenState extends State<Inning2Screen> {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  final DB _databaseHelper = DB();
  final List<String> possibleRuns = [
    '0',
    '1',
    '2',
    '4',
    '6',
    'W',
    'WD',
    'Undo',
    'Retired'
  ];
  List<String> displayOverScore = [];
  int targetScore = 0;
  int maxOvers = 0;
  int remainingBalls = 0;
  int maxWickets = 0;
  int perBallScoreCount = 0;
  String battingPlayer = '';
  String ballingPlayer = '';

  List<String> remainingPlayer = [];
  List<String> playedPlayerWicket = [];
  List<String> remainingBowlingPlayer = [];
  List<String> bowledPlayerList = [];

  int battingPlayerRuns = 0;
  int battingPlayerBalls = 0;
  int battingPlayerFours = 0;
  int battingPlayerSixes = 0;
  String strikeRate = '0';

  int ballingPlayerBall = 0;
  int ballingPlayerMaidenOver = 0;
  int ballingPlayerRuns = 0;
  int ballingPlayerWickets = 0;
  String economy = '0';
  int wideBallCount = 0;
  int extraRunCount = 0;

  int totalTeamScore = 0;
  int totalTeamWicket = 0;
  int totalTeamBalls = 0;
  int totalTeamOvers = 0;
  int totalTeamWideBalls = 0;

  List pdfSummary = [];
  List<Map<String, dynamic>> innings1Batter = [];
  List<Map<String, dynamic>> innings1Bowler = [];
  List<Map<String, dynamic>> innings2Batter = [];
  List<Map<String, dynamic>> innings2Bowler = [];

  // Map to store aggregated statistics
  Map<String, List> playerStatsMapInnings1Batter = {};
  Map<String, List> playerStatsMapInnings1Baller = {};
  Map<String, List> playerStatsMapInnings2Batter = {};
  Map<String, List> playerStatsMapInnings2Baller = {};

  List<String> innings1BatterFinalList = [];
  List<String> innings1BallerFinalList = [];
  List<String> innings2BatterFinalList = [];
  List<String> innings2BallerFinalList = [];
  List<String> matchFundFinalList = [];

  int inning1Wicket = 0;
  int inning2Wicket = 0;
  int innings1TotalRuns = 0;
  int innings2TotalRuns = 0;

  bool isClick = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDatabase();
    targetScore = widget.targetScore;
    maxOvers = widget.maxOvers;
    remainingBalls = maxOvers * 6;

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        Future.delayed(const Duration(microseconds: 1)).then(
          (_) async {
            await initialMatchDetails();
          },
        );
      },
    );
  }

  String createId = '';
  List inningDetail = [];
  String inningDetailId = '';

  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    createId = await _databaseHelper.getLastCreateTeamId().toString();
    inningDetail =
        await _databaseHelper.getInningDetailByMatchId(widget.matchesId);
    setState(() {});
    if (inningDetail.isNotEmpty) {
      print("inning details Today:");
      inningDetail.forEach((match) {
        print(match);
      });
    } else {
      print("No inning details for today's match.");
    }
    print(inningDetail);
  }

  List inningHighlight = [];

  Future<void> _inningHighlightDatabase() async {
    await _databaseHelper.initDatabase();
    // createId = await _databaseHelper.getLastCreateTeamId().toString();
    inningHighlight =
        await _databaseHelper.getInningHighlightByMatchId(widget.matchesId);
    setState(() {});
    if (inningHighlight.isNotEmpty) {
      print(inningHighlight.length);
      print("inning details Today:");
      inningHighlight.forEach((match) {
        print(match);
      });
    } else {
      print("No inning details for today's match.");
    }
    // print(inningHighlight);
  }

  initialMatchDetails() async {
    remainingPlayer = widget.battingTeam == sharedPreferenceHelper.teamACaptain
        ? sharedPreferenceHelper.teamA ?? []
        : sharedPreferenceHelper.teamB ?? [];
    remainingBowlingPlayer =
        widget.bowlingTeam == sharedPreferenceHelper.teamACaptain
            ? sharedPreferenceHelper.teamA ?? []
            : sharedPreferenceHelper.teamB ?? [];

    maxWickets = widget.battingTeam == sharedPreferenceHelper.teamACaptain
        ? sharedPreferenceHelper.teamA?.length ?? 0
        : sharedPreferenceHelper.teamB?.length ?? 0;

    if (remainingPlayer.length > 0) {
      bool? battingPlayerChanged =
          await _showBattingDialog(widget.matchId, true);
      if (battingPlayerChanged == true) {
        setState(() {});
        if (remainingBowlingPlayer.length > 0) {
          bool? isPlayerChanged =
              await _dialogBuilderOnOverComplete(context, true);
          if (isPlayerChanged == true) {
            setState(() {});
          }
        }
      }
    }
  }

  Future<void> _dialogBuilderInningsCompleted(
      BuildContext context, bool teamWon) {
    List<Map<String, dynamic>> matches = [];
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Inning 2 is Completed !!'),
            content: Text(
              teamWon
                  ? "Team ${widget.battingTeam} won the match"
                  : "Team ${widget.battingTeam} loss the match",
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Yes'),
                onPressed: () async {
                  if (!isClick) {
                    setState(() {});
                    isClick = true;
                    teamWon
                        ? sharedPreferenceHelper
                            .saveWinningTeam("Team ${widget.battingTeam}")
                        : sharedPreferenceHelper
                            .saveWinningTeam("Team ${widget.bowlingTeam}");
                    teamWon
                        ? sharedPreferenceHelper
                            .saveWinningTeamBatBall("Batting")
                        : sharedPreferenceHelper
                            .saveWinningTeamBatBall("Batting");
                    sharedPreferenceHelper.saveBattingPlayer("");
                    sharedPreferenceHelper.saveBallingPlayer("");
                    sharedPreferenceHelper.saveInning2(true);

                    await _databaseHelper.initDatabase();
                    matches = await _databaseHelper.getMatchesByTodayDate(
                        DateFormat('dd-MM-yyyy').format(DateTime.now()));
                    setState(() {});

                    bool isCheck = false;
                    for (var count = 0; count < matches.length; count++) {
                      if (!isCheck) {
                        if (matches.length != count + 1) {
                          if (matches[count]['status'] == "0") {
                            await _databaseHelper.updateMatchStatus(
                                matches[count]['id'].toString(), "2");
                            await _databaseHelper.updateMatchStatus(
                                "${matches[count]['id'] + 1}", "0");
                            isCheck = true;
                            setState(() {});
                            break;
                          }
                        } else {
                          if (matches[count]['status'] == "0") {
                            await _databaseHelper.updateMatchStatus(
                                matches[count]['id'].toString(), "2");
                            isCheck = true;
                            setState(() {});
                            break;
                          }
                        }
                      }
                    }
                    //function
                    print('1');
                    await PdfSummary();
                    print(innings1BatterFinalList);
                    print(innings1BallerFinalList);
                    print(innings2BatterFinalList);
                    print(innings2BallerFinalList);
                    //insert pdfsummary
                    await _databaseHelper.insertPdfSummaryDetails(
                        innings1BatterFinalList.toString(),
                        innings1TotalRuns.toString(),
                        inning1Wicket.toString(),
                        innings2TotalRuns.toString(),
                        inning2Wicket.toString(),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.matchesId);
                    await _databaseHelper.insertPdfSummaryDetails(
                        innings1BallerFinalList.toString(),
                        innings1TotalRuns.toString(),
                        inning1Wicket.toString(),
                        innings2TotalRuns.toString(),
                        inning2Wicket.toString(),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.matchesId);
                    await _databaseHelper.insertPdfSummaryDetails(
                        innings2BatterFinalList.toString(),
                        innings1TotalRuns.toString(),
                        inning1Wicket.toString(),
                        innings2TotalRuns.toString(),
                        inning2Wicket.toString(),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.matchesId);
                    await _databaseHelper.insertPdfSummaryDetails(
                        innings2BallerFinalList.toString(),
                        innings1TotalRuns.toString(),
                        inning1Wicket.toString(),
                        innings2TotalRuns.toString(),
                        inning2Wicket.toString(),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.matchesId);
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please wait the match is completed',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    battingPlayer = sharedPreferenceHelper.battingPlayer ?? '';
    ballingPlayer = sharedPreferenceHelper.ballingPlayer ?? '';
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      backgroundColor: theme.envoiceColorsExtensions.onSecondary,
      appBar: AppBar(
        backgroundColor: theme.envoiceColorsExtensions.onSecondary,
        title: Text(
          "${widget.matchId} : Inning 2",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) =>
                      MatchCollectedFundScreen(matchesId: widget.matchesId),
                ),
              );
            },
            icon: Icon(
              Icons.monetization_on,
              color: theme.envoiceColorsExtensions.background,
              size: 30,
            ),
          ),
          Space(Dimensions.smaller),
        ],
      ),
      bottomSheet: AlignedGridView.count(
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: padding.all(Dimensions.smaller),
        shrinkWrap: true,
        itemCount: possibleRuns.length,
        crossAxisCount: 3,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () {
              print(inningDetail);
              print("inningDetailsID");
              inningDetailId = inningDetail[1]["id"].toString();
              updateScore(possibleRuns[index]);
              // // CurrentRunRate();
              calculateCurrentRunRate(totalTeamScore);
              _inningHighlightDatabase();
              setState(() {
                strikeRate = (battingPlayerRuns / battingPlayerBalls * 100)
                    .toStringAsFixed(2);
                economy = (ballingPlayerRuns / (ballingPlayerBall / 6))
                    .toStringAsFixed(2);
              });
            },
            child: Text(possibleRuns[index],
                style:
                    possibleRuns[index] != 'W' && possibleRuns[index] != 'Undo'
                        ? theme.textTheme.titleLarge
                        : theme.textTheme.titleMedium?.copyWith(
                            color: theme.envoiceColorsExtensions.background,
                          )),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                possibleRuns[index] != 'W'
                    ? possibleRuns[index] == 'Undo'
                        ? Colors.blue
                        : theme.envoiceColorsExtensions.secondary
                    : theme.envoiceColorsExtensions.error,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: padding.all(Dimensions.small),
          child: Column(
            children: [
              Text(
                'Team ${widget.battingTeam} needs ${targetScore < 0 ? "0" : targetScore} runs in ${remainingBalls} balls',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.envoiceColorsExtensions.background,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Space(Dimensions.smaller),
              Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                color: theme.envoiceColorsExtensions.background,
                child: Padding(
                  padding: padding.all(Dimensions.medium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Team ${widget.battingTeam}",
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                              'CRR : ${calculateCurrentRunRate(totalTeamScore).toStringAsFixed(2)}'),
                          Text('RRR : ${requiredRunRate(targetScore, remainingBalls).toStringAsFixed(2)}'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${totalTeamScore}/$totalTeamWicket',
                            style: theme.textTheme.headlineLarge,
                          ),
                          Text(
                              '${totalTeamOvers}.${totalTeamBalls}/${maxOvers} Overs'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Space(Dimensions.small),
              Column(
                children: [
                  Padding(
                    padding: padding.symmetric(horizontal: Dimensions.small),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Batting",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.envoiceColorsExtensions.background,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "R",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "B",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "4s",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "6s",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.large),
                            Text(
                              "SR",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding.symmetric(horizontal: Dimensions.smaller),
                    child: Divider(
                      color: theme.envoiceColorsExtensions.secondary
                          .withOpacity(0.3),
                      thickness: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            WicketLiveAssets.images.bat.image(
                              width: 25,
                              height: 25,
                            ),
                            Space(Dimensions.smallest),
                            InkWell(
                              onTap: () async {
                                if (remainingPlayer.length > 0) {
                                  bool? battingPlayerChanged =
                                      await _showBattingDialog(
                                          widget.matchId, true);
                                  if (battingPlayerChanged == true) {
                                    setState(() {
                                      battingPlayerRuns = 0;
                                      battingPlayerBalls = 0;
                                      battingPlayerFours = 0;
                                      battingPlayerSixes = 0;
                                      strikeRate = '0';
                                    });
                                  }
                                }
                              },
                              child: Text(
                                battingPlayer,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              battingPlayerRuns.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              battingPlayerBalls.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              battingPlayerFours.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              battingPlayerSixes.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.large),
                            Text(
                              strikeRate != 'NaN'
                                  ? strikeRate != 'Infinity'
                                      ? strikeRate
                                      : '0'
                                  : '0',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Space(Dimensions.smaller),
                  Padding(
                    padding: padding.symmetric(horizontal: Dimensions.small),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bowling",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.envoiceColorsExtensions.background,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "B",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "M",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "R",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              "W",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.large),
                            Text(
                              "Eco",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding.symmetric(horizontal: Dimensions.smaller),
                    child: Divider(
                      color: theme.envoiceColorsExtensions.secondary
                          .withOpacity(0.3),
                      thickness: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            WicketLiveAssets.images.ball.image(
                              width: 25,
                              height: 25,
                            ),
                            Space(Dimensions.smallest),
                            InkWell(
                              onTap: () async {
                                if (remainingBowlingPlayer.length > 0) {
                                  bool? isPlayerChanged =
                                      await _dialogBuilderOnOverComplete(
                                          context, false);
                                  if (isPlayerChanged == true) {
                                    setState(() {
                                      extraRunCount = 0;
                                      economy = '0';
                                      ballingPlayerWickets = 0;
                                      wideBallCount = 0;
                                      ballingPlayerRuns = 0;
                                      ballingPlayerBall = 0;
                                    });
                                  }
                                }
                              },
                              child: Text(
                                ballingPlayer,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              ballingPlayerBall.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              ballingPlayerMaidenOver.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              ballingPlayerRuns.toString() == "-1"
                                  ? '0'
                                  : ballingPlayerRuns.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.small),
                            Text(
                              ballingPlayerWickets.toString(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                            Space(Dimensions.large),
                            Text(
                              economy != 'NaN' &&
                                      economy != 'Infinity' &&
                                      economy != '-Infinity'
                                  ? economy
                                  : '0',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.envoiceColorsExtensions.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Space(Dimensions.small),
              Text(
                'Team ${widget.battingTeam} : ${totalTeamScore}/$totalTeamWicket',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.envoiceColorsExtensions.background,
                ),
              ),
              Space(Dimensions.small),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      displayOverScore.length > 6 ? 6 : displayOverScore.length,
                  itemBuilder: (context, index) {
                    int reversedIndex = displayOverScore.length - index - 1;
                    return Padding(
                      padding: padding.all(Dimensions.smallest),
                      child: CircleAvatar(
                        backgroundColor: displayOverScore[reversedIndex] != 'W'
                            ? displayOverScore[reversedIndex] == '6'
                                ? Colors.green
                                : displayOverScore[reversedIndex] == '4'
                                    ? Colors.blue
                                    : theme.envoiceColorsExtensions.background
                            : theme.envoiceColorsExtensions.error,
                        child: Text(
                          displayOverScore[reversedIndex],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: displayOverScore[reversedIndex] == 'W' ||
                                    displayOverScore[reversedIndex] == '6' ||
                                    displayOverScore[reversedIndex] == '4'
                                ? theme.envoiceColorsExtensions.background
                                : theme.envoiceColorsExtensions.onBackground,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateCurrentRunRate(int totalScore) {
    double totalBall = totalTeamOvers + (totalTeamBalls / 10);
    if (totalBall < 1) {
      return 0.0;
    }
    return totalScore.toDouble() / totalBall;
  }

  double requiredRunRate(int targetScore,int remainingBalls) {
    if(remainingBalls == 0 || targetScore == 0){
      return 0.0;
    }
    return targetScore/(remainingBalls/6);
}

  void updateScore(String run) async {
    if (targetScore <= 0 && remainingBalls > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Future.delayed(const Duration(microseconds: 1)).then(
            (_) async {
              await _dialogBuilderInningsCompleted(context, true);
            },
          );
        },
      );
    } else if (remainingBalls == 0 && targetScore > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Future.delayed(const Duration(microseconds: 1)).then(
            (_) async {
              await _dialogBuilderInningsCompleted(context, false);
            },
          );
        },
      );
    } else if (targetScore == 0 && remainingBalls == 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Future.delayed(const Duration(microseconds: 1)).then(
            (_) async {
              await _dialogBuilderInningsCompleted(context, true);
            },
          );
        },
      );
    } else {
      if (run == "Retired") {
        if (remainingPlayer.length > 0) {
          bool? battingPlayerChanged =
              await _showBattingDialog(widget.matchId, false);
          if (battingPlayerChanged == true) {
            setState(() {
              battingPlayerRuns = 0;
              battingPlayerBalls = 0;
              battingPlayerFours = 0;
              battingPlayerSixes = 0;
              strikeRate = '0';
            });
          }
        }
      } else {
        if (totalTeamOvers != maxOvers) {
          if (totalTeamWicket != maxWickets) {
            if (run != 'Undo') {
              if (run != 'W') {
                setState(() {
                  displayOverScore.add(run);
                  updateCounts(run);
                });
                if (run == 'WD') {
                  await _databaseHelper.InsertInningHighlight(
                      'Team ${widget.battingTeam}',
                      battingPlayer,
                      '',
                      '0',
                      battingPlayerFours.toString(),
                      battingPlayerSixes.toString(),
                      (battingPlayerRuns / battingPlayerBalls * 100)
                          .toStringAsFixed(2),
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      widget.createTeamId,
                      widget.matchesId,
                      inningDetailId,
                      '0',
                      '0');
                  await _databaseHelper.InsertInningHighlight(
                      'Team ${widget.bowlingTeam}',
                      ballingPlayer,
                      '',
                      '',
                      '',
                      '',
                      '',
                      "1",
                      "1",
                      extraRunCount.toString(),
                      '0',
                      '0',
                      '',
                      (ballingPlayerRuns / (battingPlayerBalls / 6))
                          .toStringAsFixed(2),
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      widget.createTeamId,
                      widget.matchesId,
                      inningDetailId,
                      '0',
                      '0');
                } else {
                  await _databaseHelper.InsertInningHighlight(
                      'Team ${widget.battingTeam}',
                      battingPlayer,
                      perBallScoreCount.toString(),
                      '1',
                      battingPlayerFours.toString(),
                      battingPlayerSixes.toString(),
                      (battingPlayerRuns / battingPlayerBalls * 100)
                          .toStringAsFixed(2),
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      widget.createTeamId,
                      widget.matchesId,
                      inningDetailId,
                      perBallScoreCount.toString() == "1" ? '1' : '0',
                      perBallScoreCount.toString() == "2" ? '1' : '0');
                  await _databaseHelper.InsertInningHighlight(
                      'Team ${widget.bowlingTeam}',
                      ballingPlayer,
                      '',
                      '',
                      '',
                      '',
                      '',
                      perBallScoreCount.toString(),
                      "0",
                      extraRunCount.toString(),
                      '1',
                      '0',
                      '',
                      (ballingPlayerRuns / (ballingPlayerBall / 6))
                          .toStringAsFixed(2),
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      widget.createTeamId,
                      widget.matchesId,
                      inningDetailId,
                      perBallScoreCount.toString() == "1" ? '1' : '0',
                      perBallScoreCount.toString() == "2" ? '1' : '0');
                }
              } else {
                bool? isWicketTaken = await _dialogBuilderOnWicket(context);
                if (isWicketTaken == true) {
                  setState(() {
                    displayOverScore.add(run);
                    playedPlayerWicket.add(battingPlayer);
                    remainingPlayer.remove(battingPlayer);
                  });
                  if (remainingPlayer.length > 0) {
                    bool? battingPlayerChanged =
                        await _showBattingDialog(widget.matchId, false);
                    if (battingPlayerChanged == true) {
                      setState(() {
                        battingPlayerRuns = 0;
                        battingPlayerBalls = 0;
                        battingPlayerFours = 0;
                        battingPlayerSixes = 0;
                        strikeRate = '0';
                      });
                    }
                  } else {
                    // setState(() {
                    //   targetCount = scoreCount + 1;
                    // });
                    _dialogBuilderInningsCompleted(context, false);
                  }
                  if (totalTeamBalls > 4) {
                    if (remainingBowlingPlayer.length > 0) {
                      if (totalTeamOvers != maxOvers) {
                        bool? isPlayerChanged =
                            await _dialogBuilderOnOverComplete(context, false);
                        if (isPlayerChanged == true) {
                          setState(() {
                            extraRunCount = 0;
                            economy = '0';
                            ballingPlayerWickets = 0;
                            wideBallCount = 0;
                            ballingPlayerRuns = 0;
                            ballingPlayerBall = 0;
                          });
                        }
                      } else {
                        // setState(() {
                        //   targetCount = scoreCount + 1;
                        // });
                        _dialogBuilderInningsCompleted(context, false);
                      }
                    } else {
                      // setState(() {
                      //   targetCount = scoreCount + 1;
                      // });
                      _dialogBuilderInningsCompleted(context, false);
                    }
                  }
                  if (totalTeamBalls > 4) {
                    totalTeamOvers++;
                    totalTeamBalls = 0;
                  } else {
                    totalTeamBalls++;
                  }
                } else {}
              }
            } else {
              if (totalTeamBalls != 0) {
                if (displayOverScore.isNotEmpty) {
                  setState(() async {
                    if (displayOverScore.last != 'W') {
                      undoCounts(displayOverScore.last);
                      await _databaseHelper.deleteLastTwoRows();
                      displayOverScore.removeLast();
                      setState(() {});
                    } else {
                      Fluttertoast.showToast(
                        msg: "After Getting a wicket you can't undo ball",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  });
                }
              } else {
                if (displayOverScore.last == 'WD') {
                  undoCounts(displayOverScore.last);
                  await _databaseHelper.deleteLastTwoRows();
                  displayOverScore.removeLast();
                  setState(() {});
                } else {
                  Fluttertoast.showToast(
                    msg: "You Can't Undo Now",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              }
            }
          } else {
            run != 'Undo'
                ? await _dialogBuilderInningsCompleted(context, false)
                : UndoButton(run);
          }
        } else {
          run != 'Undo' ? null : UndoButton(run);
        }
      }
    }
  }

  void updateCounts(String run) async {
    switch (run) {
      case '0':
        perBallScoreCount = 0;
        ballingPlayerBall++;
        break;
      case '1':
        totalTeamScore++;
        if (targetScore > 0) {
          targetScore--;
        }
        perBallScoreCount = 1;
        battingPlayerRuns++;
        ballingPlayerRuns++;
        ballingPlayerBall++;
        break;
      case 'WD':
        totalTeamScore++;
        extraRunCount++;
        if (targetScore > 0) {
          targetScore--;
        }
        totalTeamWideBalls++;
        ballingPlayerRuns++;
        break;
      case '2':
        perBallScoreCount = 2;
        totalTeamScore += 2;
        if (targetScore > 0) {
          targetScore -= 2;
        }
        battingPlayerRuns += 2;
        ballingPlayerRuns += 2;
        ballingPlayerBall++;
        break;
      case '4':
        perBallScoreCount = 4;
        totalTeamScore += 4;
        if (targetScore > 0) {
          targetScore -= 4;
        }
        battingPlayerRuns += 4;
        ballingPlayerRuns += 4;
        battingPlayerFours++;
        ballingPlayerBall++;
        break;
      case '6':
        perBallScoreCount = 6;
        totalTeamScore += 6;
        if (targetScore > 0) {
          targetScore -= 6;
        }
        battingPlayerRuns += 6;
        ballingPlayerRuns += 6;
        battingPlayerSixes++;
        ballingPlayerBall++;
        break;
    }

    if (run != 'WD') {
      if (totalTeamBalls > 4) {
        totalTeamOvers++;
        if (remainingBalls > 0) {
          remainingBalls--;
        }
        battingPlayerBalls++;
        totalTeamBalls = 0;
        setState(() {
          bowledPlayerList.add(ballingPlayer);
          remainingBowlingPlayer.remove(ballingPlayer);
        });
        if (remainingBowlingPlayer.length > 0) {
          bool? isPlayerChanged =
              await _dialogBuilderOnOverComplete(context, false);
          if (isPlayerChanged == true) {
            setState(() {
              extraRunCount = 0;
              economy = '0';
              ballingPlayerWickets = 0;
              wideBallCount = 0;
              ballingPlayerRuns = 0;
              ballingPlayerBall = 0;
            });
          }
        } else {}
      } else {
        if (remainingBalls > 0) {
          remainingBalls--;
        }
        totalTeamBalls++;
        battingPlayerBalls++;
      }
    }
  }

  void undoCounts(String run) {
    switch (run) {
      case '0':
        if (ballingPlayerBall != 0) {
          ballingPlayerBall--;
        }
        break;
      case '1':
        if (totalTeamScore > 0) {
          totalTeamScore--;
        }
        if (battingPlayerRuns > 0) {
          battingPlayerRuns--;
        }
        if (ballingPlayerRuns > 0) {
          ballingPlayerRuns--;
        }
        targetScore++;
        if (ballingPlayerBall != 0) {
          ballingPlayerBall--;
        }
        break;
      case 'WD':
        if (totalTeamScore > 0) {
          totalTeamScore--;
        }
        if (ballingPlayerRuns > 0) {
          ballingPlayerRuns--;
        }
        if (totalTeamWideBalls > 0) {
          totalTeamWideBalls--;
        }
        targetScore++;
        extraRunCount--;
        break;
      case '2':
        if (totalTeamScore > 0) {
          totalTeamScore -= 2;
        }
        if (battingPlayerRuns > 0) {
          battingPlayerRuns -= 2;
        }
        if (ballingPlayerRuns > 0 || ballingPlayerBall > 0) {
          ballingPlayerRuns -= 2;
          ballingPlayerBall--;
        }
        targetScore += 2;
        break;
      case '4':
        if (totalTeamScore > 0) {
          totalTeamScore -= 4;
        }
        if (battingPlayerRuns > 0) {
          battingPlayerRuns -= 4;
        }
        if (ballingPlayerRuns > 0 || ballingPlayerBall > 0) {
          ballingPlayerRuns -= 4;
          ballingPlayerBall--;
        }
        if (battingPlayerFours > 0) {
          battingPlayerFours--;
        }
        targetScore += 4;
        break;
      case '6':
        if (totalTeamScore > 0) {
          totalTeamScore -= 6;
        }
        if (battingPlayerRuns > 0) {
          battingPlayerRuns -= 6;
        }
        if (ballingPlayerRuns > 0 || ballingPlayerBall > 0) {
          ballingPlayerRuns -= 6;
          ballingPlayerBall--;
        }
        if (battingPlayerSixes > 0) {
          battingPlayerSixes--;
        }
        targetScore += 6;
        break;
    }

    if (run != 'WD') {
      if (totalTeamBalls > 0) {
        if (totalTeamBalls > 0) {
          totalTeamBalls--;
        }
        if (battingPlayerBalls > 0) {
          battingPlayerBalls--;
        }
        remainingBalls++;
      } else {
        if (totalTeamOvers > 0) {
          if (totalTeamOvers > 0) {
            totalTeamOvers--;
          }
          if (ballingPlayerBall > 0) {
            ballingPlayerBall--;
          }
          totalTeamBalls = 5;
          if (battingPlayerBalls > 0) {
            battingPlayerBalls--;
          }
          remainingBalls++;
        }
      }
    }
  }

  void UndoButton(String run) {
    if (run == 'Undo' && displayOverScore.isNotEmpty) {
      setState(() {
        if (displayOverScore.last != 'W') {
          undoCounts(displayOverScore.last);
          displayOverScore.removeLast();
        } else {
          Fluttertoast.showToast(
            msg: "You can't do undo after a wicket",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // if (totalTeamWicket > 0) {
          //   totalTeamWicket--;
          // }
          //
          // if (ballingPlayerWickets > 0) {
          //   ballingPlayerWickets--;
          // }
          //
          // if (totalTeamBalls > 0) {
          //   if (totalTeamBalls > 0) {
          //     totalTeamBalls--;
          //   }
          //   if (battingPlayerBalls > 0) {
          //     battingPlayerBalls--;
          //   }
          // } else {
          //   if (totalTeamOvers > 0) {
          //     totalTeamOvers--;
          //   }
          //   if (ballingPlayerBall > 0) {
          //     ballingPlayerBall--;
          //   }
          //   totalTeamBalls = 5;
          //   if (battingPlayerBalls > 0) {
          //     battingPlayerBalls--;
          //   }
          //   remainingBalls++;
          // }
        }
      });
    }
  }

  Future<bool?> _dialogBuilderOnWicket(BuildContext context) {
    final DB _databaseHelper = DB();
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    String selectedWicketOption = '';
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Column(
              children: [
                Text(
                    'Team ${widget.battingTeam} :- ${totalTeamScore}/${totalTeamWicket}'),
                Text('How did the batsman got Out?'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWicketOption = 'Bowled';
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: padding.all(Dimensions.smallest),
                              child: Row(
                                children: [
                                  Space(Dimensions.smaller),
                                  WicketLiveAssets.images.bowled.image(
                                      width:
                                          MediaQuery.sizeOf(context).width / 12,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12),
                                  Space(Dimensions.small),
                                  Text(
                                    'Bowled',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            elevation: 5,
                            color: selectedWicketOption == 'Bowled'
                                ? Colors.green
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWicketOption = 'Catch Out';
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: padding.all(Dimensions.smallest),
                              child: Row(
                                children: [
                                  Space(Dimensions.smaller),
                                  WicketLiveAssets.images.catching.image(
                                      width:
                                          MediaQuery.sizeOf(context).width / 12,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12),
                                  Space(Dimensions.small),
                                  Text(
                                    'Catch Out',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            elevation: 5,
                            color: selectedWicketOption == 'Catch Out'
                                ? Colors.green
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWicketOption = 'Hit Wicket';
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: padding.all(Dimensions.smallest),
                              child: Row(
                                children: [
                                  Space(Dimensions.smaller),
                                  WicketLiveAssets.images.hitWicket.image(
                                      width:
                                          MediaQuery.sizeOf(context).width / 12,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12),
                                  Space(Dimensions.small),
                                  Text(
                                    'Hit Wicket',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            elevation: 5,
                            color: selectedWicketOption == 'Hit Wicket'
                                ? Colors.green
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWicketOption = 'Out Of Ground';
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: padding.all(Dimensions.smallest),
                              child: Row(
                                children: [
                                  Space(Dimensions.smaller),
                                  WicketLiveAssets.images.cricketGround.image(
                                      width:
                                          MediaQuery.sizeOf(context).width / 12,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12),
                                  Space(Dimensions.small),
                                  Text(
                                    'Out Of Ground',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            elevation: 5,
                            color: selectedWicketOption == 'Out Of Ground'
                                ? Colors.green
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWicketOption = 'Direct On Walls';
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: padding.all(Dimensions.smallest),
                              child: Row(
                                children: [
                                  Space(Dimensions.smaller),
                                  WicketLiveAssets.images.wall.image(
                                      width:
                                          MediaQuery.sizeOf(context).width / 12,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12),
                                  Space(Dimensions.small),
                                  Text(
                                    'Direct On Walls',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            elevation: 5,
                            color: selectedWicketOption == 'Direct On Walls'
                                ? Colors.green
                                : null,
                          ),
                        ),
                        // AnimatedEmoji(AnimatedEmojis.rocket),
                      ],
                    );
                  }),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Yes'),
                onPressed: () async {
                  if (selectedWicketOption.isNotEmpty ||
                      selectedWicketOption != '') {
                    await _databaseHelper.InsertInningHighlight(
                        'Team ${widget.battingTeam}',
                        battingPlayer,
                        '0',
                        '1',
                        battingPlayerFours.toString(),
                        battingPlayerSixes.toString(),
                        (battingPlayerRuns / battingPlayerBalls * 100)
                            .toStringAsFixed(2),
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.createTeamId,
                        widget.matchesId,
                        inningDetailId,
                        '0',
                        '0');
                    await _databaseHelper.InsertInningHighlight(
                        'Team ${widget.bowlingTeam}',
                        ballingPlayer,
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        "0",
                        extraRunCount.toString(),
                        '1',
                        '1',
                        '',
                        (ballingPlayerRuns / (ballingPlayerBall / 6))
                            .toStringAsFixed(2),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.createTeamId,
                        widget.matchesId,
                        inningDetailId,
                        '0',
                        '0');

                    setState(() {
                      totalTeamWicket++;
                      ballingPlayerWickets++;
                      ballingPlayerBall++;
                      battingPlayerRuns = 0;
                      perBallScoreCount = 0;
                      remainingBalls--;
                    });
                    if (selectedWicketOption == 'Out Of Ground') {
                      await _databaseHelper.MatchCollectedFund(
                          battingPlayer,
                          '1',
                          '10',
                          DateFormat('dd-MM-yyyy').format(DateTime.now()),
                          widget.createTeamId,
                          widget.matchesId);
                    }
                    Navigator.of(context).pop(true);
                  } else {
                    Fluttertoast.showToast(msg: "Please choose wicket type");
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<bool?> _showBattingDialog(String matchId, bool firstTime) {
    String tempSelectedPlayer = '';
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text(
                      'Team ${widget.battingTeam} :- ${totalTeamScore}/${totalTeamWicket}'),
                  Text("Select Batting Player"),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: remainingPlayer.length,
                  itemBuilder: (context, index) {
                    bool isCaptain =
                        remainingPlayer[index] == tempSelectedPlayer;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          tempSelectedPlayer =
                              remainingPlayer[index]; // Update local variable
                        });
                      },
                      child: Card(
                        elevation: 10,
                        color: isCaptain ? Colors.lightGreen : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  WicketLiveAssets.images.cricketPlayer.image(
                                    width: 35,
                                    height: 35,
                                  ),
                                  Space(Dimensions.medium),
                                  Text(
                                    remainingPlayer.elementAt(index),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                              isCaptain
                                  ? WicketLiveAssets.images.bat.image(
                                      width: 35,
                                      height: 35,
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                firstTime
                    ? SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      battingPlayer = tempSelectedPlayer; // Apply the change
                    });

                    // Rest of your logic when "OK" is pressed
                    if (battingPlayer.isNotEmpty) {
                      sharedPreferenceHelper.saveBattingPlayer(battingPlayer);
                      Navigator.of(context).pop(true);
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select a player to Bat",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _dialogBuilderOnOverComplete(
      BuildContext context, bool firstTime) {
    String tempSelectedPlayer = '';
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Column(
              children: [
                Text(
                    'Team ${widget.battingTeam} :- ${totalTeamScore}/${totalTeamWicket}'),
                Text('Choose next Bowler to bowl'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool isCaptain =
                      remainingBowlingPlayer[index] == tempSelectedPlayer;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedPlayer = remainingBowlingPlayer[index];
                      });
                    },
                    child: Card(
                      color: isCaptain ? Colors.lightGreen : null,
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                WicketLiveAssets.images.cricketPlayer.image(
                                  width: 35,
                                  height: 35,
                                ),
                                Space(Dimensions.medium),
                                Text(
                                  remainingBowlingPlayer[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            isCaptain
                                ? WicketLiveAssets.images.ball.image(
                                    width: 35,
                                    height: 35,
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: remainingBowlingPlayer.length,
              ),
            ),
            actions: <Widget>[
              firstTime
                  ? SizedBox.shrink()
                  : TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    ballingPlayer = tempSelectedPlayer;
                  });
                  if (ballingPlayer.isNotEmpty) {
                    sharedPreferenceHelper.saveBallingPlayer(ballingPlayer);
                    Navigator.of(context).pop(true);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please select a player to Bowl",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> PdfSummary() async {
    print('2');
    print(widget.matchesId);
    print(widget.matchId);
    await _databaseHelper.initDatabase();
    pdfSummary =
        await _databaseHelper.getInningHighlightByMatchId(widget.matchesId);
    setState(() {});
    if (pdfSummary.isNotEmpty) {
      print('3');
      pdfSummary.forEach((match) {
        if (int.parse(match['inningDetailId'].toString()) % 2 != 0 &&
            int.parse(match['id'].toString()) % 2 != 0) {
          innings1Batter.add(match);
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 != 0 &&
            int.parse(match['id'].toString()) % 2 == 0) {
          innings1Bowler.add(match);
          inning1Wicket = inning1Wicket +
              int.parse(match['wicket'].toString() == ''
                  ? "0"
                  : match['wicket'].toString());
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 == 0 &&
            int.parse(match['id'].toString()) % 2 != 0) {
          innings2Batter.add(match);
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 == 0 &&
            int.parse(match['id'].toString()) % 2 == 0) {
          innings2Bowler.add(match);
          inning2Wicket = inning2Wicket +
              int.parse(match['wicket'].toString() == ''
                  ? "0"
                  : match['wicket'].toString());
          setState(() {});
        }
      });

      print("666");
      print(innings1Bowler);

      innings1Batter.forEach((player) {
        String playerName = player['playerName'];
        int runs = int.parse(player['runScored'].toString() == ''
            ? '0'
            : player['runScored'].toString());
        int balls = int.parse(player['balls'].toString() == ''
            ? '0'
            : player['balls'].toString());
        int fours = int.parse(player['fours'].toString() == ''
            ? '0'
            : player['fours'].toString());
        int sixes = int.parse(player['sixes'].toString() == ''
            ? '0'
            : player['sixes'].toString());
        int singleRun = int.parse(player['singleRun'].toString() == ''
            ? '0'
            : player['singleRun'].toString());
        int doubleRun = int.parse(player['doubleRun'].toString() == ''
            ? '0'
            : player['doubleRun'].toString());
        double strikeRate = double.parse(player['strikeRate'].toString() == ''
            ? '0'
            : player['strikeRate'].toString());

        if (playerStatsMapInnings1Batter.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings1Batter[playerName]?[0] += runs; // Total runs
          playerStatsMapInnings1Batter[playerName]?[1] += balls; // Total balls
          playerStatsMapInnings1Batter[playerName]?[2] = fours; // Total fours
          playerStatsMapInnings1Batter[playerName]?[3] = sixes; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[4] +=
              singleRun; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[5] +=
              doubleRun; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[6] =
              strikeRate; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          setState(() {});
          playerStatsMapInnings1Batter[playerName] = [
            runs,
            balls,
            fours,
            sixes,
            singleRun,
            doubleRun,
            strikeRate
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Calculate strike rate
      playerStatsMapInnings1Batter.forEach((playerName, stats) {
        int runs = stats[0];
        int balls = stats[1];
        if (balls != 0) {
          double strikeRate = (runs / balls) * 100;
          playerStatsMapInnings1Batter[playerName]?[6] =
              strikeRate.round(); // Round to integer
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings1Batter.forEach((playerName, stats) {
        print(
            '$playerName: Runs: ${stats[0]}, Balls: ${stats[1]}, Fours: ${stats[2]}, Sixes: ${stats[3]}, singleRunCount: ${stats[4]}, doubleRunCount: ${stats[5]}, Strike Rate: ${stats[6]}');
      });

      innings2Batter.forEach((player) {
        String playerName = player['playerName'];
        int runs = int.parse(player['runScored'].toString() == ''
            ? '0'
            : player['runScored'].toString());
        int balls = int.parse(player['balls'].toString() == ''
            ? '0'
            : player['balls'].toString());
        int fours = int.parse(player['fours'].toString() == ''
            ? '0'
            : player['fours'].toString());
        int sixes = int.parse(player['sixes'].toString() == ''
            ? '0'
            : player['sixes'].toString());
        int singleRun = int.parse(player['singleRun'].toString() == ''
            ? '0'
            : player['singleRun'].toString());
        int doubleRun = int.parse(player['doubleRun'].toString() == ''
            ? '0'
            : player['doubleRun'].toString());
        double strikeRate = double.parse(player['strikeRate'].toString() == ''
            ? '0'
            : player['strikeRate'].toString());

        if (playerStatsMapInnings2Batter.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings2Batter[playerName]?[0] += runs; // Total runs
          playerStatsMapInnings2Batter[playerName]?[1] += balls; // Total balls
          playerStatsMapInnings2Batter[playerName]?[2] = fours; // Total fours
          playerStatsMapInnings2Batter[playerName]?[3] = sixes; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[4] +=
              singleRun; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[5] +=
              doubleRun; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[6] =
              strikeRate; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          setState(() {});
          playerStatsMapInnings2Batter[playerName] = [
            runs,
            balls,
            fours,
            sixes,
            singleRun,
            doubleRun,
            strikeRate
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Calculate strike rate
      playerStatsMapInnings2Batter.forEach((playerName, stats) {
        int runs = stats[0];
        int balls = stats[1];
        if (balls != 0) {
          double strikeRate = (runs / balls) * 100;
          playerStatsMapInnings2Batter[playerName]?[6] =
              strikeRate.round(); // Round to integer
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings2Batter.forEach((playerName, stats) {
        print(
            '$playerName: Runs: ${stats[0]}, Balls: ${stats[1]}, Fours: ${stats[2]}, Sixes: ${stats[3]}, singleRunCount: ${stats[4]}, doubleRunCount: ${stats[5]}, Strike Rate: ${stats[6]}');
      });

      innings1Bowler.forEach((player) {
        String playerName = player['playerName'];
        int over = int.parse(
            player['over'].toString() == '' ? '0' : player['over'].toString());
        int runsConceded = int.parse(player['runsConceded'].toString() == ''
            ? '0'
            : player['runsConceded'].toString());
        int extra = int.parse(player['extra'].toString() == ''
            ? '0'
            : player['extra'].toString());
        int wicket = int.parse(player['wicket'].toString() == ''
            ? '0'
            : player['wicket'].toString());
        double economy = double.parse(player['economy'].toString() == ''
            ? '0'
            : player['economy'].toString());

        if (playerStatsMapInnings1Baller.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings1Baller[playerName]?[0] += over; // Total runs
          playerStatsMapInnings1Baller[playerName]?[1] +=
              runsConceded; // Total balls
          playerStatsMapInnings1Baller[playerName]?[2] = extra; // Total fours
          playerStatsMapInnings1Baller[playerName]?[3] = extra; // Total fours
          playerStatsMapInnings1Baller[playerName]?[4] += wicket; // Total sixes
          playerStatsMapInnings1Baller[playerName]?[5] = economy; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          playerStatsMapInnings1Baller[playerName] = [
            over,
            runsConceded,
            extra,
            extra,
            wicket,
            economy
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings1Baller.forEach((playerName, stats) {
        print(
            '$playerName: over: ${stats[0]}, runsConceded: ${stats[1]}, extra: ${stats[2]}, extra: ${stats[3]}, wicket: ${stats[4]}, economy: ${stats[5]}');
      });

      innings2Bowler.forEach((player) {
        String playerName = player['playerName'];
        int over = int.parse(player['over'].toString());
        int runsConceded = int.parse(player['runsConceded'].toString() == ''
            ? '0'
            : player['runsConceded'].toString());
        int extra = int.parse(player['extra'].toString());
        int wicket = int.parse(player['wicket'].toString() == ''
            ? '0'
            : player['wicket'].toString());
        double economy = double.parse(player['economy'].toString());

        if (playerStatsMapInnings2Baller.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings2Baller[playerName]?[0] += over; // Total runs
          playerStatsMapInnings2Baller[playerName]?[1] +=
              runsConceded; // Total balls
          playerStatsMapInnings2Baller[playerName]?[2] = extra; // Total fours
          playerStatsMapInnings2Baller[playerName]?[3] = extra; // Total fours
          playerStatsMapInnings2Baller[playerName]?[4] += wicket; // Total sixes
          playerStatsMapInnings2Baller[playerName]?[5] = economy; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          playerStatsMapInnings2Baller[playerName] = [
            over,
            runsConceded,
            extra,
            extra,
            wicket,
            economy
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings2Baller.forEach((playerName, stats) {
        print(
            '$playerName: over: ${stats[0]}, runsConceded: ${stats[1]}, extra: ${stats[2]}, extra: ${stats[3]}, wicket: ${stats[4]}, economy: ${stats[5]}');
      });

      innings1BatterFinalList = formatData(playerStatsMapInnings1Batter);
      innings1BallerFinalList = formatData(playerStatsMapInnings1Baller);
      innings2BatterFinalList = formatData(playerStatsMapInnings2Batter);
      innings2BallerFinalList = formatData(playerStatsMapInnings2Baller);
      setState(() {});
    } else {
      print('4');
      print(pdfSummary);
      print("No inning details for today's match.");
    }

    for (var count = 0; count < innings1BallerFinalList.length; count++) {
      setState(() {
        innings1TotalRuns += int.parse(
            innings1BallerFinalList[count].toString().split("_")[2].toString());
      });
    }

    for (var count = 0; count < innings2BallerFinalList.length; count++) {
      setState(() {
        innings2TotalRuns += int.parse(
            innings2BallerFinalList[count].toString().split("_")[2].toString());
      });
    }
  }

  List<String> formatData(Map<String, List> data) {
    List<String> formattedList = [];
    data.forEach((key, value) {
      String formattedString = "$key" + "_" + value.join("_");
      formattedList.add(formattedString);
    });
    return formattedList;
  }
}
