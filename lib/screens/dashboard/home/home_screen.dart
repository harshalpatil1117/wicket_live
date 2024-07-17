import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:network/core/core.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/create_teams/available_players.dart';
import 'package:wicket_live_apk/screens/dashboard/home/match_collected_fund_screen.dart';
import 'package:wicket_live_apk/screens/dashboard/home/match_score_screen.dart';
import 'package:wicket_live_apk/screens/update_team/update_team.dart';
import 'package:wicket_live_apk/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'match_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DB _databaseHelper = DB();
  List<Map<String, dynamic>> matches = [];
  SharedPreferenceHelper sharedPreferenceHelper =
  SharedPreferenceHelper(Preference());

  String battingPlayer = '';
  String ballingPlayer = '';

  SharedPreferences? _prefs;
  List<String> stringList = [];
  Future<void> _loadList() async {
    _prefs = await SharedPreferences.getInstance();
    stringList = _prefs?.getStringList('stringList') ?? [];
    setState(() {});
  }

  void _showBattingDialog(List<String> selectedPlayers, bool isTeamA,
      String matchId, String id, String createTeamId) {
    String tempSelectedPlayer = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text("Select Batting Player"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedPlayers.length,
                    itemBuilder: (context, index) {
                      bool isCaptain =
                          selectedPlayers[index] == tempSelectedPlayer;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedPlayer =
                            selectedPlayers[index]; // Update local variable
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
                                      selectedPlayers.elementAt(index),
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
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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
                        Navigator.of(context).pop(); // Close the dialog
                        List<String> teamPlayers = isTeamA
                            ? sharedPreferenceHelper.teamB ?? []
                            : sharedPreferenceHelper.teamA ?? [];
                        String battingTeamCaptain = isTeamA
                            ? sharedPreferenceHelper.teamACaptain ?? ""
                            : sharedPreferenceHelper.teamBCaptain ?? "";
                        //_databaseHelper.InsertInningDetails('Team ${battingTeamCaptain}',  DateFormat('dd-MM-yyyy').format(DateTime.now()), createTeamId, id);
                        _showBallingDialog(
                            teamPlayers, isTeamA, matchId, createTeamId, id);
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
    });
  }

  void _showBallingDialog(List<String> selectedPlayers, bool isTeamA,
      String matchId, String createTeamId, String id) {
    String tempSelectedPlayer = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text("Select Bowling Player"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedPlayers.length,
                    itemBuilder: (context, index) {
                      bool isCaptain =
                          selectedPlayers[index] == tempSelectedPlayer;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedPlayer =
                            selectedPlayers[index]; // Update local variable
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
                                      selectedPlayers.elementAt(index),
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
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        ballingPlayer = tempSelectedPlayer; // Apply the change
                      });
                      // Rest of your logic when "OK" is pressed
                      if (ballingPlayer.isNotEmpty) {
                        sharedPreferenceHelper.saveBallingPlayer(ballingPlayer);
                        String ballingTeamCaptain = isTeamA
                            ? sharedPreferenceHelper.teamBCaptain ?? ""
                            : sharedPreferenceHelper.teamACaptain ?? "";
                        //_databaseHelper.InsertInningDetails('Team ${ballingTeamCaptain}',  DateFormat('dd-MM-yyyy').format(DateTime.now()), createTeamId, id);

                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchScore(
                                matchId: matchId,
                                createTeamId: createTeamId,
                                matchesId: id),
                          ),
                        );
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
    });
  }


  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _showPDfData();
  }


  void _initializeDatabase() async {
    await _loadList();
    await _databaseHelper.initDatabase();
    matches = await _databaseHelper
        .getMatchesByTodayDate(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    setState(() {});
    if (matches.isNotEmpty) {
      print("Matches for Today:");
      matches.forEach((match) {
        print(match);
      });
    } else {
      print("No matches found for today's date.");
    }
  }

  bool isMatchAllDone = true;
  List pdfSummary = [];
  void _showPDfData() async{
    await _databaseHelper.initDatabase();
    pdfSummary = await _databaseHelper.getPdfSummary( DateFormat('dd-MM-yyyy').format(DateTime.now()));
    if (pdfSummary.isNotEmpty) {
      print(pdfSummary);
    }
    else {
      print("No Data Found in pdf");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          matches.isEmpty
              ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AvailablePlayers(),
            ),
          )
              : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UpdateTeams(),
            ),
          );
        },
        backgroundColor: envoiceColorsExtensions.primary,
        label: matches.isEmpty
            ? Text(Constant.createTeam)
            : Text(Constant.updateTeam),
        icon: matches.isEmpty
            ? const Icon(Icons.add)
            : const Icon(Icons.update),
      ),
      body: Padding(
        padding: padding.all(Dimensions.medium),
        child: matches.isEmpty
            ? Column(
          children: [
            WicketLiveAssets.lottie.matchNotCreated.lottie(),
            Space(Dimensions.medium),
            Text(
              'Match Not Found',
              style: theme.textTheme.titleLarge,
            ),
          ],
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: matches.length,
                  itemBuilder: (BuildContext context, index) {
                    return Visibility(
                      visible: stringList[index] == "true" ? true : false,
                      child: Column(
                        children: [
                          InkWell(
                            onLongPress: (){
                              String matchesId = matches[index]["id"].toString();
                              String matchStatus = matches[index]["status"];
                              setState(() {

                              });
                              if(matchStatus == '2'){
                                _dialogBuilderRestartMatch(matchesId,matchStatus);
                              }

                            },
                            onDoubleTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => MatchCollectedFundScreen(
                                    matchesId: matches[index]["id"].toString(),
                                  ),
                                ),
                              );
                            },
                            child: SubmitButton(
                              onPressed: () async {
                                if (matches[index]['status'] == "0") {
                                  String winningTeam =
                                      sharedPreferenceHelper.winningTeam ?? '';
                                  String winningTeamBatBall =
                                      sharedPreferenceHelper.winningTeamBatBall ??
                                          '';
                                  print(winningTeam);
                                  print(winningTeamBatBall);

                                  sharedPreferenceHelper.saveInning1(false);
                                  sharedPreferenceHelper.saveInning2(false);
                                  sharedPreferenceHelper.saveBattingPlayer("");
                                  sharedPreferenceHelper.saveBallingPlayer("");
                                  List<Map<String, dynamic>> matchesDetails = [];
                                  final createdTeam =
                                  await _databaseHelper.getCreatedTeam();
                                  setState(() {
                                    matchesDetails = createdTeam;
                                  });
                                  print(
                                      "Team ${sharedPreferenceHelper.teamACaptain}");

                                  List<String> teamPlayers = [];
                                  bool isTeamA = false;
                                  if (winningTeam ==
                                      "Team ${sharedPreferenceHelper.teamACaptain}") {
                                    if (winningTeamBatBall == "Batting") {
                                      setState(() {
                                        teamPlayers =
                                            sharedPreferenceHelper.teamA ?? [];
                                        isTeamA = true;
                                      });
                                    } else {
                                      setState(() {
                                        teamPlayers =
                                            sharedPreferenceHelper.teamB ?? [];
                                        isTeamA = false;
                                      });
                                    }
                                  } else if (winningTeam ==
                                      "Team ${sharedPreferenceHelper.teamBCaptain}") {
                                    if (winningTeamBatBall == "Batting") {
                                      setState(() {
                                        teamPlayers =
                                            sharedPreferenceHelper.teamB ?? [];
                                        isTeamA = false;
                                      });
                                    } else {
                                      setState(() {
                                        teamPlayers =
                                            sharedPreferenceHelper.teamA ?? [];
                                        isTeamA = true;
                                      });
                                    }
                                  }

                                  setState(() {});
                                  _showBattingDialog(
                                      teamPlayers,
                                      isTeamA,
                                      matches[index]['title'],
                                      matches[index]["id"].toString(),
                                      matches[index]["createTeamId"]);
                                } else if (matches[index]['status'] == "1") {
                                  Fluttertoast.showToast(
                                    msg: "This match is locked",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchResultScreen(
                                        matchId: matches[index]["id"].toString(),
                                        title: matches[index]['title'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              isLoading: false,
                              childWidget: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(""),
                                    Text(
                                      matches[index]['title'],
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: envoiceColorsExtensions.background,
                                      ),
                                    ),
                                    matches[index]['status'] == "1"
                                        ? Icon(Icons.lock)
                                        : matches[index]['status'] == "2"
                                        ? Icon(Icons.check)
                                        : Icon(Icons.access_time_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Space(Dimensions.medium),
                        ],
                      ),
                    );
                  }),
              Visibility(
                visible: isMatchAllDone,
                child: InkWell(
                  child: SubmitButton(
                    onPressed: () async {
                      for(var count = 0; count < stringList.length ; count++){
                        if(stringList[count] == 'false'){
                          stringList[count] = 'true';
                          setState(() {});
                          break;
                        }
                      }
                      bool isCheck = false;
                      for(var count = 0; count < stringList.length ; count++){
                        if(stringList[count] == 'false'){
                          isCheck = false;
                          setState(() {});
                          break;
                        }
                        else{
                          isCheck = true;
                          setState(() {});
                        }
                      }
                      if(isCheck){
                        isMatchAllDone = false;
                        setState(() {});
                      }
                      else{
                        isMatchAllDone = true;
                        setState(() {});
                      }

                      await _saveList(stringList);
                    },
                    isLoading: false,
                    childWidget: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(""),
                          Text(
                            "Add Match",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: envoiceColorsExtensions.background,
                            ),
                          ),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _saveList(List<String> passBoolList) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('stringList', passBoolList);
  }

  Future<void> _dialogBuilderRestartMatch(String matchesId,String matchStatus) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Restart Match'),
                content: Text(
                    'Are Your sure you want to restart the match ?'
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
                      print(matchesId);
                      print(matchStatus);
                      if(matchStatus == "2"){
                        _databaseHelper.deleteMatchByMatchId(matchesId);
                        _databaseHelper.deleteMatchPDfByMatchId(matchesId);
                        _showPDfData();
                        await _databaseHelper.updateMatchStatus(matchesId, "0");
                        print('harshal');
                        print('id:'+ matchesId);
                        print('status:'+matchStatus);
                        _initializeDatabase();
                      }
                      print(matchesId);
                      print(matchStatus);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
  }
}