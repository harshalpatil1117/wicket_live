import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:network/core/core.dart';
import 'package:network/network.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:wicket_live_apk/screens/create_teams/team_a_selection.dart';
import 'package:wicket_live_apk/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wicket_live_assets/gen/assets.gen.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({
    super.key,
    required this.availablePlayersList,
  });

  final List<String> availablePlayersList;

  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  SharedPreferenceHelper sharedPreferenceHelper =
      SharedPreferenceHelper(Preference());

  @override
  void initState() {
    super.initState();
    sharedPreferenceHelper.saveTeamA([]);
    sharedPreferenceHelper.saveTeamB([]);
    sharedPreferenceHelper.saveTeamACaptain("");
    sharedPreferenceHelper.saveTeamBCaptain("");
    setState(() {});
  }

  // void initializeCheckboxStates() {
  //   team1Checked = List<bool>.filled(team1Captain.length, false);
  //   team2Checked = List<bool>.filled(team2Captain.length, false);
  //   filteredTeam1Captain.addAll(team1Captain);
  //   filteredTeam2Captain.addAll(team2Captain);
  // }

  // void dropdownCheckbox() {
  //   setState(() {
  //     for (var count = 0; count < team1Captain.length; count++) {
  //       if (selectedTeam1Captain != null) {
  //         if (selectedTeam1Captain == team1Captain[count]) {
  //           team1Checked[count] = true;
  //         } else {
  //           team1Checked[count] = false;
  //         }
  //       }
  //     }
  //     // isTeam1OnChange = true;
  //     for (var count = 0; count < team2Captain.length; count++) {
  //       if (selectedTeam2Captain != null) {
  //         if (selectedTeam2Captain == team2Captain[count]) {
  //           team2Checked[count] = true;
  //         } else {
  //           team2Checked[count] = false;
  //         }
  //       }
  //     }
  //   });
  //
  //   // isTeam1OnChange = true;
  // }
  //
  // void _initializeDatabase() async {
  //   await _databaseHelper.initDatabase();
  //   countRows = await _databaseHelper.createTeamCountRows(DateFormat('dd-MM-yyyy').format(DateTime.now()));
  //   setState(() {});
  //   if(countRows != 0){
  //     List<Map<String, dynamic>> teamsForToday = await _databaseHelper.getCreateTeamData(DateFormat('dd-MM-yyyy').format(DateTime.now()));
  //     teamsForToday.forEach((team) {
  //       setState((){
  //         selectedTeam1Captain = team['team1Captain'];
  //         selectedTeam2Captain = team['team2Captain'];
  //         selectNumOfMatch = team['numberOfMatch'];
  //         selectedTeam1Bb = team['team1Bb'];
  //         selectedTeam2Bb = team['team2Bb'];
  //       });
  //       List<String> team1CheckedString = team['team1Checked'].split(',');
  //       List<String> team2CheckedString = team['team2Checked'].split(',');
  //
  //       for(var count=0;count<team1CheckedString.length;count++){
  //         team1Checked[count] = team1CheckedString[count] == "true" ? true : false;
  //         team2Checked[count] = team2CheckedString[count] == "true" ? true : false;
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constant.createTeam,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: envoiceColorsExtensions.background,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Space(Dimensions.small),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => TeamASelection(
                    availablePlayersList: widget.availablePlayersList,
                  ),
                ),

              );
            },
            child: Center(
              child: WicketLiveAssets.lottie.teamABtn.lottie(
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              ),
                // Space(Dimensions.medium),
                // BaseDropDownButton(
                //   label: Constant.selectTeam1BB,
                //   value: selectedTeam1Bb,
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       selectedTeam1Bb = newValue!;
                //       if (selectedTeam1Bb == 'batting') {
                //         selectedTeam2Bb = 'bowling';
                //       } else {
                //         selectedTeam2Bb = 'batting';
                //       }
                //     });
                //   },
                //   options: team1bb,
                // ),
                // Space(Dimensions.medium),
                // selectedTeam1Captain != Constant.selectTeam1Captain
                //     ? ExpansionTile(
                //         tilePadding: EdgeInsets.symmetric(horizontal: 10),
                //         trailing: Icon(Icons.arrow_drop_down),
                //         collapsedShape: RoundedRectangleBorder(
                //           side: BorderSide(
                //             width: 2,
                //             color: theme.envoiceColorsExtensions.border,
                //           ),
                //           borderRadius: BorderRadius.circular(
                //             Dimensions.of(context).radii.small,
                //           ),
                //         ),
                //         shape: RoundedRectangleBorder(
                //           side: BorderSide(
                //             width: 2,
                //             color: theme.envoiceColorsExtensions.border,
                //           ),
                //           borderRadius: BorderRadius.circular(
                //             Dimensions.of(context).radii.small,
                //           ),
                //         ),
                //         iconColor: theme.envoiceColorsExtensions.primary,
                //         collapsedIconColor:
                //             theme.envoiceColorsExtensions.primary,
                //         title: Text(
                //           Constant.selectTeam1Player,
                //           style: theme.textTheme.titleLarge,
                //         ),
                //         children: [
                //           ListView.builder(
                //             physics: NeverScrollableScrollPhysics(),
                //             shrinkWrap: true,
                //             itemCount: playersMap.length,
                //             itemBuilder: (context, index) {
                //               return CheckboxListTile(
                //                 dense: true,
                //                 enabled: !team2Checked[index],
                //                 title: Text(
                //                     playersMap.entries.elementAt(index).value),
                //                 value: team1Checked[index],
                //                 onChanged: (bool? value) {
                //                   bool isCheck = false;
                //                   for(var count=0;count<team1SelectedPlayersList.length;count++){
                //                     if(playersMap.entries.elementAt(index).value == team1SelectedPlayersList[count]){
                //                       setState(() {
                //                         isCheck = true;
                //                       });
                //                     }
                //                   }
                //                   if(!isCheck){
                //                     team1SelectedPlayersList.add(playersMap.entries.elementAt(index).value);
                //                   }
                //                   else{
                //                     team1SelectedPlayersList.remove(playersMap.entries.elementAt(index).value);
                //                   }
                //                   if (team1Captain[index] !=
                //                       selectedTeam1Captain) {
                //                     setState(() {
                //                       if (value == true) {
                //                         team1Checked[index] = true;
                //                         team2Checked[index] = false;
                //                       } else {
                //                         team1Checked[index] = false;
                //                       }
                //                     });
                //                   }
                //                 },
                //               );
                //             },
                //           ),
                //         ],
                //       )
                //     : SizedBox(),
                // Space(Dimensions.medium),
                // Divider(color: envoiceColorsExtensions.primary, thickness: 2),
                // Space(Dimensions.medium),
                // BaseDropDownFormField(
                //   label: Constant.selectTeam2Captain,
                //   value: selectedTeam2Captain,
                //   onChanged: (String? newValue) {
                //     bool isCheck = false;
                //     for(var count=0;count<team2SelectedPlayersList.length;count++){
                //       if(newValue == team2SelectedPlayersList[count]){
                //         setState(() {
                //           isCheck = true;
                //         });
                //       }
                //     }
                //     if(!isCheck){
                //       team2SelectedPlayersList.add(newValue!);
                //     }
                //     else{
                //       team2SelectedPlayersList.remove(newValue);
                //     }
                //     setState(() {
                //       selectedTeam2Captain = newValue!;
                //       filteredTeam1Captain = List.from(team1Captain)
                //         ..remove(selectedTeam2Captain);
                //       dropdownCheckbox();
                //     });
                //   },
                //   validator: (value) {
                //     if (value == Constant.selectTeam2Captain ||
                //         value == null ||
                //         value.isEmpty) {
                //       return "Please select team-2 captain";
                //     }
                //     return null;
                //   },
                //   options: filteredTeam2Captain,
                // ),
                // Space(Dimensions.medium),
                // BaseDropDownButton(
                //   label: Constant.selectTeam2BB,
                //   value: selectedTeam2Bb,
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       selectedTeam2Bb = newValue!;
                //       if (selectedTeam2Bb == 'batting') {
                //         selectedTeam1Bb = 'bowling';
                //       } else {
                //         selectedTeam1Bb = 'batting';
                //       }
                //     });
                //   },
                //   options: team2bb,
                // ),
                // Space(Dimensions.medium),
                // selectedTeam2Captain != Constant.selectTeam2Captain
                //     ? ExpansionTile(
                //         tilePadding: EdgeInsets.symmetric(horizontal: 10),
                //         collapsedShape: RoundedRectangleBorder(
                //           side: BorderSide(
                //             width: 2,
                //             color: theme.envoiceColorsExtensions.border,
                //           ),
                //           borderRadius: BorderRadius.circular(
                //             Dimensions.of(context).radii.small,
                //           ),
                //         ),
                //         shape: RoundedRectangleBorder(
                //           side: BorderSide(
                //             width: 2,
                //             color: theme.envoiceColorsExtensions.border,
                //           ),
                //           borderRadius: BorderRadius.circular(
                //             Dimensions.of(context).radii.small,
                //           ),
                //         ),
                //         iconColor: theme.envoiceColorsExtensions.primary,
                //         collapsedIconColor:
                //             theme.envoiceColorsExtensions.primary,
                //         title: Text(
                //           Constant.selectTeam2Player,
                //           style: theme.textTheme.titleLarge,
                //         ),
                //         trailing: Icon(Icons.arrow_drop_down),
                //         children: [
                //           ListView.builder(
                //             physics: NeverScrollableScrollPhysics(),
                //             shrinkWrap: true,
                //             itemCount: playersMap.length,
                //             itemBuilder: (context, index) {
                //               return CheckboxListTile(
                //                 dense: true,
                //                 enabled: !team1Checked[index],
                //                 title: Text(
                //                     playersMap.entries.elementAt(index).value),
                //                 value: team2Checked[index],
                //                 onChanged: (bool? value) {
                //                   bool isCheck = false;
                //                   for(var count=0;count<team2SelectedPlayersList.length;count++){
                //                     if(playersMap.entries.elementAt(index).value == team2SelectedPlayersList[count]){
                //                       setState(() {
                //                         isCheck = true;
                //                       });
                //                     }
                //                   }
                //                   if(!isCheck){
                //                     team2SelectedPlayersList.add(playersMap.entries.elementAt(index).value);
                //                   }
                //                   else{
                //                     team2SelectedPlayersList.remove(playersMap.entries.elementAt(index).value);
                //                   }
                //                   if (team2Captain[index] !=
                //                       selectedTeam2Captain) {
                //                     setState(() {
                //                       if (value == true) {
                //                         team2Checked[index] = true;
                //                         team1Checked[index] = false;
                //                       } else {
                //                         team2Checked[index] = false;
                //                       }
                //                     });
                //                   }
                //                 },
                //               );
                //             },
                //           ),
                //         ],
                //       )
                //     : SizedBox(),
                // Space(Dimensions.medium),
                // Divider(color: envoiceColorsExtensions.primary, thickness: 2),
                // Space(Dimensions.medium),
                // BaseDropDownFormField(
                //   label: Constant.selectNumOfMatch,
                //   value: selectNumOfMatch,
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       selectNumOfMatch = newValue!;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == Constant.selectNumOfMatch ||
                //         value == null ||
                //         value.isEmpty) {
                //       return "Please select the number of the match";
                //     }
                //     return null;
                //   },
                //   options: numOfMatch,
                // ),
                // const Space(Dimensions.medium),
                // SubmitButton(
                //   onPressed: () async {
                //     if (_formKey.currentState!.validate()) {
                //       if (selectedTeam2Bb == Constant.selectTeam2BB ||
                //           selectedTeam1Bb == Constant.selectTeam1BB) {
                //         Fluttertoast.showToast(
                //             msg: "Please Select all Required fields",
                //             toastLength: Toast.LENGTH_SHORT,
                //             gravity: ToastGravity.BOTTOM,
                //             timeInSecForIosWeb: 1,
                //             backgroundColor: Colors.red,
                //             textColor: Colors.white,
                //             fontSize: 16.0);
                //       }
                //       else{
                //         if(countRows == 0){
                //           await _databaseHelper.initDatabase();
                //           await _databaseHelper.createTeamInsert(selectedTeam1Captain, selectedTeam2Captain, selectedTeam1Bb, selectedTeam2Bb, team1SelectedPlayersList.join(","), team2SelectedPlayersList.join(","), selectNumOfMatch, team1Checked.join(","), team2Checked.join(","), DateFormat('dd-MM-yyyy').format(DateTime.now()));
                //         }
                //         else{
                //           await _databaseHelper.initDatabase();
                //           await _databaseHelper.createTeamUpdate(selectedTeam1Captain, selectedTeam2Captain, selectedTeam1Bb, selectedTeam2Bb, team1SelectedPlayersList.join(","), team2SelectedPlayersList.join(","), selectNumOfMatch, team1Checked.join(","), team2Checked.join(","), DateFormat('dd-MM-yyyy').format(DateTime.now()));
                //         }
                //       }
                //     }
                //   },
                //   isLoading: false,
                //   childWidget: Text(countRows == 0 ? Constant.createMatch.toUpperCase() : Constant.updateMatch.toUpperCase(),style: theme.textTheme.headlineMedium?.copyWith(
                //     fontWeight: FontWeight.bold,
                //     fontSize: 15,
                //     letterSpacing: 1,
                //     color: envoiceColorsExtensions.background,
                //   )),
                // ),
            ),
          ),
          Text(
            "Team A",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Space(Dimensions.large),
          WicketLiveAssets.lottie.vs.lottie(
            width: 150,
            height: 150,
            fit: BoxFit.fill,
            repeat: false,
          ),
          Space(Dimensions.medium),
          InkWell(
            onTap: () {},
            child: WicketLiveAssets.lottie.teamBBtn.lottie(
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
          Text(
            "Team B",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
