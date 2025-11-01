import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => AnalyticsPageState();
}

class AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  static const CUSTOMER_ISSUES_COLLECTION = 'customer_issues';
  static const IDEA_PITCHED_COLLECTION = 'idea_pitched';
  static const REVIEWS_COLLECTION = 'reviews';

  late List<String> monthLabels;
  int _lastIssueCount = 0;
  int _lastIdeaCount = 0;
  int _lastReviewCount = 0;

  @override
  void initState() {
    super.initState();
    monthLabels = _buildLast12MonthLabels();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      
    }
  }

  @override
  void dispose() {
    
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _controller.forward(from: 0);
  }

  List<String> _buildLast12MonthLabels() {
    final now = DateTime.now();
    final months = <String>[];
    for (int i = 11; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      months.add(_shortMonth(dt.month));
    }
    return months;
  }

  String _shortMonth(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[(m - 1) % 12];
  }

  DateTime? _extractTimestamp(Map<String, dynamic> data) {
    final dynamic t = data['timestamp'] ?? data['createdAt'] ?? data['created_at'];
    if (t == null) return null;
    if (t is Timestamp) return t.toDate();
    if (t is int) return DateTime.fromMillisecondsSinceEpoch(t);
    if (t is String) {
      try {
        return DateTime.parse(t);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  int _monthIndexFor(DateTime dt) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month);
    final diffMonths =
        (dt.year - thisMonthStart.year) * 12 + (dt.month - thisMonthStart.month);
    final index = 11 + diffMonths;
    if (index < 0 || index > 11) return -1;
    return index;
  }

  void _triggerAnimationIfDataChanged(int issues, int ideas, int reviews) {
    if (issues != _lastIssueCount ||
        ideas != _lastIdeaCount ||
        reviews != _lastReviewCount) {
      _lastIssueCount = issues;
      _lastIdeaCount = ideas;
      _lastReviewCount = reviews;
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              Text('User not logged in', style: TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    final uid = _currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Analytics & Insights',
            style: GoogleFonts.lora(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(CUSTOMER_ISSUES_COLLECTION)
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, issuesSnap) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(IDEA_PITCHED_COLLECTION)
                .where('uid', isEqualTo: uid)
                .snapshots(),
            builder: (context, ideasSnap) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(REVIEWS_COLLECTION)
                    .snapshots(),
                builder: (context, reviewsSnap) {
                  if (!issuesSnap.hasData ||
                      !ideasSnap.hasData ||
                      !reviewsSnap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  final issuesDocs = issuesSnap.data!.docs;
                  int totalProblems = issuesDocs.length;
                  List<int> problemsMonthly = List.filled(12, 0);
                  for (final doc in issuesDocs) {
                    final dt = _extractTimestamp(doc.data());
                    if (dt != null) {
                      final idx = _monthIndexFor(dt);
                      if (idx >= 0) problemsMonthly[idx] += 1;
                    }
                  }

                  final ideasDocs = ideasSnap.data!.docs;
                  int totalIdeas = ideasDocs.length;
                  List<int> ideasMonthly = List.filled(12, 0);
                  for (final doc in ideasDocs) {
                    final dt = _extractTimestamp(doc.data());
                    if (dt != null) {
                      final idx = _monthIndexFor(dt);
                      if (idx >= 0) ideasMonthly[idx] += 1;
                    }
                  }

                  // Fetch review docs where current user voted
                  final reviewsDocs = reviewsSnap.data!.docs;
                  Map<String, int> companyVoteCount = {};

                  for (final doc in reviewsDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final votedUsers =
                        List<Map<String, dynamic>>.from(data['votedUsers'] ?? []);
                    final hasVoted = votedUsers.any((v) => v['uid'] == uid);
                    if (hasVoted) {
                      final company = (data['authorName'] ??
                              data['companyName'] ??
                              data['brand'] ??
                              'Unknown')
                          .toString()
                          .trim();
                      final key = company.isEmpty ? 'Unknown' : company;
                      companyVoteCount[key] =
                          (companyVoteCount[key] ?? 0) + 1;
                    }
                  }

                  _triggerAnimationIfDataChanged(
                      totalProblems, totalIdeas, companyVoteCount.length);

                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildOverviewRow(
                            totalProblems, totalIdeas, companyVoteCount),
                        const SizedBox(height: 18),

                        totalProblems == 0
                            ? _buildEmptyBox("No problems reported yet")
                            : _buildAnimatedBarChart(
                                'Problems Reported', problemsMonthly, Colors.white),

                        const SizedBox(height: 10),
                        _buildVotedProductsPieChart(companyVoteCount),

                        totalIdeas == 0
                            ? _buildEmptyBox("No ideas pitched yet")
                            : _buildAnimatedBarChart(
                                'Ideas Pitched', ideasMonthly, Colors.white),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverviewRow(
      int totalProblems, int totalIdeas, Map<String, int> votedCompanies) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallCard('Problems', totalProblems.toString()),
        _smallCard('Ideas', totalIdeas.toString()),
        _smallCard('Voted Products',
            votedCompanies.values.fold(0, (a, b) => a + b).toString()),
      ],
    );
  }

  Widget _smallCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.lora(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.poppins(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18)),
      child: Center(
        child: Text(message, style: GoogleFonts.lora(color: Colors.white70)),
      ),
    );
  }

  Widget _buildAnimatedBarChart(String title, List<int> values, Color color) {
    final data = List.generate(values.length,
        (index) => _ChartData(monthLabels[index], values[index].toDouble()));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animData = data
            .map((d) => _ChartData(d.month, d.value * _controller.value))
            .toList();
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Text(title,
                  style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  backgroundColor: Colors.transparent,
                  primaryXAxis: CategoryAxis(
                    labelStyle:
                        const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle:
                        const TextStyle(color: Colors.white70, fontSize: 10),
                    interval: 1,
                  ),
                  series: <CartesianSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: animData,
                      xValueMapper: (_ChartData data, _) => data.month,
                      yValueMapper: (_ChartData data, _) => data.value,
                      borderRadius: BorderRadius.circular(6),
                      color: color.withOpacity(0.8),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVotedProductsPieChart(Map<String, int> companyVoteCount) {
    if (companyVoteCount.isEmpty) {
      return _buildEmptyBox("No voted products yet");
    }

    final random = Random();
    final predefinedColors = [
      Colors.greenAccent,
      const Color.fromARGB(255, 13, 17, 145),
      Colors.orangeAccent,
      const Color.fromARGB(255, 64, 12, 12),
      Colors.purpleAccent,
      Colors.cyanAccent,
      Colors.redAccent,
      Colors.amberAccent,
      Colors.pinkAccent,
      Colors.limeAccent,
    ];

    final data = <_PieData>[];
    int i = 0;
    companyVoteCount.forEach((company, votes) {
      final color = i < predefinedColors.length
          ? predefinedColors[i]
          : Color.fromARGB(
              255,
              100 + random.nextInt(155),
              100 + random.nextInt(155),
              100 + random.nextInt(155),
            );
      data.add(_PieData(company, votes.toDouble(), color));
      i++;
    });

    final isSingleCompany = companyVoteCount.length == 1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedData = data
            .map((d) => _PieData(d.company, d.value * _controller.value, d.color))
            .toList();

        final totalVotes =
            companyVoteCount.values.fold(0, (sum, val) => sum + val);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Text("Voted Products by Company",
                  style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SfCircularChart(
                      backgroundColor: Colors.transparent,
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                        textStyle:
                            TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<_PieData, String>(
                          dataSource: animatedData,
                          xValueMapper: (_PieData data, _) => data.company,
                          yValueMapper: (_PieData data, _) => data.value,
                          pointColorMapper: (_PieData data, _) => data.color,
                          dataLabelMapper: (_PieData data, _) =>
                              "${data.company} (${data.value.toInt()})",
                          dataLabelSettings: DataLabelSettings(
                            isVisible: !isSingleCompany,
                            labelPosition: ChartDataLabelPosition.outside,
                            connectorLineSettings: const ConnectorLineSettings(
                              type: ConnectorType.curve,
                              color: Colors.white54,
                            ),
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                          innerRadius: '65%',
                          radius: '90%',
                        ),
                      ],
                    ),
                    if (isSingleCompany)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            companyVoteCount.keys.first,
                            style: GoogleFonts.lora(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "(${totalVotes})",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartData {
  final String month;
  final double value;
  _ChartData(this.month, this.value);
}

class _PieData {
  final String company;
  final double value;
  final Color color;
  _PieData(this.company, this.value, this.color);
}
