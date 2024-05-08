import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:ims/screens/employer/sales/salesreportscreen.dart';
import 'package:intl/intl.dart';

class SelectDateScreen extends StatefulWidget {
  final String reportMode;
  const SelectDateScreen({super.key, required this.reportMode});

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  late double sWidth, sHeight, textSize;
  late DateTime fromDate, toDate;
  late Widget datePickerWidget;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    loadReportMode();
    await() {}
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Date",
          style: TextStyle(
            color: Colors.black,
            fontSize: textSize * 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: textSize),
        width: sWidth,
        height: sHeight,
        child: datePickerWidget,
      ),
    );
  }

  void loadReportMode() async {
    if (widget.reportMode == "Range") {
      datePickerWidget = RangeDatePicker(
        maxDate: DateTime.now(),
        minDate: DateTime.now().subtract(
          const Duration(days: 365),
        ),
        currentDate: DateTime.now(),
        onRangeSelected: (range) {
          fromDate = range.start;
          toDate = range.end;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SalesReportScreen(fromDate: fromDate, toDate: toDate),
            ),
          );
        },
      );
    } else if (widget.reportMode == "Date") {
      datePickerWidget = DatePicker(
        maxDate: DateTime.now(),
        minDate: DateTime.now().subtract(
          const Duration(days: 365),
        ),
        currentDate: DateTime.now(),
        onDateSelected: (date) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SalesReportScreen(fromDate: date, toDate: date),
            ),
          );
        },
      );
    } else if (widget.reportMode == "Month") {
      datePickerWidget = MonthPicker(
        maxDate: DateTime.now(),
        minDate: DateTime.now().subtract(
          const Duration(days: 365),
        ),
        currentDate: DateTime.now(),
        onDateSelected: (month) {
          DateTime firstDateOfMonth = DateTime.utc(month.year, month.month, 1);
          DateTime lastDateOfMonth =
              DateTime.utc(month.year, month.month + 1, 0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SalesReportScreen(
                  fromDate: firstDateOfMonth, toDate: lastDateOfMonth),
            ),
          );
        },
      );
    }
  }
}
