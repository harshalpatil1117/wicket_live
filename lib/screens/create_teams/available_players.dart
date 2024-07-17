import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/core.dart';
import 'package:wicket_live_apk/screens/dashboard/home/create_team_screen.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';

class AvailablePlayers extends StatefulWidget {
  const AvailablePlayers({super.key});

  @override
  State<AvailablePlayers> createState() => _AvailablePlayersState();
}

class _AvailablePlayersState extends State<AvailablePlayers> {
  final SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  List<bool> isSelected = List.generate(28, (index) => false);
  List<String> selectedPlayers = [];
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
                    // if (!playersList.contains(playerName.text.trim())) {
                    //   playersList.add(playerName.text.trim());
                    //
                    // } else {
                    //   Fluttertoast.showToast(
                    //     msg: "Player name is already in use",
                    //     toastLength: Toast.LENGTH_SHORT,
                    //     gravity: ToastGravity.TOP,
                    //     timeInSecForIosWeb: 1,
                    //     backgroundColor: Colors.red,
                    //     textColor: Colors.white,
                    //     fontSize: 16.0,
                    //   );
                    // }
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    bool allSelected = selectedPlayers.length == playersList.length;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? isPlayerAdded = await _showPlayerAddDialog();
          if (isPlayerAdded == true) {
            setState(() {
              sharedPreferenceHelper.savePlayers(playersList);
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
          "Available Players",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
        actions: [
          IconButton(
            icon: allSelected
                ? Icon(
                    Icons.check_box,
                    color: theme.envoiceColorsExtensions.background,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    color: theme.envoiceColorsExtensions.background,
                  ),
            onPressed: () {
              setState(() {
                if (selectedPlayers.length == playersList.length) {
                  isSelected = List.generate(28, (index) => false);
                  selectedPlayers.clear();
                } else {
                  isSelected = List.generate(28, (index) => true);
                  selectedPlayers = List.from(playersList);
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: padding.symmetric(vertical: Dimensions.small),
        itemCount: playersList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected[index] = !isSelected[index];
                if (isSelected[index]) {
                  selectedPlayers.add(playersList[index]);
                } else {
                  selectedPlayers.remove(playersList[index]);
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
                    if (selectedPlayers.length >= 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTeamScreen(
                              availablePlayersList: selectedPlayers),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select atleast 2 players",
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