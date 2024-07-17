import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/shared_preferences/helper.dart';
import 'package:network/core/shared_preferences/preferences.dart';
import 'package:wicket_live_apk/screens/create_teams/team_a_selection.dart';
import 'package:wicket_live_apk/screens/dashboard/coinToss/coin_toss_screen.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';

class TeamBSelection extends StatefulWidget {
  const TeamBSelection({
    super.key,
    required this.availablePlayersList,
  });

  final List<String> availablePlayersList;

  @override
  State<TeamBSelection> createState() => _TeamBSelectionState();
}

class _TeamBSelectionState extends State<TeamBSelection> {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  List<bool> isSelected = List.generate(28, (index) => false);
  List<String> selectedPlayers = [];
  int maxPlayersSelection = 0;
  double bottomAppBarHeight = 120.0;

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
                title: Text("Choose Team B Captain"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedPlayers.length,
                    itemBuilder: (context, index) {
                      bool isCaptain =
                          selectedPlayers[index] == tempSelectedCaptain;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedCaptain = selectedPlayers[
                                index]; // Update local variable
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    WicketLiveAssets.images.cricketPlayer
                                        .image(
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
                        selectedCaptain =
                            tempSelectedCaptain; // Apply the change
                      });
                      Navigator.of(context).pop(); // Close the dialog

                      // Rest of your logic when "OK" is pressed
                      if (selectedCaptain.isNotEmpty) {
                        sharedPreferenceHelper
                            .saveTeamBCaptain(selectedCaptain);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => CoinTossPage(),
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

    // Fetch team A players from shared preferences
    List<String> teamAPlayers =
        SharedPreferenceHelper(Preference()).teamA ?? [];

    // Remove team A players from availablePlayersList
    List<String> remainingPlayers =
        List<String>.from(widget.availablePlayersList);
    remainingPlayers.removeWhere((player) => teamAPlayers.contains(player));

    // Initialize selectedPlayers with remainingPlayers by default
    selectedPlayers = List<String>.from(remainingPlayers);

    // Initialize isSelected with true for all players
    isSelected = List.generate(
      widget.availablePlayersList.length,
      (index) => true,
    );

    maxPlayersSelection = selectedPlayers.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Select Team B",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
      ),
      body: ListView.builder(
        padding: padding.symmetric(vertical: Dimensions.small),
        itemCount: selectedPlayers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
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
                            selectedPlayers.elementAt(index),
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
                    sharedPreferenceHelper.saveTeamB(selectedPlayers);
                    _showCaptainDialog();
                  },
                  child: Text("NEXT"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
