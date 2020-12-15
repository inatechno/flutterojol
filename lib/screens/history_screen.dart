import 'package:driverojol/helper/helper.dart';
import 'package:driverojol/model/model_history.dart';
import 'package:driverojol/network/network.dart';
import 'package:driverojol/widgets/history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  static String id = "history";
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;

  String iduser;

  String token;
  List<DataHistory> dataHistory;

  String device;
  Network network = Network();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      switch (controller.index) {
        case 0:
          return getHistory("2");
          break;
        case 1:
          return getHistory("4");
          break;
        case 2:
          return getHistory("3");

          break;
        default:
      }
    });
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.orange[900],
        bottom: TabBar(
          controller: controller,
          tabs: [
            Tab(
              text: "Progress",
            ),
            Tab(
              text: "Complete",
            ),
            Tab(
              text: "Cancel",
            ),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(
                dataHistory: dataHistory,
              ),
            ),
            onRefresh: () => getHistory("2"),
          ),
          RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(dataHistory: dataHistory),
            ),
            onRefresh: () => getHistory("4"),
          ),
          RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(dataHistory: dataHistory),
            ),
            onRefresh: () => getHistory("3"),
          ),
        ],
      ),
    );
  }

  getHistory(String status) async {
    return network.getHistory(iduser, status, token, device).then((response) {
      if (response.result == "true") {
        setState(() {
          dataHistory = response.data;
        });
      } else {
        setState(() {
          dataHistory = null;
        });
      }
    });
  }

  Future<void> getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    iduser = sharedPreferences.getString("iduser");
    token = sharedPreferences.getString("token");
    device = await getId();
    getHistory("2");
  }
}
