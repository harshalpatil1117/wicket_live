import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:network/database/db/db.dart';
import 'package:wicket_live_apk/screens/dashboard/home/match_collected_fund_screen.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:intl/intl.dart';

class MatchDetailsAddScreen extends StatefulWidget {
  const MatchDetailsAddScreen({Key? key, required this.matchesId}) : super(key: key);
final String matchesId;
  
  @override
  MatchDetailsAddScreenState createState() => MatchDetailsAddScreenState();
}

class MatchDetailsAddScreenState extends State<MatchDetailsAddScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Constant.match1,
            style: theme.textTheme.headlineMedium?.copyWith(
                color: envoiceColorsExtensions.background,
                fontStyle: FontStyle.italic),
          ),
          bottom: TabBar(
            labelStyle: theme.textTheme.titleMedium
                ?.copyWith(color: envoiceColorsExtensions.background),
            tabs: [
              Tab(
                text: Constant.team1,
              ),
              Tab(text: Constant.team2),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Team1Details(),
            Team2Details(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  MatchCollectedFundScreen(matchesId: widget.matchesId,)));
          },
          child: const Icon(Icons.money),
        ),
      ),
    );
  }
}

class Team1Details extends StatefulWidget {
  const Team1Details({super.key});

  @override
  State<Team1Details> createState() => _Team1DetailsState();
}

class _Team1DetailsState extends State<Team1Details> {
  String selectedTeam1Over = 'Select Over';
  List<String> team1Over = ['1', '2', '3', '4', '5', '6'];

  String selectedTeam1BattingPlayers = 'Select Batting Player';
  List<String> team1BattingPlayers = [];

  String selectedTeam1BowlingPlayers = 'Select Bowling Player';
  List<String> team1BowlingPlayers = [];

  List<bool> isClick = [false, false, false, false, false, false, false, false];

  String? selectedRunType;
  List<String> runType = ['NB', 'W', 'WB', '0', '1', '2', '4', '6'];

  String selectedWicketType = 'Select Wicket Type';
  List<String> wicketType = [
    'Catch Out',
    'Stamping',
    'Hit Wicket',
    'Out Of Ground'
  ];

