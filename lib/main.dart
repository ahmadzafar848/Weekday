import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  RegExp dateRegex = RegExp(
    r'^\d{2}/\d{2}/\d{4}$', // Assumes MM/DD/YYYY format
  );
  bool _isDateValid = true;
  String day = "";
  String month = "";
  String year = "";
  String errorText = "";
  bool isButtonDisabled = true;
  int targetDate=-1;
  int monthCode=-1;
  int yearCode=-1;
  int yearQuotient=-1;
  int lastTwoDigitsOfYear=-1;
  int summedValue=-1;
  int remainder=-1;
  String calculatedWeekDay="";

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Day Calculator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: width * 0.8,
              child: TextField(
                controller: _textEditingController,
                onChanged: (text) {
                  setState(() {
                    _isDateValid = _validateDate(text);
                    isButtonDisabled = !_isDateValid;
                  });
                },
                inputFormatters: [
                  _DateInputFormatter(),
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: 'Enter Date (MM/DD/YYYY)',
                  errorText: _isDateValid ? null : errorText,
                ),
              ),
            ),

            SizedBox(height: height*0.03),
            ElevatedButton(
              onPressed: isButtonDisabled
                  ? null
                  : () {
                if (_isDateValid) {
                  printDateInfo(_textEditingController.text);
                } else {
                  if (kDebugMode) {
                    print('Invalid date format');
                  }
                }
              },
              child: const Text('Find Day'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _textEditingController.text = '';
            _isDateValid = true;
            day = '';
            month = '';
            year = '';
            errorText = '';
            isButtonDisabled = true;
          });
        },
        tooltip: 'Reset',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  bool _validateDate(String input) {
    if (!dateRegex.hasMatch(input)) {
      errorText = 'Invalid date format';
      return false;
    }

    final parts = input.split('/');
    if (parts.length != 3) {
      errorText = 'Invalid date format';
      return false;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      errorText = 'Invalid date format';
      return false;
    }

    if (year < 1600 || year > 3100) {
      errorText = 'Year Must be between 1600 to 3100';
      return false;
    }

    if (month < 1 || month > 12) {
      errorText = 'Month Must be between 01 to 12';
      return false;
    }

    if (day < 1 || day > 31) {
      errorText = 'Day Must be between 01 to 31';
      return false;
    }

    // Check for February and leap years
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        // Leap year
        if (day > 29) {
          errorText = 'Invalid day for February in a leap year';
          return false;
        }
      } else {
        // Not a leap year
        if (day > 28) {
          errorText = 'Invalid day for February';
          return false;
        }
      }
    }

    return true;
  }

  void printDateInfo(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      day = parts[0];
      month = parts[1];
      year = parts[2];
      int monthNo=int.parse(month);
      targetDate=convertStringToInt(day);
      monthCode=calculateMonthCode(convertStringToInt(month))!;
      yearCode=calculateYearCode(extractFirstTwoDigits(year));
      lastTwoDigitsOfYear=extractLastTwoDigits(year);
      yearQuotient=calculateQuotient(extractLastTwoDigits(year));
      summedValue=sumValues(targetDate, monthCode, yearCode, yearQuotient, lastTwoDigitsOfYear,isLeapYear(convertStringToInt(year)),monthNo);
      if (kDebugMode) {
        print(summedValue);
      }
      remainder=calculateRemainder(summedValue);
      if (kDebugMode) {
        print(remainder);
      }
      calculatedWeekDay=calculateWeekDay(remainder);
      if (kDebugMode) {
        print(calculatedWeekDay);
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Weekday')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isLeapYear(convertStringToInt(year))?"Is LeapYear=Yes":"Is Leap Year=No"),
                Text(calculatedWeekDay),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is shorter than the old value, check and adjust the formatting
    if (oldValue.text.length > newValue.text.length) {
      // Check if the last character is "/" and remove it along with the previous digit
      if (oldValue.text.endsWith('/') && oldValue.text.length > 1) {
        final newString = oldValue.text.substring(0, oldValue.text.length - 2);
        return TextEditingValue(
          text: newString,
          selection: TextSelection.collapsed(offset: newString.length),
        );
      }
    }

    // If the new value is longer than the old value, apply the usual formatting
    if (newValue.text.length == 2 || newValue.text.length == 5) {
      final newText = '${newValue.text}/';
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}


int convertStringToInt(String value) {
  try {
    return int.parse(value);
  } catch (e) {
    return 0; // or any default value or indication that conversion failed
  }
}

int? calculateMonthCode(int monthNumber){
  if(monthNumber==1 || monthNumber==10){
    return 1;
  }else if(monthNumber==2 || monthNumber==3 || monthNumber==11){
    return 4;
  }else if(monthNumber==4 || monthNumber==7){
    return 0;
  }else if(monthNumber==5){
    return 2;
  }else if(monthNumber==6){
    return 5;
  }else if(monthNumber==8){
    return 3;
  }else if(monthNumber==12 || monthNumber==9){
    return 6;
  }
  return null;
}

String calculateWeekDay(int number){
  if(number==1){
    return "Sunday";
  }else if(number==2){
    return "Monday";
  }else if(number==3){
    return "Tuesday";
  }else if(number==4){
    return "Wednesday";
  }else if(number==5){
    return "Thursday";
  }else if(number==6){
    return "Friday";
  }else if(number==0){
    return "Saturday";
  }
  return "";
}
int extractLastTwoDigits(String yearString) {
  if (yearString.length >= 2) {
    // Take the last two characters of the string and parse them as an integer
    return int.parse(yearString.substring(yearString.length - 2));
  } else {
    // Handle the case when the string is too short
    return 0; // or any default value that makes sense for your application
  }
}
int extractFirstTwoDigits(String yearString) {
  if (yearString.length >= 2) {
    // Take the first two characters of the string and parse them as an integer
    int firstTwoDigits = int.parse(yearString.substring(0, 2));
    return firstTwoDigits;
  } else {
    // Handle the case when the string is too short
    return 0; // or any default value that makes sense for your application
  }
}

int calculateQuotient(int number){
  return number ~/ 4;
}
int calculateYearCode(int number) {
  const pattern = [0, 6, 4, 2];

  if (number >= 15) {
    int index = (number - 15) % 4;
    return pattern[index];
  } else {
    return -1;
  }
}
int sumValues(int targetDate, int monthCode, int yearCode, int yearQuotient, int lastTwoDigitsOfYear,bool isLeapYear,int monthNo) {
  if(isLeapYear==true && (monthNo==1 || monthNo==2) ){
    return (targetDate + monthCode + yearCode + yearQuotient + lastTwoDigitsOfYear)-1;
  }
  return targetDate + monthCode + yearCode + yearQuotient + lastTwoDigitsOfYear;
}
int calculateRemainder(int dividend) {
  int divisor = 7;
  return (dividend % divisor);
}
bool isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 != 0 || (year % 100 == 0 && year % 400 == 0)) {
      return true;
    }
  }
  return false;
}