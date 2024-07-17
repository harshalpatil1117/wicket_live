import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dismissible_tile/flutter_dismissible_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/core.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/update_team/select_available_player.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';

class UpdateTeams extends StatefulWidget {
  const UpdateTeams({super.key});

  @override
  State<UpdateTeams> createState() => _UpdateTeamsState();
}

class _UpdateTeamsState extends State<UpdateTeams> {
  final SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  List<String> teamAPlayers = [];
  List<String> teamBPlayers = [];
  String teamACaptain = '';
  String teamBCaptain = '';
  List<bool> isSelectedTeamA = [];
  List<bool> isSelectedTeamB = [];
  final DB _databaseHelper = DB();

  Future<bool?> _dialogDeletionTeamA(BuildContext context, int index) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text(
              "Are you sure want to delete player ?",
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
                  teamAPlayers.remove(teamAPlayers.elementAt(index));
                  final createdTeam = await _databaseHelper.getCreatedTeam();
                  String team1Captain = createdTeam[0]["team1Captain"];
                  String team2Captain = createdTeam[0]["team2Captain"];
                  String team1Bb = createdTeam[0]["team1Bb"];
                  String team2Bb = createdTeam[0]["team2Bb"];

                  String numberOfMatch = createdTeam[0]["numberOfMatch"];
                  String numberOfOver = createdTeam[0]["numberOfOver"];
                  String team1Checked = createdTeam[0]["team1Checked"];
                  String team2Checked = createdTeam[0]["team2Checked"];
                  String todayDate = createdTeam[0]["todayDate"];

                  String team1Players = teamAPlayers.join(",");
                  String team2Players = teamBPlayers.join(",");
                  sharedPreferenceHelper.saveTeamA(teamAPlayers);
                  await _databaseHelper.createTeamUpdate(
                      team1Captain,
                      team2Captain,
                      team1Bb,
                      team2Bb,
                      team1Players,
                      team2Players,
                      numberOfMatch,
                      numberOfOver,
                      team1Checked,
                      team2Checked,
                      todayDate);
                  Fluttertoast.showToast(msg: "Player deleted successfull");
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<bool?> _dialogDeletionTeamB(BuildContext context, int index) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text(
              "Are you sure want to delete player ?",
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
                  teamBPlayers.remove(teamBPlayers.elementAt(index));
                  final createdTeam = await _databaseHelper.getCreatedTeam();
                  String team1Captain = createdTeam[0]["team1Captain"];
                  String team2Captain = createdTeam[0]["team2Captain"];
                  String team1Bb = createdTeam[0]["team1Bb"];
                  String team2Bb = createdTeam[0]["team2Bb"];

                  String numberOfMatch = createdTeam[0]["numberOfMatch"];
                  String numberOfOver = createdTeam[0]["numberOfOver"];
                  String team1Checked = createdTeam[0]["team1Checked"];
                  String team2Checked = createdTeam[0]["team2Checked"];
                  String todayDate = createdTeam[0]["todayDate"];

                  String team1Players = teamAPlayers.join(",");
                  String team2Players = teamBPlayers.join(",");

                  sharedPreferenceHelper.saveTeamB(teamBPlayers);
                  await _databaseHelper.createTeamUpdate(
                      team1Captain,
                      team2Captain,
                      team1Bb,
                      team2Bb,
                      team1Players,
                      team2Players,
                      numberOfMatch,
                      numberOfOver,
                      team1Checked,
                      team2Checked,
                      todayDate);
                  Fluttertoast.showToast(msg: "Player deleted successfull");
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    teamAPlayers = sharedPreferenceHelper.teamA ?? [];
    teamBPlayers = sharedPreferenceHelper.teamB ?? [];
    teamACaptain = sharedPreferenceHelper.teamACaptain ?? "";
    teamBCaptain = sharedPreferenceHelper.teamBCaptain ?? "";
    isSelectedTeamA = List.generate(teamAPlayers.length, (index) => true);
    isSelectedTeamB = List.generate(teamBPlayers.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Update Teams",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.envoiceColorsExtensions.background,
            ),
          ),
          bottom: TabBar(
            dividerColor: theme.envoiceColorsExtensions.background,
            unselectedLabelColor: theme.envoiceColorsExtensions.background,
            labelColor: theme.envoiceColorsExtensions.background,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: "Team $teamACaptain"),
              Tab(text: "Team $teamBCaptain"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Team A Tab
            Stack(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  padding: padding.symmetric(vertical: Dimensions.small),
                  itemCount: teamAPlayers.length,
                  itemBuilder: (context, index) {
                    return DismissibleTile(
                      key: UniqueKey(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      delayBeforeResize: const Duration(milliseconds: 500),
                      rtlDismissedColor: theme.envoiceColorsExtensions.error,
                      rtlOverlay: const Text('Delete'),
                      rtlOverlayDismissed: const Text('Deleted'),
                      onDismissConfirmed: () async {
                        print("Deleted Successfully");
                        if (teamAPlayers[index] != teamACaptain) {
                          setState(() {});
                          bool? isPlayerDeleted =
                              await _dialogDeletionTeamA(context, index);
                          if (isPlayerDeleted == true) {
                            setState(() {});
                          }
                        } else {
                          setState(() {});
                          Fluttertoast.showToast(
                              msg: "Captain can not be deleted");
                        }
                      },
                      child: Padding(
                        padding: padding.symmetric(
                          horizontal: Dimensions.smaller,
                        ),
                        child: Card(
                          elevation: 10,
                          color: Colors.lightGreen,
                          child: Padding(
                            padding: padding.symmetric(
                              vertical: Dimensions.smaller,
                              horizontal: Dimensions.smaller,
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
                                      teamAPlayers.elementAt(index),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                // Empty container if not selected
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              SelectPlayers(teamName: teamACaptain),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),

            // Team B Tab
            Stack(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  padding: padding.symmetric(vertical: Dimensions.small),
                  itemCount: teamBPlayers.length,
                  itemBuilder: (context, index) {
                    return DismissibleTile(
                      key: UniqueKey(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      delayBeforeResize: const Duration(milliseconds: 500),
                      rtlDismissedColor: theme.envoiceColorsExtensions.error,
                      rtlOverlay: const Text('Delete'),
                      rtlOverlayDismissed: const Text('Deleted'),
                      onDismissConfirmed: () async {
                        print("Deleted Successfully");

                        if (teamBPlayers[index] != teamBCaptain) {
                          setState(() {});
                          bool? isPlayerDeleted =
                              await _dialogDeletionTeamB(context, index);
                          if (isPlayerDeleted == true) {
                            setState(() {});
                          }
                        } else {
                          setState(() {});
                          Fluttertoast.showToast(
                              msg: "Captain can not be deleted");
                        }
                      },
                      child: Padding(
                        padding: padding.symmetric(
                          horizontal: Dimensions.smaller,
                        ),
                        child: Card(
                          elevation: 10,
                          color: Colors.lightGreen,
                          child: Padding(
                            padding: padding.symmetric(
                              vertical: Dimensions.smaller,
                              horizontal: Dimensions.smaller,
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
                                      teamBPlayers.elementAt(index),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                // Empty container if not selected
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              SelectPlayers(teamName: teamBCaptain),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
