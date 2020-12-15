import 'package:driverojol/model/model_history.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class History extends StatelessWidget {
  List<DataHistory> dataHistory;
  History({Key key, this.dataHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dataHistory?.length ?? 0,
      itemBuilder: (context, index) {
        var data = dataHistory[index];
        return GestureDetector(
          onTap: () {
            Toast.show(data.idBooking, context);
            // Navigator.pushNamed(context, DetailHistory.id, arguments: dataHistory);
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              elevation: 7,
              child: Column(
                children: [
                  Container(
                    color: Colors.orange[900],
                    height: 30,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          data?.bookingTanggal ?? "tdk ada tnggl",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 8),
                    child: Row(
                      children: [
                        Icon(Icons.person_pin),
                        Flexible(
                            child: Text(
                          data.bookingFrom,
                          style: TextStyle(fontSize: 12),
                        ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 8, top: 5),
                    child: Row(
                      children: [
                        Icon(Icons.person_pin),
                        Flexible(
                            child: Text(data.bookingTujuan,
                                style: TextStyle(fontSize: 12)))
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black38,
                  ),
                  Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: Text(
                          "BIAYA : " + data?.bookingBiayaUser ?? "GRATIS",
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
