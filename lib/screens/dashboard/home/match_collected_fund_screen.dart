import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dismissible_tile/flutter_dismissible_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network/core/shared_preferences/helper.dart';
import 'package:network/core/shared_preferences/preferences.dart';
import 'package:network/database/db/db.dart';
import '../../../utils/constants.dart';
import 'package:intl/intl.dart';

class MatchCollectedFundScreen extends StatefulWidget {
  const MatchCollectedFundScreen({super.key, required this.matchesId});

  final String matchesId;

  @override
  State<MatchCollectedFundScreen> createState() =>
      _MatchCollectedFundScreenState();
}

class _MatchCollectedFundScreenState extends State<MatchCollectedFundScreen> {
  final SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DB _databaseHelper = DB();

  String selectedPlayers = Constant.selectedPlayers;
  List<String> playersList = [];

  // String createId = '';
  int? lastRecordId;
  List matchCollectedFund = [];

  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    lastRecordId = await _databaseHelper.getLastCreateTeamId();
    matchCollectedFund =
        await _databaseHelper.getMatchFundByMatchId(widget.matchesId);
    setState(() {});
    if (matchCollectedFund.isNotEmpty) {
      print("fund collected Today:");
      matchCollectedFund.forEach((match) {
        print(match);
      });
      print(matchCollectedFund);
    } else {
      print("No fund found for today's match.");
    }
    // print(matchCollectedFund);
  }

  @override
  void initState() {
    super.initState();
    playersList = sharedPreferenceHelper.players ?? [];
    _initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> playerCounts = {};
    matchCollectedFund.forEach((match) {
      String playerName = match['playerName'];
      playerCounts[playerName] = (playerCounts[playerName] ?? 0) + 1;
    });
    List<MapEntry<String, int>> sortedPlayers = playerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return RefreshIndicator(
      onRefresh: () async {
        _initializeDatabase();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Constant.matchCollectedFund,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: envoiceColorsExtensions.background,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Padding(
          padding: padding.all(Dimensions.medium),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BaseDropDownFormField(
                          label: Constant.selectedPlayers,
                          value: selectedPlayers,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPlayers = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == Constant.selectedPlayers ||
                                value == null ||
                                value.isEmpty) {
                              return "Please select a player";
                            }
                            return null;
                          },
                          options: playersList),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: envoiceColorsExtensions.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: MediaQuery.sizeOf(context).width / 10,
                        height: MediaQuery.sizeOf(context).height / 15,
                        child: GestureDetector(
                          onTap: () async {
                            if (selectedPlayers == Constant.selectedPlayers) {
                              Fluttertoast.showToast(
                                  msg: "Please select a player",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              await _databaseHelper.initDatabase();
                              await _databaseHelper.MatchCollectedFund(
                                  selectedPlayers,
                                  '1',
                                  '10',
                                  DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                  lastRecordId.toString(),
                                  widget.matchesId);
                              print('data submited');
                            }
                            _initializeDatabase();
                          },
                          child: Icon(
                            Icons.check,
                            color: envoiceColorsExtensions.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Space(Dimensions.medium),
                Divider(thickness: 3, color: envoiceColorsExtensions.primary),
                Space(Dimensions.medium),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: sortedPlayers.length,
                      itemBuilder: (BuildContext context, index) {
                        String playerName = sortedPlayers[index].key;
                        int count = sortedPlayers[index].value;
                        print(playerName);
                        print(count);
                        return DismissibleTile(
                          key: UniqueKey(),
                          direction: DismissibleTileDirection.rightToLeft,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          rtlDismissedColor: theme.envoiceColorsExtensions.error,
                          rtlOverlay: const Icon(CupertinoIcons.delete),
                          rtlOverlayDismissed: const Text('Deleted'),
                          onDismissConfirmed: () async{
                            await _databaseHelper.deleteSinglePlayerMatchCollectedFund(playerName);
                            _initializeDatabase();
                          },
                          child: Container(
                            margin: padding.all(Dimensions.smallest),
                            color: envoiceColorsExtensions.primary,
                            height: MediaQuery.of(context).size.height / 17,
                            child: Padding(
                              padding: padding.all(Dimensions.smaller),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$playerName (${count.toString()})",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: envoiceColorsExtensions.background,
                                    ),
                                  ),
                                  Text(
                                    "\u{20B9}${count >= 1 ? (count * int.parse(matchCollectedFund[index]['amount'])) : null}",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: envoiceColorsExtensions.background,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
