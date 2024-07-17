import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/core.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/dashboard/home/inning_2_screen.dart';
import 'package:wicket_live_apk/screens/dashboard/home/match_collected_fund_screen.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';
import 'package:intl/intl.dart';

class MatchScore extends StatefulWidget {
  const MatchScore({
    super.key,
    required this.matchId,
    required this.createTeamId,
    required this.matchesId,
  });

  final String matchId;
  final String createTeamId;
  final String matchesId;

  @override
  State<MatchScore> createState() => _MatchScoreState();
}

class _MatchScoreState extends State<MatchScore> {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());

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
  int wicketCount = 0;
  int bowlerWicketCount = 0;
  int maxWicketCount = 0;
  int scoreCount = 0;
  int batsmanScoreCount = 0;
  int batsmanScoreCountForStrikeRate = 0;
  int bowlerScoreCount = 0;
  int bowlerBallCount = 0;
  int batsmanBallCount = 0;
  int ballCount = 0;
  int ballCountForCalc = 0;
  int overCount = 0;
  int sixCount = 0;
  int fourCount = 0;
  int maidenOverCount = 0;
  int wideBallCount = 0;
  int extraRunCount = 0;
  int maxOverCount = 0;
  int requiredRunRate = 0;
  int targetCount = 0;
  double currentRunRate = 0.0;
  final DB _databaseHelper = DB();
  List<Map<String, dynamic>> matchesDetails = [];
  bool dataReady = false;
  String battingTeam = '';
  String ballingTeam = '';
  String battingPlayer = '';
  String ballingPlayer = '';
  String strikeRate = '0';
  String economy = '0';
  List<String> remainingPlayer = [];
  List<String> playedPlayerWicket = [];
  List<String> remainingBowlingPlayer = [];
  List<String> bowledPlayerList = [];

  getMatchDetailsData() async {
    final createdTeam = await _databaseHelper.getCreatedTeam();
    setState(() {
      matchesDetails = createdTeam;
      maxOverCount = int.parse(matchesDetails[0]["numberOfOver"]);
      String winningTeam = sharedPreferenceHelper.winningTeam ?? '';
      String winningTeamBatBall = sharedPreferenceHelper.winningTeamBatBall ?? '';

      if (winningTeam ==
          "Team ${sharedPreferenceHelper.teamACaptain}") {
        if (winningTeamBatBall == "Batting") {
          setState(() {
            battingTeam =
                sharedPreferenceHelper.teamACaptain ?? '';
            ballingTeam = sharedPreferenceHelper.teamBCaptain ?? '';
          });
        } else {
          setState(() {
            battingTeam =
                sharedPreferenceHelper.teamBCaptain ?? '';
            ballingTeam = sharedPreferenceHelper.teamACaptain ?? '';
          });
        }
      } else if(winningTeam ==
          "Team ${sharedPreferenceHelper.teamBCaptain}") {
        if (winningTeamBatBall == "Batting") {
          setState(() {
            battingTeam =
                sharedPreferenceHelper.teamBCaptain ?? '';
            ballingTeam = sharedPreferenceHelper.teamACaptain ?? '';
          });
        } else {
          setState(() {
            battingTeam =
                sharedPreferenceHelper.teamACaptain ?? '';
            ballingTeam = sharedPreferenceHelper.teamBCaptain ?? '';
          });
        }
      }
      battingPlayer = sharedPreferenceHelper.battingPlayer ?? '';
      ballingPlayer = sharedPreferenceHelper.ballingPlayer ?? '';
      dataReady = true;
      remainingPlayer = battingTeam == sharedPreferenceHelper.teamACaptain
          ? sharedPreferenceHelper.teamA ?? []
          : sharedPreferenceHelper.teamB ?? [];
      remainingBowlingPlayer =
          ballingTeam == sharedPreferenceHelper.teamACaptain
              ? sharedPreferenceHelper.teamA ?? []
              : sharedPreferenceHelper.teamB ?? [];
      maxWicketCount = battingTeam == sharedPreferenceHelper.teamACaptain
          ? sharedPreferenceHelper.teamA?.length ?? 0
          : sharedPreferenceHelper.teamB?.length ?? 0;
    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMatchDetailsData();
    _initializeDatabase();
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
          "${widget.matchId} : Inning 1",
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
            onPressed: () async {
              print("inningDetail");
              print(inningDetail);
              inningDetailId = inningDetail[0]["id"].toString();
              updateScore(possibleRuns[index]);
              // CurrentRunRate();
              calculateCurrentRunRate(scoreCount);

              await _inningHighlightDatabase();
              print(inningHighlight);
              setState(() {
                strikeRate =
                    (batsmanScoreCountForStrikeRate / ballCountForCalc * 100)
                        .toStringAsFixed(2);
                economy = (bowlerScoreCount / (bowlerBallCount / 6))
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
      body: dataReady
          ? SafeArea(
              child: Padding(
                padding: padding.all(Dimensions.small),
                child: Column(
                  children: [
                    Text(
                      'Team $battingTeam won toss and elected to bat',
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
                                  "Team $battingTeam",
                                  style: theme.textTheme.headlineMedium,
                                ),
                                Text(
                                    'CRR : ${calculateCurrentRunRate(scoreCount).toStringAsFixed(2)}'),
                                Text('RRR : 0.0'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${scoreCount}/$wicketCount',
                                  style: theme.textTheme.headlineLarge,
                                ),
                                Text(
                                    '${overCount}.${ballCount}/${maxOverCount} Overs'),
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
                          padding:
                              padding.symmetric(horizontal: Dimensions.small),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Batting",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color:
                                      theme.envoiceColorsExtensions.background,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "R",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "B",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "4s",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "6s",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.large),
                                  Text(
                                    "SR",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              padding.symmetric(horizontal: Dimensions.smaller),
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
                                        bool? battingPlayerChanged = await _showBattingDialog(widget.matchId,true);
                                        if (battingPlayerChanged == true) {
                                          setState(() {
                                            batsmanScoreCount = 0;
                                            batsmanScoreCountForStrikeRate = 0;
                                            ballCountForCalc = 0;
                                            fourCount = 0;
                                            sixCount = 0;
                                            batsmanBallCount = 0;
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
                                            color: theme.envoiceColorsExtensions
                                                .background,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    batsmanScoreCountForStrikeRate.toString(),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    batsmanBallCount.toString(),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "${fourCount.toString()}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "${sixCount.toString()}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    strikeRate != 'NaN' ? strikeRate != 'Infinity' ? strikeRate : '0' : '0',
                                    // "${(scoreCount / ballCountForCalc * 100).toStringAsFixed(2)}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Space(Dimensions.smaller),
                        Padding(
                          padding:
                              padding.symmetric(horizontal: Dimensions.small),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Bowling",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color:
                                      theme.envoiceColorsExtensions.background,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "B",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "M",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "R",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "W",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.large),
                                  Text(
                                    "Eco",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              padding.symmetric(horizontal: Dimensions.smaller),
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
                                        if(overCount != maxOverCount) {
                                          bool? isPlayerChanged = await _dialogBuilderOnOverComplete(context);
                                          if (isPlayerChanged == true) {
                                            setState(() {});
                                          }
                                        }
                                        else{
                                          setState(() {
                                            targetCount = scoreCount + 1;
                                          });
                                          _dialogBuilderInningsCompleted(context);
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
                                            color: theme.envoiceColorsExtensions
                                                .background,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    bowlerBallCount.toString(),
                                    // "${overCount}.${ballCount}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    "${maidenOverCount.toString()}",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    bowlerScoreCount.toString(),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    bowlerWicketCount.toString(),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Space(Dimensions.small),
                                  Text(
                                    economy != 'NaN' ? economy != 'Infinity' ? economy : '0' : '0',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .envoiceColorsExtensions.background,
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
                      'Team $battingTeam : ${scoreCount}/$wicketCount',
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
                        itemCount: displayOverScore.length > 6 ? 6 : displayOverScore.length,
                        itemBuilder: (context, index) {
                          // Display the latest 6 records in reverse order
                          int reversedIndex = displayOverScore.length - index - 1;
                          return Padding(
                            padding: padding.all(Dimensions.smallest),
                            child: CircleAvatar(
                              backgroundColor: displayOverScore[reversedIndex] != 'W'
                                  ? displayOverScore[reversedIndex] == '6'
                                      ? Colors.green
                                      : displayOverScore[reversedIndex] == '4'
                                          ? Colors.blue
                                          : theme.envoiceColorsExtensions
                                              .background
                                  : theme.envoiceColorsExtensions.error,
                              child: Text(
                                displayOverScore[reversedIndex],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: displayOverScore[reversedIndex] == 'W' ||
                                          displayOverScore[reversedIndex] == '6' ||
                                          displayOverScore[reversedIndex] == '4'
                                      ? theme.envoiceColorsExtensions.background
                                      : theme
                                          .envoiceColorsExtensions.onBackground,
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
            )
          : Text("Loading...."),
    );
  }

  void updateScore(String run) async {
    if (run == "Retired") {
      if (remainingPlayer.length > 0) {
        bool? battingPlayerChanged = await _showBattingDialog(widget.matchId,true);
        if (battingPlayerChanged == true) {
          setState(() {
            batsmanScoreCount = 0;
            batsmanScoreCountForStrikeRate = 0;
            ballCountForCalc = 0;
            fourCount = 0;
            sixCount = 0;
            batsmanBallCount = 0;
            strikeRate = '0';
          });
        }
      }
    } else{
      if (overCount != maxOverCount) {
        if( wicketCount != maxWicketCount) {
          if (run != 'Undo') {
            if (run != 'W') {
              setState(() {
                displayOverScore.add(run);
                updateCounts(run);
              });
              if(run == 'WD'){
                await _databaseHelper.InsertInningHighlight('Team ${battingTeam}', battingPlayer, '', '0', fourCount.toString(), sixCount.toString(), (batsmanScoreCountForStrikeRate / ballCountForCalc * 100).toStringAsFixed(2), '','','', '', '', '', '',  DateFormat('dd-MM-yyyy').format(DateTime.now()), widget.createTeamId, widget.matchesId, inningDetailId, '0', '0');
                await _databaseHelper.InsertInningHighlight('Team ${ballingTeam}', ballingPlayer, '', '', '', '', '', "1","1",extraRunCount.toString(), '0', '0', '', (bowlerScoreCount / (bowlerBallCount / 6)).toStringAsFixed(2),  DateFormat('dd-MM-yyyy').format(DateTime.now()), widget.createTeamId, widget.matchesId, inningDetailId, '0', '0');

              }
              else{
                await _databaseHelper.InsertInningHighlight('Team ${battingTeam}', battingPlayer, batsmanScoreCount.toString(), '1', fourCount.toString(), sixCount.toString(), (batsmanScoreCountForStrikeRate / ballCountForCalc * 100).toStringAsFixed(2), '','','', '', '', '', '',  DateFormat('dd-MM-yyyy').format(DateTime.now()), widget.createTeamId, widget.matchesId, inningDetailId,batsmanScoreCount.toString() == "1" ? '1' : '0', batsmanScoreCount.toString() == "2" ? '1' : '0');
                await _databaseHelper.InsertInningHighlight('Team ${ballingTeam}', ballingPlayer, '', '', '', '', '', batsmanScoreCount.toString(),"0",extraRunCount.toString(), '1','0', '', (bowlerScoreCount / (bowlerBallCount / 6)).toStringAsFixed(2),  DateFormat('dd-MM-yyyy').format(DateTime.now()), widget.createTeamId, widget.matchesId, inningDetailId,batsmanScoreCount.toString() == "1" ? '1' : '0', batsmanScoreCount.toString() == "2" ? '1' : '0');

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
                  await _showBattingDialog(widget.matchId,false);
                  if (battingPlayerChanged == true) {
                    setState(() {});
                  }
                } else {
                  setState(() {
                    targetCount = scoreCount + 1;
                  });
                  _dialogBuilderInningsCompleted(context);
                }
                if(ballCount > 4){
                  if (remainingBowlingPlayer.length > 0) {
                    if(overCount != maxOverCount) {
                      bool? isPlayerChanged = await _dialogBuilderOnOverComplete(context);
                      if (isPlayerChanged == true) {
                        setState(() {});
                      }
                    }
                    else{
                      setState(() {
                        targetCount = scoreCount + 1;
                      });
                      _dialogBuilderInningsCompleted(context);
                    }
                  } else {
                    setState(() {
                      targetCount = scoreCount + 1;
                    });
                    _dialogBuilderInningsCompleted(context);
                  }
                }
                if (ballCount > 4) {
                  overCount++;
                  ballCount = 0;
                } else {
                  ballCount++;
                }
              } else {}
            }
          } else {
            if(ballCount != 0) {
              if (displayOverScore.isNotEmpty) {
                if (displayOverScore.last != 'W') {
                  await undoCounts(displayOverScore.last);
                  print('harshal');
                  _inningHighlightDatabase();
                  await _databaseHelper.deleteLastTwoRows();
                  print('karan');
                  _inningHighlightDatabase();
                  print('aman');
                  print(inningHighlight);
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
              }
            }
            else{
              if(displayOverScore.last == 'WD'){
                await undoCounts(displayOverScore.last);
                print('harshal');
                _inningHighlightDatabase();
                await _databaseHelper.deleteLastTwoRows();
                print('karan');
                _inningHighlightDatabase();
                print('aman');
                print(inningHighlight);
                displayOverScore.removeLast();
                setState(() {});
              }
              else{
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
        }
        else{
          setState(() {
            targetCount = scoreCount + 1;
          });
          run != 'Undo' ? _dialogBuilderInningsCompleted(context) : UndoButton(run);
        }
      } else {
        setState(() {
          targetCount = scoreCount + 1;
        });
        run != 'Undo' ? _dialogBuilderInningsCompleted(context) : UndoButton(run);
      }
    }

  }

  void updateCounts(String run) async {
    switch (run) {
      case '0':
        batsmanScoreCount = 0;
        bowlerBallCount++;
        batsmanBallCount++;
        break;
      case '1':
        scoreCount++;
        batsmanScoreCount = 1;
        batsmanScoreCountForStrikeRate++;
        bowlerScoreCount++;
        bowlerBallCount++;
        batsmanBallCount++;
        break;
      case 'WD':
        scoreCount++;
        extraRunCount++;
        bowlerScoreCount++;
        break;
      case '2':
        scoreCount += 2;
        batsmanScoreCount = 2;
        batsmanScoreCountForStrikeRate += 2;
        bowlerScoreCount += 2;
        bowlerBallCount++;
        batsmanBallCount++;
        break;
      case '4':
        scoreCount += 4;
        batsmanScoreCount = 4;
        fourCount++;
        batsmanScoreCountForStrikeRate += 4;
        bowlerScoreCount += 4;
        bowlerBallCount++;
        batsmanBallCount++;
        break;
      case '6':
        scoreCount += 6;
        batsmanScoreCount = 6;
        sixCount++;
        batsmanScoreCountForStrikeRate += 6;
        bowlerScoreCount += 6;
        bowlerBallCount++;
        batsmanBallCount++;
        break;
    }

    if (run != 'WD') {
      if (ballCount > 4) {
        overCount++;
        ballCountForCalc++;
        ballCount = 0;
        setState(() {
          bowledPlayerList.add(ballingPlayer);
          remainingBowlingPlayer.remove(ballingPlayer);
        });
        if (remainingBowlingPlayer.length > 0) {
          if(overCount != maxOverCount) {
            bool? isPlayerChanged = await _dialogBuilderOnOverComplete(context);
            if (isPlayerChanged == true) {
              setState(() {});
            }
          }
          else{
            setState(() {
              targetCount = scoreCount + 1;
            });
            _dialogBuilderInningsCompleted(context);
          }
        } else {
          setState(() {
            targetCount = scoreCount + 1;
          });
          _dialogBuilderInningsCompleted(context);
        }
      } else {
        ballCount++;
        ballCountForCalc++;
      }
    }
  }

  Future<void> undoCounts(String run) async {
    switch (run) {
      case '0':
        if(bowlerBallCount != 0){
          bowlerBallCount--;
        }
        break;
      case '1':
        scoreCount--;
        batsmanScoreCountForStrikeRate--;
        if(bowlerBallCount != 0 || bowlerScoreCount != 0){
          bowlerScoreCount--;
          bowlerBallCount--;
        }
        batsmanBallCount--;
        break;
      case 'WD':
        scoreCount--;
        extraRunCount--;
        if(bowlerScoreCount != 0){
          bowlerScoreCount--;
        }
        break;
      case '2':
        scoreCount -= 2;
        batsmanScoreCountForStrikeRate -= 2;
        if(bowlerBallCount != 0 || bowlerScoreCount != 0){
          bowlerScoreCount -= 2;
          bowlerBallCount--;
        }
        batsmanBallCount--;
        break;
      case '4':
        scoreCount -= 4;
        batsmanScoreCountForStrikeRate -= 4;
        if(bowlerBallCount != 0 || bowlerScoreCount != 0){
          bowlerScoreCount -= 4;
          bowlerBallCount--;
        }
        fourCount--;
        batsmanBallCount--;
        break;
      case '6':
        scoreCount -= 6;
        batsmanScoreCountForStrikeRate -= 6;
        if(bowlerBallCount != 0 || bowlerScoreCount != 0){
          bowlerScoreCount -= 6;
          bowlerBallCount--;
        }
        sixCount--;
        batsmanBallCount--;
        break;
    }
    if (run != 'WD') {
      if (ballCount > 0) {
        ballCount--;
        ballCountForCalc--;
      } else {
        overCount--;
        ballCount = 5;
        ballCountForCalc--;
      }
    }
  }

  void undoBallCount() {
    if (displayOverScore.isEmpty) {
      ballCount = 0;
      overCount = 0;
      fourCount = 0;
      sixCount = 0;
      maidenOverCount = 0;
      ballCountForCalc = 0;
    }
  }

  double calculateCurrentRunRate(int totalScore) {
    double totalBall = overCount + (ballCount / 10);
    if (totalBall < 1) {
      return 0.0;
    }
    return totalScore.toDouble() / totalBall;
  }

  void UndoButton(String run) {
    if (run == 'Undo' && displayOverScore.isNotEmpty) {
      setState(() {
        if (displayOverScore.last != 'W') {
          undoCounts(displayOverScore.last);
        displayOverScore.removeLast();
        } else {
          Fluttertoast.showToast(
            msg: "You can't do undo after the wicket",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // wicketCount--;
          // if (ballCount > 0) {
          //   ballCount--;
          //   ballCountForCalc--;
          // } else {
          //   overCount--;
          //   ballCount = 5;
          //   ballCountForCalc--;
          // }
        }
        // if (run == 'Undo') {
        //   undoBallCount();
        // }
      });
    }
  }

  Future<void> _dialogBuilderInningsCompleted(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Inning 1 is Completed !!'),
            content: Text(
              'Team $battingTeam score : ' +
                  ' ${scoreCount}/${wicketCount}\n\n'
                      'Target for Team $ballingTeam : ${targetCount}\n\n'
                      'Are you ready for the next Inning?',
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
                  await sharedPreferenceHelper.saveInning1(true);
                  bool isInning1Completed =
                      await sharedPreferenceHelper.inning1 ?? false;
                  if (isInning1Completed) {
                    sharedPreferenceHelper.saveBattingPlayer("");
                    sharedPreferenceHelper.saveBallingPlayer("");
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Inning2Screen(
                          matchesId : widget.matchesId,
                          matchId: widget.matchId,
                          battingTeam: ballingTeam,
                          bowlingTeam: battingTeam,
                          targetScore: targetCount,
                          maxOvers: maxOverCount,
                          createTeamId: widget.createTeamId,
                        ),
                      ),
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
                Text('Team $battingTeam :- ${scoreCount}/${wicketCount}'),
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
                        'Team ${battingTeam}',
                        battingPlayer,
                        '0',
                        '1',
                        fourCount.toString(),
                        sixCount.toString(),
                        (batsmanScoreCountForStrikeRate /
                                ballCountForCalc *
                                100)
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
                        inningDetailId,'0','0');
                    await _databaseHelper.InsertInningHighlight(
                        'Team ${ballingTeam}',
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
                        (bowlerScoreCount / (bowlerBallCount / 6))
                            .toStringAsFixed(2),
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        widget.createTeamId,
                        widget.matchesId,
                        inningDetailId,'0','0');

                    setState(() {
                      bowlerWicketCount++;
                      wicketCount++;
                      bowlerBallCount++;
                      batsmanScoreCount = 0;
                      batsmanScoreCountForStrikeRate = 0;
                      ballCountForCalc = 0;
                      fourCount = 0;
                      sixCount = 0;
                      batsmanBallCount = 0;
                      strikeRate = '0';
                    });
                    if (selectedWicketOption == 'Out Of Ground') {
                      print(widget.matchesId);
                      print(widget.createTeamId);
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

  Future<bool?> _showBattingDialog(String matchId,bool showNoBtn) {
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
                  Text('Team $battingTeam :- ${scoreCount}/${wicketCount}'),
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
               showNoBtn ? TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Close the dialog
                  },
                  child: Text("Cancel"),
                ) : SizedBox.shrink(),
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

  Future<bool?> _dialogBuilderOnOverComplete(BuildContext context) {
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
                Text('Team $battingTeam :- ${scoreCount}/${wicketCount}'),
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
                onPressed: () {
                  setState(() {
                    ballingPlayer = tempSelectedPlayer;
                  });
                  if (ballingPlayer.isNotEmpty) {
                    sharedPreferenceHelper.saveBallingPlayer(ballingPlayer);
                    extraRunCount = 0;
                    economy = '0';
                    bowlerWicketCount = 0;
                    wideBallCount = 0;
                    bowlerScoreCount = 0;
                    bowlerBallCount = 0;
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
}
