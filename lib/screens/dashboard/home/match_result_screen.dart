import 'package:common/common.dart';
import 'dart:io';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/material.dart';
import 'package:network/database/db/db.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class MatchResultScreen extends StatefulWidget {
  final String matchId, title;

  MatchResultScreen({Key? key, required this.matchId, required this.title})
      : super(key: key);

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  int totalQty = 0;
  int totalAmount = 0;
  final DB _databaseHelper = DB();

  Future<void> generatePDF() async {
    String date = DateTime.now().toString().split(" ")[0];
    // Create a PDF document
    PdfDocument document = PdfDocument();

    // Draw match details for inning 1 on the first page
    PdfPage page1 = document.pages.add();
    drawInningsDetails(
        page1,
        "Match-${widget.matchId} : 1st Innings (Batting)  (${innings1TotalRuns}/${inning1Wicket}) ($date)",
        innings1BatterFinalList,
        innings1BallerFinalList);

    // Draw match details for inning 2 on the second page
    PdfPage page2 = document.pages.add();
    drawInningsDetails(
        page2,
        "Match-${widget.matchId} : 2nd Innings (Batting)  (${innings2TotalRuns}/${inning2Wicket}) ($date)",
        innings2BatterFinalList,
        innings2BallerFinalList);

    // Draw match funds on the third page
    PdfPage page3 = document.pages.add();
    drawMatchFunds(page3, matchFundFinalList);

    // Save the document to the user's downloads directory
    final String downloadsDirectory = '/storage/emulated/0/Download';
    final String filePath =
        '$downloadsDirectory/match${widget.matchId}_${date}.pdf';

    // Get the bytes from the document
    final List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    // Save the bytes to the file
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    // Show a message to the user
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PDF Generated'),
          content: Text('The PDF has been saved to your downloads directory.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Helper function to draw innings details
  void drawInningsDetails(PdfPage page, String title, List<String> batterList,
      List<String> ballerList) {
    // Draw title for the innings
    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(10, 10, page.getClientSize().width - 20, 20),
    );

    // Draw player statistics for batters
    drawPlayerDetails(
        page, batterList, 30, ['R', 'B', '4s', '6s', '1s', '2s', 'SR']);

    // Draw player statistics for ballers
    drawPlayerDetails(
        page, ballerList, 400, ['B', 'R', 'WB', 'WR', 'W', 'Eco']);
  }

// Helper function to draw match funds
  void drawMatchFunds(PdfPage page, List<String> fundMap) {
    // Draw title for match funds
    page.graphics.drawString(
      'Match Funds',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(10, 10, page.getClientSize().width - 20, 20),
    );

    // Draw player details for match funds
    drawPlayerDetails(page, matchFundFinalList, 30, ['Qty', 'Rs'],
        isMatchFund: true);
  }

// Helper function to draw player details
  void drawPlayerDetails(PdfPage page, List<String> playerList, double startY,
      List<String> headers,
      {bool isMatchFund = false}) {
    // Draw table header
    drawTableHeader(page, startY, headers);

    // Draw player details
    double y = startY + 20;
    for (String player in playerList) {
      List<String> details = player.split("_");

      // Draw player name
      page.graphics.drawString(
        details[0],
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(10, y, 100, 20),
      );

      // Draw other player details
      for (int i = 1; i < details.length; i++) {
        page.graphics.drawString(
          details[i],
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(120 + (i - 1) * 60, y, 50, 20),
        );
      }

      y += 20;
    }

    isMatchFund
        ? // Draw player name
        page.graphics.drawString(
            "Qty: $totalQty",
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: Rect.fromLTWH(85 + (1 - 1) * 60, y + 20, 100, 20),
          )
        : null;
    isMatchFund
        ? page.graphics.drawString(
            "Rs. $totalAmount",
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: Rect.fromLTWH(155 + (1 - 1) * 60, y + 20, 100, 20),
          )
        : null;
  }

// Helper function to draw table header
  void drawTableHeader(PdfPage page, double startY, List<String> headers) {
    // Draw table header for batters/ballers
    page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(10, startY, page.getClientSize().width - 20, 20),
      pen: PdfPen(PdfColor(0, 0, 0)),
      brush: PdfSolidBrush(PdfColor(200, 200, 200)),
    );

    // Draw column headers
    page.graphics.drawString(
      'Player Name',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(10, startY, 100, 20),
    );

    for (int i = 0; i < headers.length; i++) {
      page.graphics.drawString(
        headers[i],
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(120 + i * 60, startY, 50, 20),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _inningHighlightDatabase();
  }

  List inningHighlight = [];

  List<Map<String, dynamic>> innings1Batter = [];
  List<Map<String, dynamic>> innings1Bowler = [];
  List<Map<String, dynamic>> innings2Batter = [];
  List<Map<String, dynamic>> innings2Bowler = [];

  // Map to store aggregated statistics
  Map<String, List> playerStatsMapInnings1Batter = {};
  Map<String, List> playerStatsMapInnings1Baller = {};
  Map<String, List> playerStatsMapInnings2Batter = {};
  Map<String, List> playerStatsMapInnings2Baller = {};

  List<String> innings1BatterFinalList = [];
  List<String> innings1BallerFinalList = [];
  List<String> innings2BatterFinalList = [];
  List<String> innings2BallerFinalList = [];
  List<String> matchFundFinalList = [];

  int inning1Wicket = 0;
  int inning2Wicket = 0;

  List matchCollectedFund = [];
  List<Map<String, dynamic>> matchCollectedFundList = [];
  Map<String, List> matchCollectedFundMap = {};

  Future<void> _inningHighlightDatabase() async {
    await _databaseHelper.initDatabase();
    inningHighlight =
        await _databaseHelper.getInningHighlightByMatchId(widget.matchId);
    setState(() {});
    if (inningHighlight.isNotEmpty) {
      inningHighlight.forEach((match) {
        if (int.parse(match['inningDetailId'].toString()) % 2 != 0 &&
            int.parse(match['id'].toString()) % 2 != 0) {
          innings1Batter.add(match);
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 != 0 &&
            int.parse(match['id'].toString()) % 2 == 0) {
          innings1Bowler.add(match);
          inning1Wicket = inning1Wicket +
              int.parse(match['wicket'].toString() == ''
                  ? "0"
                  : match['wicket'].toString());
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 == 0 &&
            int.parse(match['id'].toString()) % 2 != 0) {
          innings2Batter.add(match);
          setState(() {});
        }
        if (int.parse(match['inningDetailId'].toString()) % 2 == 0 &&
            int.parse(match['id'].toString()) % 2 == 0) {
          innings2Bowler.add(match);
          inning2Wicket = inning2Wicket +
              int.parse(match['wicket'].toString() == ''
                  ? "0"
                  : match['wicket'].toString());
          setState(() {});
        }
      });

      print("666");
      print(innings1Bowler);

      innings1Batter.forEach((player) {
        String playerName = player['playerName'];
        int runs = int.parse(player['runScored'].toString() == ''
            ? '0'
            : player['runScored'].toString());
        int balls = int.parse(player['balls'].toString() == ''
            ? '0'
            : player['balls'].toString());
        int fours = int.parse(player['fours'].toString() == ''
            ? '0'
            : player['fours'].toString());
        int sixes = int.parse(player['sixes'].toString() == ''
            ? '0'
            : player['sixes'].toString());
        int singleRun = int.parse(player['singleRun'].toString() == ''
            ? '0'
            : player['singleRun'].toString());
        int doubleRun = int.parse(player['doubleRun'].toString() == ''
            ? '0'
            : player['doubleRun'].toString());
        double strikeRate = double.parse(player['strikeRate'].toString() == ''
            ? '0'
            : player['strikeRate'].toString());

        if (playerStatsMapInnings1Batter.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings1Batter[playerName]?[0] += runs; // Total runs
          playerStatsMapInnings1Batter[playerName]?[1] += balls; // Total balls
          playerStatsMapInnings1Batter[playerName]?[2] = fours; // Total fours
          playerStatsMapInnings1Batter[playerName]?[3] = sixes; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[4] +=
              singleRun; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[5] +=
              doubleRun; // Total sixes
          playerStatsMapInnings1Batter[playerName]?[6] =
              strikeRate; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          setState(() {});
          playerStatsMapInnings1Batter[playerName] = [
            runs,
            balls,
            fours,
            sixes,
            singleRun,
            doubleRun,
            strikeRate
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Calculate strike rate
      playerStatsMapInnings1Batter.forEach((playerName, stats) {
        int runs = stats[0];
        int balls = stats[1];
        if (balls != 0) {
          double strikeRate = (runs / balls) * 100;
          playerStatsMapInnings1Batter[playerName]?[6] =
              strikeRate.round(); // Round to integer
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings1Batter.forEach((playerName, stats) {
        print(
            '$playerName: Runs: ${stats[0]}, Balls: ${stats[1]}, Fours: ${stats[2]}, Sixes: ${stats[3]}, singleRunCount: ${stats[4]}, doubleRunCount: ${stats[5]}, Strike Rate: ${stats[6]}');
      });

      innings2Batter.forEach((player) {
        String playerName = player['playerName'];
        int runs = int.parse(player['runScored'].toString() == ''
            ? '0'
            : player['runScored'].toString());
        int balls = int.parse(player['balls'].toString());
        int fours = int.parse(player['fours'].toString());
        int sixes = int.parse(player['sixes'].toString());
        int singleRun = int.parse(player['singleRun'].toString());
        int doubleRun = int.parse(player['doubleRun'].toString());
        double strikeRate = double.parse(player['strikeRate'].toString());

        if (playerStatsMapInnings2Batter.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings2Batter[playerName]?[0] += runs; // Total runs
          playerStatsMapInnings2Batter[playerName]?[1] += balls; // Total balls
          playerStatsMapInnings2Batter[playerName]?[2] = fours; // Total fours
          playerStatsMapInnings2Batter[playerName]?[3] = sixes; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[4] +=
              singleRun; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[5] +=
              doubleRun; // Total sixes
          playerStatsMapInnings2Batter[playerName]?[6] =
              strikeRate; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          setState(() {});
          playerStatsMapInnings2Batter[playerName] = [
            runs,
            balls,
            fours,
            sixes,
            singleRun,
            doubleRun,
            strikeRate
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Calculate strike rate
      playerStatsMapInnings2Batter.forEach((playerName, stats) {
        int runs = stats[0];
        int balls = stats[1];
        if (balls != 0) {
          double strikeRate = (runs / balls) * 100;
          playerStatsMapInnings2Batter[playerName]?[6] =
              strikeRate.round(); // Round to integer
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings2Batter.forEach((playerName, stats) {
        print(
            '$playerName: Runs: ${stats[0]}, Balls: ${stats[1]}, Fours: ${stats[2]}, Sixes: ${stats[3]}, singleRunCount: ${stats[4]}, doubleRunCount: ${stats[5]}, Strike Rate: ${stats[6]}');
      });

      innings1Bowler.forEach((player) {
        String playerName = player['playerName'];
        int over = int.parse(player['over'].toString());
        int runsConceded = int.parse(player['runsConceded'].toString() == ''
            ? '0'
            : player['runsConceded'].toString());
        int extra = int.parse(player['extra'].toString());
        int wicket = int.parse(player['wicket'].toString() == ''
            ? '0'
            : player['wicket'].toString());
        double economy = double.parse(player['economy'].toString());

        if (playerStatsMapInnings1Baller.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings1Baller[playerName]?[0] += over; // Total runs
          playerStatsMapInnings1Baller[playerName]?[1] +=
              runsConceded; // Total balls
          playerStatsMapInnings1Baller[playerName]?[2] = extra; // Total fours
          playerStatsMapInnings1Baller[playerName]?[3] = extra; // Total fours
          playerStatsMapInnings1Baller[playerName]?[4] += wicket; // Total sixes
          playerStatsMapInnings1Baller[playerName]?[5] = economy; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          playerStatsMapInnings1Baller[playerName] = [
            over,
            runsConceded,
            extra,
            extra,
            wicket,
            economy
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings1Baller.forEach((playerName, stats) {
        print(
            '$playerName: over: ${stats[0]}, runsConceded: ${stats[1]}, extra: ${stats[2]}, extra: ${stats[3]}, wicket: ${stats[4]}, economy: ${stats[5]}');
      });

      innings2Bowler.forEach((player) {
        String playerName = player['playerName'];
        int over = int.parse(player['over'].toString());
        int runsConceded = int.parse(player['runsConceded'].toString() == ''
            ? '0'
            : player['runsConceded'].toString());
        int extra = int.parse(player['extra'].toString());
        int wicket = int.parse(player['wicket'].toString() == ''
            ? '0'
            : player['wicket'].toString());
        double economy = double.parse(player['economy'].toString());

        if (playerStatsMapInnings2Baller.containsKey(playerName)) {
          // Update existing player's statistics
          playerStatsMapInnings2Baller[playerName]?[0] += over; // Total runs
          playerStatsMapInnings2Baller[playerName]?[1] +=
              runsConceded; // Total balls
          playerStatsMapInnings2Baller[playerName]?[2] = extra; // Total fours
          playerStatsMapInnings2Baller[playerName]?[3] = extra; // Total fours
          playerStatsMapInnings2Baller[playerName]?[4] += wicket; // Total sixes
          playerStatsMapInnings2Baller[playerName]?[5] = economy; // Total sixes
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          playerStatsMapInnings2Baller[playerName] = [
            over,
            runsConceded,
            extra,
            extra,
            wicket,
            economy
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      // Print the aggregated statistics
      playerStatsMapInnings2Baller.forEach((playerName, stats) {
        print(
            '$playerName: over: ${stats[0]}, runsConceded: ${stats[1]}, extra: ${stats[2]}, extra: ${stats[3]}, wicket: ${stats[4]}, economy: ${stats[5]}');
      });

      innings1BatterFinalList = formatData(playerStatsMapInnings1Batter, false);
      innings1BallerFinalList = formatData(playerStatsMapInnings1Baller, false);
      innings2BatterFinalList = formatData(playerStatsMapInnings2Batter, false);
      innings2BallerFinalList = formatData(playerStatsMapInnings2Baller, false);
      setState(() {});
    } else {
      print("No inning details for today's match.");
    }

    matchCollectedFund =
        await _databaseHelper.getMatchFundByMatchId(widget.matchId);

    print("matchCollectedFund");
    print(matchCollectedFund);
    if (matchCollectedFund.isNotEmpty) {
      matchCollectedFund.forEach((player) {
        print("MATCHHHHHH $player");
        String playerName = player['playerName'];
        int numberOfBall = int.parse(player['numberOfBall'].toString());
        int amount = int.parse(player['amount'].toString());
        totalQty = totalQty + numberOfBall;
        totalAmount = totalAmount + amount;

        if (matchCollectedFundMap.containsKey(playerName)) {
          // Update existing player's statistics
          matchCollectedFundMap[playerName]?[0] += numberOfBall; // Total runs
          matchCollectedFundMap[playerName]?[1] += amount; // Total balls
          // For strike rate, we'll calculate it later
        } else {
          // Add new player to the map
          setState(() {});
          matchCollectedFundMap[playerName] = [
            numberOfBall,
            amount
          ]; // [runs, balls, fours, sixes, totalStrikeRate]
        }
      });

      matchFundFinalList = formatData(matchCollectedFundMap, true);
      print("MATCHHH CHKKK $matchFundFinalList");

      matchCollectedFundMap.forEach((playerName, stats) {
        print('$playerName: Runs: ${stats[0]}, Balls: ${stats[1]}');
      });
    }

    for (var count = 0; count < innings1BallerFinalList.length; count++) {
      setState(() {
        innings1TotalRuns += int.parse(
            innings1BallerFinalList[count].toString().split("_")[2].toString());
      });
    }

    for (var count = 0; count < innings2BallerFinalList.length; count++) {
      setState(() {
        innings2TotalRuns += int.parse(
            innings2BallerFinalList[count].toString().split("_")[2].toString());
      });
    }
  }

  List<String> formatData(Map<String, List> data, bool isMatchFundData) {
    List<String> formattedList = [];
    List<MapEntry<String, List>> sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    Map<String, List> sortedMap = Map.fromEntries(sortedEntries);
    isMatchFundData
        ? sortedMap.forEach((key, value) {
            String formattedString = "$key" + "_" + value.join("_");
            formattedList.add(formattedString);
          })
        : data.forEach((key, value) {
            String formattedString = "$key" + "_" + value.join("_");
            formattedList.add(formattedString);
          });
    return formattedList;
  }

  int innings1TotalRuns = 0;
  int innings2TotalRuns = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.envoiceColorsExtensions.onSecondary,
        title: Text(
          "${widget.title}",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.envoiceColorsExtensions.background,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await generatePDF();
            },
            icon: Icon(
              Icons.download,
              color: theme.envoiceColorsExtensions.background,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: padding.all(Dimensions.smallest),
        child: SingleChildScrollView(
          child: Padding(
            padding: padding.symmetric(
              vertical: Dimensions.smaller,
              horizontal: Dimensions.smaller,
            ),
            child: Column(
              children: [
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedBackgroundColor:
                      theme.envoiceColorsExtensions.primary,
                  textColor: theme.envoiceColorsExtensions.secondary,
                  backgroundColor: theme.envoiceColorsExtensions.primary,
                  iconColor: theme.envoiceColorsExtensions.background,
                  collapsedIconColor: theme.envoiceColorsExtensions.background,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1st Innings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                      Text(
                        '${innings1TotalRuns}-${inning1Wicket}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: padding.symmetric(
                        horizontal: Dimensions.smallest,
                        vertical: Dimensions.smallest,
                      ),
                      decoration: BoxDecoration(
                        color: theme.envoiceColorsExtensions.background,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: theme.envoiceColorsExtensions.border,
                            child: ListTile(
                              tileColor: theme.envoiceColorsExtensions.border,
                              title: Text(
                                'Batsman',
                                style: theme.textTheme.titleMedium,
                              ),
                              trailing: Container(
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                height: MediaQuery.sizeOf(context).height,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'R',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'B',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '1s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '2s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '4s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '6s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'SR',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: innings1BatterFinalList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(innings1BatterFinalList[index]
                                      .toString()
                                      .split("_")[0]),
                                  trailing: Container(
                                    // color: Colors.red,
                                    width:
                                        MediaQuery.sizeOf(context).width / 1.8,
                                    height: MediaQuery.sizeOf(context).height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[1],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[2],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[5],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[6],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[3],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[4],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BatterFinalList[index]
                                              .toString()
                                              .split("_")[7],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          Container(
                            color: theme.envoiceColorsExtensions.border,
                            child: ListTile(
                              tileColor: Colors.grey,
                              title: Text(
                                'Bowler',
                                style: theme.textTheme.titleMedium,
                              ),
                              trailing: Container(
                                // color: Colors.green,
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                height: MediaQuery.sizeOf(context).height,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'B',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'R',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'WB',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'WR',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'W',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'ECO',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: innings1BallerFinalList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(innings1BallerFinalList[index]
                                      .toString()
                                      .split("_")[0]),
                                  trailing: Container(
                                    // color: Colors.red,
                                    width:
                                        MediaQuery.sizeOf(context).width / 1.8,
                                    height: MediaQuery.sizeOf(context).height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[1],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[2],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[3],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[4],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[5],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings1BallerFinalList[index]
                                              .toString()
                                              .split("_")[6],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    )
                  ],
                ),
                Space(Dimensions.small),
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedBackgroundColor:
                      theme.envoiceColorsExtensions.primary,
                  textColor: theme.envoiceColorsExtensions.secondary,
                  backgroundColor: theme.envoiceColorsExtensions.primary,
                  iconColor: theme.envoiceColorsExtensions.background,
                  collapsedIconColor: theme.envoiceColorsExtensions.background,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2st Innings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                      Text(
                        '${innings2TotalRuns}-${inning2Wicket}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: padding.symmetric(
                        horizontal: Dimensions.smallest,
                        vertical: Dimensions.smallest,
                      ),
                      decoration: BoxDecoration(
                        color: theme.envoiceColorsExtensions.background,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: theme.envoiceColorsExtensions.border,
                            child: ListTile(
                              tileColor: Colors.grey,
                              title: Text(
                                'Batsman',
                                style: theme.textTheme.titleMedium,
                              ),
                              trailing: Container(
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                height: MediaQuery.sizeOf(context).height,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'R',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'B',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '1s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '2s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '4s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      '6s',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'SR',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: innings2BatterFinalList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(innings2BatterFinalList[index]
                                      .toString()
                                      .split("_")[0]),
                                  trailing: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width / 1.8,
                                    height: MediaQuery.sizeOf(context).height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[1],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[2],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[5],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[6],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[3],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[4],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BatterFinalList[index]
                                              .toString()
                                              .split("_")[7],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          Container(
                            color: theme.envoiceColorsExtensions.border,
                            child: ListTile(
                              tileColor: Colors.grey,
                              title: Text(
                                'Bowler',
                                style: theme.textTheme.titleMedium,
                              ),
                              trailing: Container(
                                width: MediaQuery.sizeOf(context).width / 1.8,
                                height: MediaQuery.sizeOf(context).height,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'B',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'R',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'WB',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'WR',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'W',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'ECO',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: innings2BallerFinalList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(innings2BallerFinalList[index]
                                      .toString()
                                      .split("_")[0]),
                                  trailing: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width / 1.8,
                                    height: MediaQuery.sizeOf(context).height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[1],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[2],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[3],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[4],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[5],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.small),
                                        Text(
                                          innings2BallerFinalList[index]
                                              .toString()
                                              .split("_")[6],
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
                Space(Dimensions.small),
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Set the desired border radius
                  ),
                  collapsedBackgroundColor:
                      theme.envoiceColorsExtensions.primary,
                  textColor: theme.envoiceColorsExtensions.secondary,
                  backgroundColor: theme.envoiceColorsExtensions.primary,
                  iconColor: theme.envoiceColorsExtensions.background,
                  collapsedIconColor: theme.envoiceColorsExtensions.background,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Match Funds',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                      Text(
                        'Qty : ${totalQty}      \u{20B9} $totalAmount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: padding.symmetric(
                        horizontal: Dimensions.smallest,
                        vertical: Dimensions.smallest,
                      ),
                      decoration: BoxDecoration(
                        color: theme.envoiceColorsExtensions.background,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: theme.envoiceColorsExtensions.border,
                            child: ListTile(
                              tileColor: Colors.grey,
                              title: Text(
                                'Player Name',
                                style: theme.textTheme.titleMedium,
                              ),
                              trailing: Container(
                                width: MediaQuery.sizeOf(context).width / 2,
                                height: MediaQuery.sizeOf(context).height,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Qty',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Space(Dimensions.small),
                                    Text(
                                      'Rs',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: matchCollectedFundMap.length,
                              itemBuilder: (context, index) {
                                List<MapEntry<String, List>> sortedEntries =
                                    matchCollectedFundMap.entries.toList()
                                      ..sort((a, b) => a.key.compareTo(b.key));

                                Map<String, List> sortedMap =
                                    Map.fromEntries(sortedEntries);
                                return ListTile(
                                  title: Text(sortedMap.keys.elementAt(index)),
                                  trailing: Container(
                                    width: MediaQuery.sizeOf(context).width / 2,
                                    height: MediaQuery.sizeOf(context).height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          sortedMap['${sortedMap.keys.elementAt(index)}']![
                                                  0]
                                              .toString(),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Space(Dimensions.large),
                                        Text(
                                          sortedMap['${sortedMap.keys.elementAt(index)}']![
                                                  1]
                                              .toString(),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          Divider(
                            color: theme.envoiceColorsExtensions.border,
                          ),
                          Space(Dimensions.smaller),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Total Qty: $totalQty",
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                "Total Amount: $totalAmount",
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Space(Dimensions.smallest),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
