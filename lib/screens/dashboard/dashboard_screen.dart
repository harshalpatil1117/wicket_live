import 'dart:convert';
import 'dart:io';
import 'package:common/common.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dimensions_theme/dimensions_theme.dart';
import 'package:flutter/services.dart';
import 'package:network/network.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wicket_live_apk/utils/constants.dart';
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> match1Inning1batter = [];
  List<String> match1Inning1baller = [];
  List<String> match1Inning2batter = [];
  List<String> match1Inning2baller = [];
  String match1Inning1TotalRun = "";
  String match1Inning2TotalRun = "";
  String match1Inning1TotalWicket = "";
  String match1Inning2TotalWicket = "";

  List<String> match2Inning1batter = [];
  List<String> match2Inning1baller = [];
  List<String> match2Inning2batter = [];
  List<String> match2Inning2baller = [];
  String match2Inning1TotalRun = '';
  String match2Inning2TotalRun = '';
  String match2Inning1TotalWicket = '';
  String match2Inning2TotalWicket = '';

  List<String> match3Inning1batter = [];
  List<String> match3Inning1baller = [];
  List<String> match3Inning2batter = [];
  List<String> match3Inning2baller = [];
  String match3Inning1TotalRun = '';
  String match3Inning2TotalRun = '';
  String match3Inning1TotalWicket = '';
  String match3Inning2TotalWicket = '';

  List<String> match4Inning1batter = [];
  List<String> match4Inning1baller = [];
  List<String> match4Inning2batter = [];
  List<String> match4Inning2baller = [];
  String match4Inning1TotalRun = '';
  String match4Inning2TotalRun = '';
  String match4Inning1TotalWicket = '';
  String match4Inning2TotalWicket = '';

  List<String> match5Inning1batter = [];
  List<String> match5Inning1baller = [];
  List<String> match5Inning2batter = [];
  List<String> match5Inning2baller = [];
  String match5Inning1TotalRun = '';
  String match5Inning2TotalRun = '';
  String match5Inning1TotalWicket = '';
  String match5Inning2TotalWicket = '';

  int _selectedIndex = 0;
  final DB _databaseHelper = DB();
  List<Map<String, dynamic>> matchFunds = [];
  bool isMatchDataReady = false;

  List<String> matchFundFinalList = [];

  final List<Widget> _widgetOptions = [
    const HomeScreen(),
  ];

  List<String> formatData(Map<String, List> data) {
    List<String> formattedList = [];
    List<MapEntry<String, List>> sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    Map<String, List> sortedMap = Map.fromEntries(sortedEntries);
    sortedMap.forEach((key, value) {
      String formattedString = "$key" + "_" + value.join("_");
      formattedList.add(formattedString);
    });
    return formattedList;
  }

  Future<void> generatePDF(int totalQty, int totalAmount) async {
    String date = DateTime.now().toString().split(" ")[0];
    print(date);
    // Create a PDF document
    PdfDocument document = PdfDocument();

    if (matchFundFinalList.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page1 = document.pages.add();
      drawMatchFunds(page1, matchFundFinalList, totalQty, totalAmount);
    }

    if (match1Inning1batter.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page2 = document.pages.add();
      drawInningsDetails(
          page2,
          "Match-1 : 1st Innings (Batting)  ($match1Inning1TotalRun/$match1Inning1TotalWicket)",
          match1Inning1batter,
          match1Inning1baller);

      // Draw match details for inning 2 on the second page
      PdfPage page3 = document.pages.add();
      drawInningsDetails(
          page3,
          "Match-1 : 2nd Innings (Batting)  ($match1Inning2TotalRun/$match1Inning2TotalWicket)",
          match1Inning2batter,
          match1Inning2baller);
    }
    if (match2Inning1batter.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page4 = document.pages.add();
      drawInningsDetails(
          page4,
          "Match-2 : 1st Innings (Batting)  ($match2Inning1TotalRun/$match2Inning1TotalWicket)",
          match2Inning1batter,
          match2Inning1baller);

      // Draw match details for inning 2 on the second page
      PdfPage page5 = document.pages.add();
      drawInningsDetails(
          page5,
          "Match-2 : 2nd Innings (Batting)  ($match2Inning2TotalRun/$match2Inning2TotalWicket)",
          match2Inning2batter,
          match2Inning2baller);
    }
    if (match3Inning1batter.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page6 = document.pages.add();
      drawInningsDetails(
          page6,
          "Match-3 : 1st Innings (Batting)  ($match3Inning1TotalRun/$match3Inning1TotalWicket)",
          match3Inning1batter,
          match3Inning1baller);

      // Draw match details for inning 2 on the second page
      PdfPage page7 = document.pages.add();
      drawInningsDetails(
          page7,
          "Match-3 : 2nd Innings (Batting)  ($match3Inning2TotalRun/$match3Inning2TotalWicket)",
          match3Inning2batter,
          match3Inning2baller);
    }
    if (match4Inning1batter.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page8 = document.pages.add();
      drawInningsDetails(
          page8,
          "Match-4 : 1st Innings (Batting)  ($match4Inning1TotalRun/$match4Inning1TotalWicket)",
          match4Inning1batter,
          match4Inning1baller);

      // Draw match details for inning 2 on the second page
      PdfPage page9 = document.pages.add();
      drawInningsDetails(
          page9,
          "Match-4 : 2nd Innings (Batting)  ($match4Inning2TotalRun/$match4Inning2TotalWicket)",
          match4Inning2batter,
          match4Inning2baller);
    }
    if (match5Inning1batter.isNotEmpty) {
      // Draw match details for inning 1 on the first page
      PdfPage page10 = document.pages.add();
      drawInningsDetails(
          page10,
          "Match-5 : 1st Innings (Batting)  ($match5Inning1TotalRun/$match5Inning1TotalWicket)",
          match5Inning1batter,
          match5Inning1baller);

      // Draw match details for inning 2 on the second page
      PdfPage page11 = document.pages.add();
      drawInningsDetails(
          page11,
          "Match-5 : 2nd Innings (Batting)  ($match5Inning2TotalRun/$match5Inning2TotalWicket)",
          match5Inning2batter,
          match5Inning2baller);
    }

    try {
      // Save the document to the user's downloads directory
      final String downloadsDirectory = '/storage/emulated/0/Download';
      final String filePath = '$downloadsDirectory/match_funds${date}.pdf';

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
            content: Text('PDF has been saved to your downloads directory.'),
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
    } catch (e) {
      // Show a message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
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
  }

  // Helper function to draw match funds
  void drawMatchFunds(
    PdfPage page,
    List<String> fundMap,
    int totalQty,
    int totalAmount,
  ) {
    String date = DateTime.now().toString().split(" ")[0];
    // Draw title for match funds
    page.graphics.drawString(
      'Match Funds  ${date}',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(10, 10, page.getClientSize().width - 20, 20),
    );

    // Draw player details for match funds
    drawPlayerDetails(page, matchFundFinalList, 30, ['Qty', 'Rs'],
        totalQty: totalQty, totalAmount: totalAmount, isMatchFund: true);
  }

  // Helper function to draw player details
  void drawPlayerDetails(
    PdfPage page,
    List<String> playerList,
    double startY,
    List<String> headers, {
    bool isMatchFund = false,
    int totalQty = 0,
    int totalAmount = 0,
  }) {
    // Draw table header
    drawTableHeader(page, startY, headers);

    // Draw player details
    double y = startY + 25;
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

    // Draw player name
    isMatchFund
        ? page.graphics.drawString(
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

  List<Map<String, dynamic>> matches = [];

  void _initializeDatabase() async {
    await _databaseHelper.initDatabase();
    matches = await _databaseHelper.getMatchesByTodayDate(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    setState(() {});

    if (matches.isNotEmpty) {
      setState(() {
        isMatchDataReady = true;
      });
    } else {
      print("No matches found for today's date.");
    }
  }

  List pdfSummary = [];

  void _showPdfSummary() async {
    await _databaseHelper.initDatabase();
    pdfSummary = await _databaseHelper.getPdfSummary(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    if (pdfSummary.isNotEmpty) {
      print(pdfSummary);

      for (int i = 0; i < pdfSummary.length; i++) {
        /// MATCH 1 DETAILS
        if (i == 0) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 1) {
            match1Inning1batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            match1Inning1TotalRun = pdfSummary.elementAt(i)['inning1TotalRun'];
            match1Inning1TotalWicket =
                pdfSummary.elementAt(i)['inning1TotalWicket'];
            match1Inning2TotalRun = pdfSummary.elementAt(i)['inning2TotalRun'];
            match1Inning2TotalWicket =
                pdfSummary.elementAt(i)['inning2TotalWicket'];
            setState(() {});
          }
        }
        if (i == 1) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 1) {
            match1Inning1baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 2) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 1) {
            match1Inning2batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 3) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 1) {
            match1Inning2baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }

        /// MATCH 2 DETAILS
        if (i == 4) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 2) {
            match2Inning1batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            match2Inning1TotalRun = pdfSummary.elementAt(i)['inning1TotalRun'];
            match2Inning1TotalWicket =
                pdfSummary.elementAt(i)['inning1TotalWicket'];
            match2Inning2TotalRun = pdfSummary.elementAt(i)['inning2TotalRun'];
            match2Inning2TotalWicket =
                pdfSummary.elementAt(i)['inning2TotalWicket'];
            setState(() {});
          }
        }
        if (i == 5) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 2) {
            match2Inning1baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 6) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 2) {
            match2Inning2batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 7) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 2) {
            match2Inning2baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }

        /// MATCH 3 DETAILS
        if (i == 8) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 3) {
            match3Inning1batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            match3Inning1TotalRun = pdfSummary.elementAt(i)['inning1TotalRun'];
            match3Inning1TotalWicket =
                pdfSummary.elementAt(i)['inning1TotalWicket'];
            match3Inning2TotalRun = pdfSummary.elementAt(i)['inning2TotalRun'];
            match3Inning2TotalWicket =
                pdfSummary.elementAt(i)['inning2TotalWicket'];
            setState(() {});
          }
        }
        if (i == 9) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 3) {
            match3Inning1baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 10) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 3) {
            match3Inning2batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 11) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 3) {
            match3Inning2baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }

        /// MATCH 4 DETAILS
        if (i == 12) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 4) {
            match4Inning1batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            match4Inning1TotalRun = pdfSummary.elementAt(i)['inning1TotalRun'];
            match4Inning1TotalWicket =
                pdfSummary.elementAt(i)['inning1TotalWicket'];
            match4Inning2TotalRun = pdfSummary.elementAt(i)['inning2TotalRun'];
            match4Inning2TotalWicket =
                pdfSummary.elementAt(i)['inning2TotalWicket'];
            setState(() {});
          }
        }
        if (i == 13) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 4) {
            match4Inning1baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 14) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 4) {
            match4Inning2batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 15) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 4) {
            match4Inning2baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }

        /// MATCH 5 DETAILS
        if (i == 16) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 5) {
            match5Inning1batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            match5Inning1TotalRun = pdfSummary.elementAt(i)['inning1TotalRun'];
            match5Inning1TotalWicket =
                pdfSummary.elementAt(i)['inning1TotalWicket'];
            match5Inning2TotalRun = pdfSummary.elementAt(i)['inning2TotalRun'];
            match5Inning2TotalWicket =
                pdfSummary.elementAt(i)['inning2TotalWicket'];
            setState(() {});
          }
        }
        if (i == 17) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 5) {
            match5Inning1baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 18) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 != 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 5) {
            match5Inning2batter = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
        if (i == 19) {
          if (int.parse(pdfSummary.elementAt(i)['id'].toString()) % 2 == 0 &&
              int.parse(pdfSummary.elementAt(i)['matchesId'].toString()) == 5) {
            match5Inning2baller = pdfSummary
                .elementAt(i)['mapInningBatterBowler']
                .substring(1,
                    pdfSummary.elementAt(i)['mapInningBatterBowler'].length - 1)
                .split(', ');
            setState(() {});
          }
        }
      }
      print('match1Inning1batter length: ${match1Inning1batter.length}');
      print('match1Inning1batter: $match1Inning1batter');
      print('match1Inning1baller: $match1Inning1baller');
      print('match1Inning2batter: $match1Inning2batter');
      print('match1Inning2baller: $match1Inning2baller');
      print(match1Inning1TotalRun);
      print(match1Inning1TotalWicket);
      print(match1Inning2TotalRun);
      print(match1Inning2TotalWicket);

      print('match2Inning1batter: $match2Inning1batter');
      print('match2Inning1baller: $match2Inning1baller');
      print('match2Inning2batter: $match2Inning2batter');
      print('match2Inning2baller: $match2Inning2baller');
      print(match2Inning1TotalRun);
      print(match2Inning1TotalWicket);
      print(match2Inning2TotalRun);
      print(match2Inning2TotalWicket);

      print('match3Inning1batter: $match3Inning1batter');
      print('match3Inning1baller: $match3Inning1baller');
      print('match3Inning2batter: $match3Inning2batter');
      print('match3Inning2baller: $match3Inning2baller');
      print(match3Inning1TotalRun);
      print(match3Inning1TotalWicket);
      print(match3Inning2TotalRun);
      print(match3Inning2TotalWicket);

      print('match4Inning1batter: $match4Inning1batter');
      print('match4Inning1baller: $match4Inning1baller');
      print('match4Inning2batter: $match4Inning2batter');
      print('match4Inning2baller: $match4Inning2baller');
      print(match4Inning1TotalRun);
      print(match4Inning1TotalWicket);
      print(match4Inning2TotalRun);
      print(match4Inning2TotalWicket);

      print('match5Inning1batter: $match5Inning1batter');
      print('match5Inning1baller: $match5Inning1baller');
      print('match5Inning2batter: $match5Inning2batter');
      print('match5Inning2baller: $match5Inning2baller');
      print(match5Inning1TotalRun);
      print(match5Inning1TotalWicket);
      print(match5Inning2TotalRun);
      print(match5Inning2TotalWicket);
    } else {
      print("No pdf found for today's date.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDatabase();
    _showPdfSummary();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsetsOf(context);
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(Constant.wicketLive,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: envoiceColorsExtensions.background)),
          actions: [
            isMatchDataReady
                ? matches[0]['status'] == "2"
                    ? IconButton(
                        onPressed: () async {
                          Map<String, List> matchCollectedFundMap = {};
                          matchFunds = await _databaseHelper.getMatchFundAll(DateFormat('dd-MM-yyyy').format(DateTime.now()));
                          int totalBalls = 0;
                          int totalAmount = 0;
                          if (matchFunds.isNotEmpty) {
                            matchFunds.forEach((player) {
                              String playerName = player['playerName'];
                              int numberOfBall =
                                  int.parse(player['numberOfBall'].toString());
                              int amount =
                                  int.parse(player['amount'].toString());
                              totalBalls = totalBalls + numberOfBall;
                              totalAmount = totalAmount + amount;

                              if (matchCollectedFundMap
                                  .containsKey(playerName)) {
                                matchCollectedFundMap[playerName]?[0] +=
                                    numberOfBall; // Total runs
                                matchCollectedFundMap[playerName]?[1] +=
                                    amount; // Total balls
                              } else {
                                setState(() {});
                                matchCollectedFundMap[playerName] = [
                                  numberOfBall,
                                  amount
                                ]; // [runs, balls, fours, sixes, totalStrikeRate]
                              }
                            });
                            matchFundFinalList =
                                formatData(matchCollectedFundMap);


                          }
                          if (Platform.isAndroid) {
                            final AndroidDeviceInfo androidInfo =
                            await _getAndroidDeviceInfo();
                            if (androidInfo.version.sdkInt < 33) {
                              // If Android version is below 13, request storage permission
                              var status = await Permission.storage.status;
                              if (!status.isGranted) {
                                // Request permission
                                status = await Permission.storage.request();
                                if (!status.isGranted) {
                                  // Permission denied, handle accordingly
                                  return;
                                }
                              }
                            }
                          }
                          try {
                            await generatePDF(totalBalls, totalAmount);
                          } catch (e) {}
                        },
                        icon: Icon(
                          Icons.download,
                          color: theme.envoiceColorsExtensions.background,
                        ),
                      )
                    : SizedBox.shrink()
                : SizedBox.shrink(),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
    );
  }

  Future<AndroidDeviceInfo> _getAndroidDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.androidInfo;
  }
}
