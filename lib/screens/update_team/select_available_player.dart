import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/core.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/update_team/update_team.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';
import 'package:intl/intl.dart';

class SelectPlayers extends StatefulWidget {
  const SelectPlayers({
    super.key,
    required this.teamName,
  });

  final String teamName;

  @override
  State<SelectPlayers> createState() => _SelectPlayersState();
}

class _SelectPlayersState extends State<SelectPlayers> {
  final DB _databaseHelper = DB();
  final SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  List<String> selectedPlayers = [];
  List<bool> isSelected = [];
  List<String> teamPlayersA = [];
  List<String> teamPlayersB = [];
  List<String> playersList = [];
  double bottomAppBarHeight = 120.0;
  final _formKey = GlobalKey<FormState>();

  Future<bool?> _showPlayerAddDialog() {
    TextEditingController playerName = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New Player"),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      RegularTextFormField(
                        controller: playerName,
                        label: "Player Name",
                        hintText: "Enter player name",
                        validation: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          String formattedName =
                          value.toLowerCase().capitalizeFirstLetter();
                          if (playersList.contains(formattedName.trim())) {
                            return 'This name is already in the list';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        String formattedName =
                        playerName.text.toLowerCase().capitalizeFirstLetter();
                        playersList.add(formattedName.trim());
                        playerName.clear();
                      });
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playersList = sharedPreferenceHelper.players ?? [];
    teamPlayersA = sharedPreferenceHelper.teamA ?? [];
    teamPlayersB = sharedPreferenceHelper.teamB ?? [];

    // Remove teamPlayers from playersList
    playersList.removeWhere((player) => teamPlayersA.contains(player));
    playersList.removeWhere((player) => teamPlayersB.contains(player));
    isSelected = List.generate(playersList.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? isPlayerAdded = await _showPlayerAddDialog();
          if (isPlayerAdded == true) {
            setState(() {
              sharedPreferenceHelper.savePlayers(playersList);

              playersList = sharedPreferenceHelper.players ?? [];

              // Remove teamPlayers from playersList
              playersList.removeWhere((player) => teamPlayersA.contains(player));
              playersList.removeWhere((player) => teamPlayersB.contains(player));
              isSelected = List.generate(playersList.length, (index) => false);
            });
          }
        },
        backgroundColor: envoiceColorsExtensions.primary,
        label: Text("Add Players"),
        icon: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Select Player",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
      ),
      body: ListView.builder(
        padding: padding.symmetric(
          vertical: Dimensions.smaller,
          horizontal: Dimensions.small,
        ),
        itemCount: playersList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: padding.symmetric(vertical: Dimensions.smallest),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSelected[index] = !isSelected[index];
                  if (isSelected[index]) {
                   widget.teamName == sharedPreferenceHelper.teamACaptain
                        ? teamPlayersA.add(playersList[index]) :
                   teamPlayersB.add(playersList[index]);
                    selectedPlayers.add(playersList[index]);
                  } else {
                    widget.teamName == sharedPreferenceHelper.teamACaptain
                        ? teamPlayersA.remove(playersList[index]) :
                    teamPlayersB.remove(playersList[index]);
                    selectedPlayers.remove(playersList[index]);
                  }
                });
              },
              child: Card(
                elevation: 10,
                color: isSelected[index] ? Colors.lightGreen : null,
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
                            playersList.elementAt(index),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      isSelected[index]
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 35,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: selectedPlayers.length > 0
            ? selectedPlayers.length > 15
                ? 150
                : bottomAppBarHeight
            : 100,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Padding(
            padding: padding.symmetric(
              horizontal: Dimensions.smaller,
              vertical: Dimensions.smallest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: selectedPlayers.length > 0
                      ? Text(
                          "${selectedPlayers.join(' , ')}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                Space(Dimensions.large),
                ElevatedButton(
                  onPressed: () async {
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

                    String team1Players = teamPlayersA.join(",");
                    String team2Players = teamPlayersB.join(",");

                    if (selectedPlayers.length >= 1) {
                      sharedPreferenceHelper.saveTeamA(teamPlayersA);
                      sharedPreferenceHelper.saveTeamB(teamPlayersB);
                      _databaseHelper.createTeamUpdate(
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
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              UpdateTeams(),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select atleast 1 players",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: Text("Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + this.substring(1);
  }
}