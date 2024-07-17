import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/core.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/create_teams/team_b_selection.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';
import 'package:intl/intl.dart';

class TeamASelection extends StatefulWidget {
  const TeamASelection({
    super.key,
    required this.availablePlayersList,
  });

  final List<String> availablePlayersList;

  @override
  State<TeamASelection> createState() => _TeamASelectionState();
}

class _TeamASelectionState extends State<TeamASelection> {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  List<bool> isSelected = List.generate(28, (index) => false);
  List<String> selectedPlayers = [];
  int maxPlayersSelection = 0;
  double bottomAppBarHeight = 120.0;
  List<String> alreadySelectedPlayers = [];

  final DB _databaseHelper = DB();

  String selectedCaptain = "";

  void _showCaptainDialog() {
    String tempSelectedCaptain = selectedCaptain; // Use a local variable

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text("Choose Team A Captain"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedPlayers.length,
                    itemBuilder: (context, index) {
                      bool isCaptain = selectedPlayers[index] == tempSelectedCaptain;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedCaptain = selectedPlayers[index]; // Update local variable
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
                                    ? Text(
                                  'C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
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
                        selectedCaptain = tempSelectedCaptain; // Apply the change
                      });
                      Navigator.of(context).pop(); // Close the dialog

                      // Rest of your logic when "OK" is pressed
                      if (selectedCaptain.isNotEmpty) {
                        sharedPreferenceHelper.saveTeamACaptain(selectedCaptain);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TeamBSelection(
                              availablePlayersList: widget.availablePlayersList,
                            ),
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please select a captain",
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

    alreadySelectedPlayers = sharedPreferenceHelper.teamA ?? [];
    if (alreadySelectedPlayers.isNotEmpty) {
      selectedPlayers = List<String>.from(alreadySelectedPlayers);
      isSelected = List.generate(
        widget.availablePlayersList.length,
        (index) => selectedPlayers.contains(
          widget.availablePlayersList[index],
        ),
      );
      maxPlayersSelection = selectedPlayers.length;
    } else {
      maxPlayersSelection = widget.availablePlayersList.length ~/ 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Select Team A",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.envoiceColorsExtensions.background,
            ),
          ),
        ),
        body: ListView.builder(
          padding: padding.symmetric(vertical: Dimensions.small),
          itemCount: widget.availablePlayersList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected[index]) {
                    isSelected[index] = false;
                    selectedPlayers.remove(widget.availablePlayersList[index]);
                  } else {
                    if (selectedPlayers.length >= maxPlayersSelection) {
                      Fluttertoast.showToast(
                        msg: "Maximum $maxPlayersSelection players allowed",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      isSelected[index] = true;
                      selectedPlayers.add(widget.availablePlayersList[index]);
                    }
                  }
                });
              },
              child: Padding(
                padding: padding.symmetric(
                  vertical: Dimensions.smallest,
                  horizontal: Dimensions.smaller,
                ),
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
                              widget.availablePlayersList.elementAt(index),
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
                            : Container(), // Empty container if not selected
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
                    onPressed: () {
                      if (selectedPlayers.length == maxPlayersSelection) {
                        sharedPreferenceHelper.saveTeamA(selectedPlayers);
                        _showCaptainDialog();
                        // List<String> unselectedPlayers =
                        // List<String>.from(widget.availablePlayersList)
                        //     .where(
                        //       (player) => !selectedPlayers.contains(player),
                        // )
                        //     .toList();
                        // Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (context) => TeamBSelection(
                        //       availablePlayersList: widget.availablePlayersList,
                        //     ),
                        //   ),
                        // );
                      } else {
                        Fluttertoast.showToast(
                          msg:
                              "Please select at least $maxPlayersSelection players",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    child: Text("NEXT"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
