import 'package:common/common.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'match_collected_fund_screen.dart';

class MatchDetailsViewScreen extends StatefulWidget {
  const MatchDetailsViewScreen({super.key, required this.matchesId});

  final String matchesId;

  @override
  MatchDetailsViewScreenState createState() => MatchDetailsViewScreenState();
}

class MatchDetailsViewScreenState extends State<MatchDetailsViewScreen> {
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
        body: const TabBarView(
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
                    builder: (context) =>  MatchCollectedFundScreen(matchesId : widget.matchesId),),);
          },
          backgroundColor: envoiceColorsExtensions.primary,
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
                        padding:
                            padding.symmetric(horizontal: Dimensions.smallest),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Over - ${index + 1}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background)),
                            Row(
                              children: [
                                Container(
                                  padding: padding.symmetric(
                                      horizontal: Dimensions.smallest),
                                  color: Colors.white,
                                  child: Text(
                                    "00",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Space(Dimensions.medium),
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(
                                      horizontal: Dimensions.smallest),
                                  child: Text(
                                    "10",
                                    style: theme.textTheme.titleMedium,
                                  ),
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
                                        style: TextStyle(color: Colors.white)),
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
              color: kBlue,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text(
                        "Total Run : ".toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: envoiceColorsExtensions.background),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          color: Colors.red,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                              child: Text(
                                "45",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background),
                              ),
                            ),
                          ),
                        ),
                        Space(Dimensions.medium),
                        Container(
                          color: Colors.green,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                              child: Text(
                                "46",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: Text(Constant.team1Innings,style: theme.textTheme.titleLarge,),
              trailing: Icon(Icons.arrow_drop_down),
              subtitle: Text('53-4(6.0 Ov)',style: theme.textTheme.bodyLarge,),
              children: [
                ListView.builder(shrinkWrap: true,itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Rohit Sharma'),
                    subtitle: Text('c Foakes b Tom Hartley'),
                    trailing: Row(
                      children: [
                        Text('55'),
                        Text('81'),
                        Text('5'),
                        Text('1'),
                        Text('67.9'),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  );
                },itemCount: 2,)
              ],
            ),
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
                        padding:
                            padding.symmetric(horizontal: Dimensions.smallest),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Over - ${index + 1}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: envoiceColorsExtensions.background),
                            ),
                            Row(
                              children: [
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(
                                      horizontal: Dimensions.smallest),
                                  child: Text(
                                    "00",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Space(Dimensions.small),
                                Container(
                                  color: Colors.white,
                                  padding: padding.symmetric(
                                      horizontal: Dimensions.smallest),
                                  child: Text(
                                    "10",
                                    style: theme.textTheme.titleMedium,
                                  ),
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
                                        style: TextStyle(color: Colors.white)),
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
                      child: Text(
                        "Total Run : ".toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: envoiceColorsExtensions.background),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          color: Colors.red,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                              child: Text(
                                "45",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background),
                              ),
                            ),
                          ),
                        ),
                        Space(Dimensions.medium),
                        Container(
                          color: Colors.green,
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Center(
                              child: Text(
                                "46",
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: envoiceColorsExtensions.background),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