  final DB _databaseHelper = DB();
  List<Map<String, dynamic>> matches = [];
  String selectedRole = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }
  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    matches = await _databaseHelper.getCreatedTeam();
    setState(() {});
    if (matches.isNotEmpty) {
      print("Matches for Today:");
      matches.forEach((match) {
        print(match);
      });
      print(matches);
    } else {
      print("No matches found for today's date.");
    }
    for( var count = 0;count<matches.length;count++){
      selectedRole = matches[count]['team1Bb'];
      String playersString = matches[count]['team1Players'];
      team1BattingPlayers = playersString.split(',');
      String players2String = matches[count]['team2Players'];
      team1BowlingPlayers = players2String.split(',');
      print(selectedRole);
      print(team1BattingPlayers);
      print(team1BowlingPlayers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Padding(
      padding: padding.all(Dimensions.medium),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      width: MediaQuery.of(context).size.width,
                      color: envoiceColorsExtensions.primary,
                      child: Padding(
                        padding: padding.symmetric(horizontal: Dimensions.smallest),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Over - ${index + 1}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background)),
                            Row(
                              children: [
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(horizontal: Dimensions.smallest),
                                  child: Text(
                                    "00",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Space(Dimensions.small),
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(horizontal: Dimensions.smallest),
                                  child: Text("10",
                                      style: theme.textTheme.titleMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kBlue,
                          width: 2.0,
                        ),
                      ),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 6,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) {
                          return SizedBox(
                            height: 10,
                            child: Row(
                              children: [
                              Space(Dimensions.smaller),
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                    color: kBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('0',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Space(Dimensions.smaller),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: envoiceColorsExtensions.primary,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text("Total Run : ".toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: envoiceColorsExtensions.background),),
                    ),
                    Row(
                      children: [
                        Container(
                          color: Colors.red,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                                child: Text("45",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: envoiceColorsExtensions
                                                .background),),),
                          ),
                        ),
                        Space(Dimensions.medium),
                        Container(
                          color: Colors.green,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                                child: Text("46",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: envoiceColorsExtensions
                                                .background))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BaseDropDownFormField(
              label: '',
              value: selectedTeam1Over!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam1Over = newValue!;
                });
              },
              validator: (v) {},
              options: team1Over,
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey), // Border color
            //     borderRadius: BorderRadius.circular(5.0), // Border radius
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(7.0),
            //     child: DropdownButton<String>(
            //       value: selectedTeam1Over,
            //       onChanged: (String? newValue) {
            //         setState(() {
            //           selectedTeam1Over = newValue;
            //         });
            //       },
            //       items: team1Over.map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem<String>(
            //           value: value,
            //           child: Text(value),
            //         );
            //       }).toList(),
            //       isDense: true,
            //       hint: const Text('Select Over'),
            //       underline: Container(),
            //       style: const TextStyle(color: Colors.black),
            //       icon: const Icon(Icons.arrow_drop_down),
            //       isExpanded: true,
            //       dropdownColor: Colors.white,
            //     ),
            //   ),
            // ),
            // Space(Dimensions.smaller),
            BaseDropDownFormField(
              label: '',
              value: selectedTeam1BattingPlayers!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam1BattingPlayers = newValue!;
                });
              },
              validator: (v) {},
              options: selectedRole == 'batting' ? team1BattingPlayers : team1BowlingPlayers,
            ),
            BaseDropDownFormField(
              label: '',
              value: selectedTeam1BowlingPlayers!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam1BowlingPlayers = newValue!;
                });
              },
              validator: (v) {},
              options: selectedRole != 'batting' ? team1BattingPlayers : team1BowlingPlayers,
            ),
            Space(Dimensions.medium),
            Center(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: runType.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, index) {
                      return SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                for (var count = 0;
                                    count < isClick.length;
                                    count++) {
                                  setState(() {
                                    isClick[count] = false;
                                    if (count == isClick.length - 1) {
                                      isClick[index] = true;
                                      selectedRunType = runType[index];
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: index == 0 || index == 1
                                      ? Colors.red
                                      : index == 2 || index == 3
                                          ? Colors.orange
                                          : Colors.green,
                                  shape: BoxShape.circle,
                                  border: isClick[index] == true
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2.0,
                                        )
                                      : Border.all(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                ),
                                child: Center(
                                  child: index == 0
                                      ? Text(runType[index],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))
                                      : index == 1
                                          ? Text(runType[index],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold))
                                          : index == 2
                                              ? Text(runType[index],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : index == 3
                                                  ? Text(runType[index],
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold))
                                                  : index == 4
                                                      ? Text(runType[index],
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                      : index == 5
                                                          ? Text(
                                                              runType[index],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                          : index == 6
                                                              ? Text(runType[index],
                                                                  style: const TextStyle(
                                                                      color:
                                                                          Colors.white,
                                                                      fontWeight: FontWeight.bold))
                                                              : Text(runType[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            selectedRunType == "W"
                ?
            BaseDropDownFormField(
              label: '',
              value: selectedWicketType!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedWicketType = newValue!;
                });
              },
              validator: (v) {},
              options: wicketType,
            )
            // Padding(
            //         padding: const EdgeInsets.all(10),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey), // Border color
            //             borderRadius:
            //                 BorderRadius.circular(5.0), // Border radius
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(7.0),
            //             child: DropdownButton<String>(
            //               value: selectedWicketType,
            //               onChanged: (String? newValue) {
            //                 setState(() {
            //                   selectedWicketType = newValue;
            //                 });
            //               },
            //               items: wicketType
            //                   .map<DropdownMenuItem<String>>((String value) {
            //                 return DropdownMenuItem<String>(
            //                   value: value,
            //                   child: Text(value),
            //                 );
            //               }).toList(),
            //               isDense: true,
            //               hint: const Text('Select Wicket Type'),
            //               underline: Container(),
            //               style: const TextStyle(color: Colors.black),
            //               icon: const Icon(Icons.arrow_drop_down),
            //               isExpanded: true,
            //               dropdownColor: Colors.white,
            //             ),
            //           ),
            //         ),
            //       )
                : const SizedBox.shrink(),
            selectedRunType != "W"
                ? const SizedBox(height: 10)
                : const SizedBox.shrink(),
            SubmitButton(
              onPressed: () {},
              isLoading: false,
              childWidget: Text(
                Constant.submitRecord,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: 45,
            //     decoration: BoxDecoration(
            //       color: kBlue,
            //       borderRadius: BorderRadius.circular(10), // Adjust the value as needed
            //     ),
            //     child: Center(
            //       child: Text('Submit Record'.toUpperCase(), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1)),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class Team2Details extends StatefulWidget {
  const Team2Details({super.key});

  @override
  State<Team2Details> createState() => _Team2DetailsState();
}

class _Team2DetailsState extends State<Team2Details> {
  String selectedTeam2Over = 'Select Over';
  List<String> team2Over = ['1', '2', '3', '4', '5', '6'];

  String selectedTeam2BattingPlayers = 'Select Batting Player';
  List<String> team2BattingPlayers = [];

  String selectedTeam2BowlingPlayers = 'Select Bowling Player';
  List<String> team2BowlingPlayers = [];

  List<bool> isClick = [false, false, false, false, false, false, false, false];

  String? selectedRunType;
  List<String> runType = ['NB', 'W', 'WB', '0', '1', '2', '4', '6'];

  String selectedWicketType = 'Select Wicket Type';
  List<String> wicketType = [
    'Catch Out',
    'Stamping',
    'Hit Wicket',
    'Out Of Ground'
  ];

  final DB _databaseHelper = DB();
  List<Map<String, dynamic>> matches = [];
  String selectedRole = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }
  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    matches = await _databaseHelper.getCreatedTeam();
    setState(() {});
    if (matches.isNotEmpty) {
      print("Matches for Today:");
      matches.forEach((match) {
        print(match);
      });
      print(matches);
    } else {
      print("No matches found for today's date.");
    }
    for( var count = 0;count<matches.length;count++){
      selectedRole = matches[count]['team1Bb'];
      String playersString = matches[count]['team2Players'];
      team2BattingPlayers = playersString.split(',');
      String players2String = matches[count]['team1Players'];
      team2BowlingPlayers = players2String.split(',');
      print(selectedRole);
      print(team2BattingPlayers);
      print(team2BowlingPlayers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Padding(
      padding: padding.all(Dimensions.medium),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      width: MediaQuery.of(context).size.width,
                      color: envoiceColorsExtensions.primary,
                      child: Padding(
                        padding: padding.symmetric(horizontal: Dimensions.smallest),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Over - ${index + 1}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background),),
                            Row(
                              children: [
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(horizontal: Dimensions.smallest),
                                  child: Text(
                                    "00",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Space(Dimensions.small),
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(horizontal: Dimensions.smallest),
                                  child: Text("10",
                                      style: theme.textTheme.titleMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kBlue,
                          width: 2.0,
                        ),
                      ),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 6,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) {
                          return SizedBox(
                            height: 10,
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                    color: kBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('0',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Space(Dimensions.smaller),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: envoiceColorsExtensions.primary,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text("Total Run : ".toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: envoiceColorsExtensions.background),),
                    ),
                    Row(
                      children: [
                        Container(
                          color: Colors.red,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                                child: Text("45",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: envoiceColorsExtensions
                                                .background))),
                          ),
                        ),
                        Space(Dimensions.medium),
                        Container(
                          color: Colors.green,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                                child: Text("46",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: envoiceColorsExtensions
                                                .background))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BaseDropDownFormField(
              label: '',
              value: selectedTeam2Over!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam2Over = newValue!;
                });
              },
              validator: (v) {},
              options: team2Over,
            ),

            BaseDropDownFormField(
              label: '',
              value: selectedTeam2BattingPlayers!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam2BattingPlayers = newValue!;
                });
              },
              validator: (v) {},
              options: selectedRole == 'batting' ? team2BattingPlayers : team2BowlingPlayers,
            ),
            BaseDropDownFormField(
              label: '',
              value: selectedTeam2BowlingPlayers!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam2BowlingPlayers = newValue!;
                });
              },
              validator: (v) {},
              options: selectedRole != 'batting' ? team2BattingPlayers : team2BowlingPlayers,
            ),
            Space(Dimensions.medium),
            Center(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: runType.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, index) {
                      return SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                for (var count = 0;
                                    count < isClick.length;
                                    count++) {
                                  setState(() {
                                    isClick[count] = false;
                                    if (count == isClick.length - 1) {
                                      isClick[index] = true;
                                      selectedRunType = runType[index];
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: index == 0 || index == 1
                                      ? Colors.red
                                      : index == 2 || index == 3
                                          ? Colors.orange
                                          : Colors.green,
                                  shape: BoxShape.circle,
                                  border: isClick[index] == true
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2.0,
                                        )
                                      : Border.all(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                ),
                                child: Center(
                                  child: index == 0
                                      ? Text(runType[index],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))
                                      : index == 1
                                          ? Text(runType[index],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold))
                                          : index == 2
                                              ? Text(runType[index],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : index == 3
                                                  ? Text(runType[index],
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold))
                                                  : index == 4
                                                      ? Text(runType[index],
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                      : index == 5
                                                          ? Text(
                                                              runType[index],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                          : index == 6
                                                              ? Text(runType[index],
                                                                  style: const TextStyle(
                                                                      color:
                                                                          Colors.white,
                                                                      fontWeight: FontWeight.bold))
                                                              : Text(runType[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            selectedRunType == "W"
                ?
            BaseDropDownFormField(
              label: '',
              value: selectedWicketType!,
              onChanged: (String? newValue) {
                setState(() {
                  selectedWicketType = newValue!;
                });
              },
              validator: (v) {},
              options: wicketType,
            )
            // Padding(
                //     padding: const EdgeInsets.all(10),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: Colors.grey), // Border color
                //         borderRadius:
                //             BorderRadius.circular(5.0), // Border radius
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(7.0),
                //         child: DropdownButton<String>(
                //           value: selectedWicketType,
                //           onChanged: (String? newValue) {
                //             setState(() {
                //               selectedWicketType = newValue;
                //             });
                //           },
                //           items: wicketType
                //               .map<DropdownMenuItem<String>>((String value) {
                //             return DropdownMenuItem<String>(
                //               value: value,
                //               child: Text(value),
                //             );
                //           }).toList(),
                //           isDense: true,
                //           hint: const Text('Select Wicket Type'),
                //           underline: Container(),
                //           style: const TextStyle(color: Colors.black),
                //           icon: const Icon(Icons.arrow_drop_down),
                //           isExpanded: true,
                //           dropdownColor: Colors.white,
                //         ),
                //       ),
                //     ),
                //   )
                : const SizedBox.shrink(),
            selectedRunType != "W"
                ? const SizedBox(height: 10)
                : const SizedBox.shrink(),
            SubmitButton(
              onPressed: () {},
              isLoading: false,
              childWidget: Text(
                Constant.submitRecord,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: 45,
            //     decoration: BoxDecoration(
            //       color: kBlue,
            //       borderRadius: BorderRadius.circular(10), // Adjust the value as needed
            //     ),
            //     child: Center(
            //       child: Text('Submit Record'.toUpperCase(), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1)),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
