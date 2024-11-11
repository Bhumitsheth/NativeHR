import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../Models/ChangeLeaveTypeModel.dart';
import '../../Models/leave_type_model.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import '../../utils/imageSelectionWidget.dart';
import '../../utils/responsive_flutter.dart';
import 'leave_request_page.dart';

class LeaveRequestFormPage extends StatefulWidget {
  @override
  State<LeaveRequestFormPage> createState() => _LeaveRequestFormPageState();
}

class _LeaveRequestFormPageState extends State<LeaveRequestFormPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int? userId;
  int? leaveId;
  String? _selectedLeaveType;
  List<LeaveType> _leaveTypes = [];
  String? _halfDayTime;
  bool isHalfDay = false;
  bool isCustomHours = false;

  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  bool? unitHours;
  bool? unitHalf;
  bool? isAttachment;

  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  var picUrl = null;
  List<File> attachmetFileList = [];
  List<File> filesData = [];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    updateUi();
  }

  Future<void> updateUi() async {
    userId = await SharedPrefre.getUserId();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    final url = Uri.parse(URLS.LEAVE_TYPE_LIST);
    final params = {"user_id": userId};
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> leaveTypesData = data['result']['leave_type'];
      setState(() {
        _leaveTypes =
            leaveTypesData.map((item) => LeaveType.fromJson(item)).toList();
      });
    } else {
      snowSnackBar(context, "Failed to load leave types");
    }
  }

  Future<void> _changeLeaveType(int holidayStatusId) async {
    showLoader(context);
    final url = Uri.parse(URLS.CHANGE_LEAVE_TYPE);

    final params = {"holiday_status_id": holidayStatusId};

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(params));

      final Map<String, dynamic> data = jsonDecode(response.body);

      hideLoader(context);
      if (response.statusCode == 200 && data['result']['success'] == true) {
        ChangeLeaveTypeModel result =
        ChangeLeaveTypeModel.fromJson(data['result']);

        setState(() {
          unitHalf = data['result']['request_unit_half'];
          unitHours = data['result']['request_unit_hours'];
          isAttachment = data['result']['is_attachment'];
          isCustomHours = false;
          isHalfDay = false;
        });

        print("unitHalf:$unitHalf");
        print("unitHours:$unitHours");
      } else {
        hideLoader(context);
        snowSnackBar(context, data['result']['message']);
      }
    } catch (e) {
      hideLoader(context);
      snowSnackBar(context, 'Error changing leave type: $e');
    }
  }

  // Function to handle date picking with validation
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? firstDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (isHalfDay) {
            _endDateController.text = _startDateController.text; // Auto-fill end date
          }
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate()) {
      showLoader(context);
      String leaveType = _selectedLeaveType!;
      String startDate = _startDateController.text;
      String endDate = _endDateController.text;
      String reason = _reasonController.text;

      log("startDate:${startDate}");
      log("endDate:${endDate}");

      // Convert _fromTime and _toTime to numeric format
      double? requestHourFrom;
      double? requestHourTo;
      if (isCustomHours && _fromTime != null && _toTime != null) {
        requestHourFrom = _convertToNumericFormat(_fromTime!);
        requestHourTo = _convertToNumericFormat(_toTime!);
      }

      // Prepare attachment data (name and base64)
      List<Map<String, String>> supportedAttachmentIds = [];
      for (var file in attachmetFileList) {
        String fileName = file.path
            .split('/')
            .last; // Get file name
        List<int> fileBytes = await file
            .readAsBytes(); // Convert file to binary
        String base64File = base64Encode(
            fileBytes); // Encode the file in base64

        supportedAttachmentIds.add({
          "name": fileName,
          "datas": base64File,
        });
      }

      final url = Uri.parse(URLS.SUBMIT_LEAVE);
      final params = {
        "user_id": userId,
        "name": reason,
        "holiday_status_id": int.parse(leaveType),
        "request_date_from": startDate,
        "request_date_to": endDate,
        "request_unit_half": isHalfDay,
        "request_unit_hours": isCustomHours,
        // "request_unit_half": unitHalf,
        // "request_unit_hours": unitHours,
        "request_hour_from": requestHourFrom,
        "request_hour_to": requestHourTo,
        "request_date_from_period": _halfDayTime ??  "",
        "leave_type_support_document": isAttachment,
        "supported_attachment_ids": supportedAttachmentIds,
        // Use dynamic attachments
      };

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(params);

      log("params:$params");
      log("body:$body");
      try {
        final response = await http.post(url, headers: headers, body: body);
        final Map<String, dynamic> data = json.decode(response.body);

        hideLoader(context);
        log("daataaaaaa:$data");
        if (response.statusCode == 200 && data['result']['success'] == true) {
          log("dataaaaaa:$data");
          leaveId = data['result']['leave_id'];
          log("leaveId:$leaveId");
        } else {
          hideLoader(context);
          snowSnackBar(context, data['result']['message']);
        }
      } catch (error) {
        hideLoader(context);
        snowSnackBar(context, 'Error submitting leave request: $error');
      }

      _startDateController.clear();
      _endDateController.clear();
      _reasonController.clear();

      Navigator.pop(context, true);
    }
  }


  Future<void> _pickImage() async {
    // Check for storage and camera permissions
    if (await Permission.storage
        .request()
        .isGranted &&
        await Permission.camera
            .request()
            .isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
      }
    } else {
      // If permissions are denied, you can show an alert or a dialog
      snowSnackBar(context, 'Storage or Camera permission is denied.');
    }
  }

  Future<void> _selectTime(BuildContext context,
      Function(TimeOfDay) onTimeSelected) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  // Function to convert TimeOfDay to custom numeric format (0 for 12 AM, 0.5 for 12:30 AM, etc.)
  double _convertToNumericFormat(TimeOfDay time) {
    // Convert hour and minute to the format you need (0.5 for 12:30 AM, etc.)
    return time.hour + (time.minute == 30 ? 0.5 : 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New Time Off',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        ),
        backgroundColor: Colors.orange.withOpacity(0.8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Time Off Type:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: _selectedLeaveType,
                  items: _leaveTypes.map((leaveType) {
                    return DropdownMenuItem<String>(
                      value: leaveType.id.toString(),
                      child: Text(leaveType.displayName),
                    );
                  }).toList(),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  hint: Text('Select Leave Type'),
                  onChanged: (value) {
                    setState(() {
                      _selectedLeaveType = value;
                      final selectedLeave = _leaveTypes.firstWhere(
                              (leaveType) => leaveType.id.toString() == value);
                      log("selectedLeave id:${selectedLeave.id}");
                      _changeLeaveType(selectedLeave.id);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a leave type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text("From:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 5),
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    hintText: 'Start Date',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate(context, _startDateController, null);
                      },
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                ),

                // Text("To:",
                //     style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black87)),
                // SizedBox(height: 5),
                if (!isHalfDay && !isCustomHours) ...[
                  SizedBox(height: 20),
                  Text(
                    "To:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      hintText: 'End Date',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          DateTime? startDate = _startDateController.text.isNotEmpty
                              ? DateFormat('yyyy-MM-dd').parse(_startDateController.text)
                              : null;
                          _selectDate(context, _endDateController, startDate);
                        },
                      ),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an end date';
                      }
                      if (_startDateController.text.isNotEmpty) {
                        DateTime startDate =
                        DateFormat('yyyy-MM-dd').parse(_startDateController.text);
                        DateTime endDate = DateFormat('yyyy-MM-dd').parse(value);
                        if (endDate.isBefore(startDate)) {
                          return 'End date cannot be before start date';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                // TextFormField(
                //   controller: _endDateController,
                //   decoration: InputDecoration(
                //     hintText: 'End Date',
                //     border: OutlineInputBorder(),
                //     suffixIcon: IconButton(
                //       icon: Icon(Icons.calendar_today),
                //       onPressed: () {
                //         DateTime? startDate =
                //         _startDateController.text.isNotEmpty
                //             ? DateFormat('yyyy-MM-dd')
                //             .parse(_startDateController.text)
                //             : null;
                //         _selectDate(context, _endDateController, startDate);
                //       },
                //     ),
                //   ),
                //   readOnly: true,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select an end date';
                //     }
                //     if (_startDateController.text.isNotEmpty) {
                //       DateTime startDate = DateFormat('yyyy-MM-dd')
                //           .parse(_startDateController.text);
                //       DateTime endDate = DateFormat('yyyy-MM-dd').parse(value);
                //       if (endDate.isBefore(startDate)) {
                //         return 'End date cannot be before start date';
                //       }
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(height: 20),
                // Conditionally show checkboxes and time pickers when unitHours == true
                if (unitHours == true || unitHalf == true) ...[
                  Row(
                    children: [
                      if (unitHalf == true) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: isHalfDay,
                              onChanged: (value) {
                                setState(() {
                                  isHalfDay = value!;
                                  if (isHalfDay) {
                                    isCustomHours = false; // Disable custom hours when half-day is selected
                                    _endDateController.text = _startDateController.text; // Auto-fill end date
                                    _halfDayTime = null; // Reset the radio button selection
                                  }
                                  print("isHalfDay:$isHalfDay");
                                  log("_endDateController.text:${_endDateController.text}");
                                });
                              },
                            ),
                            Text('Half Day'),
                          ],
                        ),
                      ],
                      SizedBox(width: 20),
                      if (unitHours == true) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: isCustomHours,
                              onChanged: (value) {
                                setState(() {
                                  isCustomHours = value!;
                                  if (isCustomHours)
                                    isHalfDay =
                                    false; // Disable half-day when custom hours is selected
                                  _endDateController.text =
                                      _startDateController.text; // Auto-fill end date
                                  print("isCustomHours:$isCustomHours");
                                });
                              },
                            ),
                            Text('Custom Hours'),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // Show radio buttons for morning/afternoon if Half Day is selected
                  if (isHalfDay) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Select Half Day Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        // Morning Radio Button
                        Radio<String>(
                          value: 'am',
                          groupValue: _halfDayTime,
                          onChanged: (String? value) {
                            setState(() {
                              _halfDayTime = value;
                              log("Selected Half Day Time: $_halfDayTime");
                            });
                          },
                        ),
                        Text('Morning'),
                        SizedBox(width: 20),
                        // Afternoon Radio Button
                        Radio<String>(
                          value: 'pm',
                          groupValue: _halfDayTime,
                          onChanged: (String? value) {
                            setState(() {
                              _halfDayTime = value;
                              log("Selected Half Day Time: $_halfDayTime");
                            });
                          },
                        ),
                        Text('Afternoon'),
                      ],
                    ),
                  ],

                  // Show time pickers for custom hours
                  if (isCustomHours) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text('From:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                // Padding for a larger button
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), // Rounded corners
                                ),
                                // elevation: 8, // Shadow for a 3D effect
                                // shadowColor: Colors.orangeAccent.withOpacity(0.5), // Shadow color
                              ),
                              onPressed: () =>
                                  _selectTime(context, (pickedTime) {
                                    setState(() {
                                      _fromTime = pickedTime;
                                    });
                                  }),
                              child: Text(
                                _fromTime != null
                                    ? _fromTime!.format(context)
                                    : 'Select Time',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Text('To:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                // Padding for a larger button
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), // Rounded corners
                                ),
                                // elevation: 8, // Shadow for a 3D effect
                                // shadowColor: Colors.orangeAccent.withOpacity(0.5), // Shadow color
                              ),
                              onPressed: () =>
                                  _selectTime(context, (pickedTime) {
                                    setState(() {
                                      _toTime = pickedTime;
                                    });
                                  }),
                              child: Text(
                                _toTime != null
                                    ? _toTime!.format(context)
                                    : 'Select Time',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // SizedBox(height: 20),
                    // if (_fromTime != null && _toTime != null) ...[
                    //   Text('Selected "From" time in binary: ${_convertToNumericFormat(_fromTime!)}'),
                    //   Text('Selected "To" time in binary: ${_convertToNumericFormat(_toTime!)}'),
                    // ],
                  ],
                ],
                SizedBox(height: 20),
                Text("Description:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 5),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                      hintText: 'Add a description',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a reason for the leave';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                if (isAttachment == true) ...[
                  Text(
                    "Supporting Document:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 5),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await ImageSelectionWidget().selectImageFromMedia(
                  //       context,
                  //       isDoc: true,
                  //       onImageUploaded: (url) {
                  //         if (url != null) {
                  //           print(url);
                  //           setState(() {
                  //             picUrl = url.path;
                  //             attachmetFileList.add(File(picUrl));
                  //           });
                  //         }
                  //       },
                  //     );
                  //   },
                  //   // onPressed: _pickImage,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.orange.withOpacity(0.5),
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  //     // Padding for a larger button
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(30), // Rounded corners
                  //     ),
                  //     elevation: 8,
                  //     // Shadow for a 3D effect
                  //     shadowColor:
                  //         Colors.orangeAccent.withOpacity(0.5), // Shadow color
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(Icons.attach_file, color: Colors.white),
                  //       // Icon for the button
                  //       SizedBox(width: 10),
                  //       // Space between the icon and text
                  //       Text(
                  //         "Attach File",
                  //         style: TextStyle(
                  //           fontSize: 16, // Font size
                  //           fontWeight: FontWeight.bold, // Bold text
                  //           color: Colors.blueGrey,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () async {
                      await ImageSelectionWidget().selectImageFromMedia(
                        context,
                        isDoc: true,
                        onImageUploaded: (url) async {
                          if (url != null) {
                            print(url);

                            picUrl = url.path;
                            attachmetFileList.add(File(picUrl));
                            setState(() {});
                            //   _selectedFile = File(url.path);
                            //   List<int> fileBytes = await _selectedFile!.readAsBytes(); // Convert file to binary
                            //   String base64File = base64Encode(fileBytes); // Encode the file in base64
                            //   log("base64File:$base64File");
                            //   filesData.add(File(base64File));
                            //
                            //
                            print("attachmetFileList:${attachmetFileList
                                .length}");
                            // print("filesData:${filesData.length}");
                            // print("filesData[0]path:${filesData[0].path}");
                            // print("filesData[1]path:${filesData[1].path}");
                            // print("filesData[2]path:${filesData[2].path}");

                          }
                        },
                      );
                    },
                    child: Container(
                      height: ResponsiveFlutter.of(context).scale(45),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      margin: EdgeInsets.only(top: 8, right: 10, left: 10),
                      child: Center(
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 30,
                              ),
                              child: Icon(
                                Icons.attach_file_sharp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveFlutter.of(context).scale(10),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Browse ",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print("CLICKED");
                                        /*CallNextScreen(context, SignUpView());*/
                                      },
                                  ),
                                  TextSpan(
                                    text: "file",
                                    style: TextStyle(
                                      // color: Colors.red,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 150,
                    child: attachmetFileList.isEmpty
                        ? Center(
                        child: Text(
                          '',
                          // style:
                          // TextStyle(color: Colors.black),
                        ))
                        : ListView.builder(
                      itemCount: attachmetFileList.length,
                      itemBuilder: (context, index) {
                        File file = attachmetFileList[index];
                        if (index < 0 ||
                            index >= attachmetFileList.length) {
                          // Ensure that the index is within the valid range
                          return Container(); // or any placeholder widget
                        }
                        return Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: ResponsiveFlutter.of(context).scale(40),
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ResponsiveFlutter.of(context).scale(10),
                            ),
                            color: Colors.orange.withOpacity(0.5),
                          ),
                          child: Container(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 8, left: 10, bottom: 9),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      // Adjust the icon as needed
                                      // SvgPicture.asset(
                                      //     AppImages
                                      //         .icDocument),
                                      // SizedBox(
                                      //   width: ResponsiveFlutter
                                      //       .of(context)
                                      //       .scale(Dimens
                                      //       .dimen_10dp),
                                      // ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 4,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                attachmetFileList[index]
                                                    .path
                                                    .split('/')
                                                    .last,
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Text(
                                            //   _formatFileSize(
                                            //       attachmetFileList[
                                            //       index]
                                            //           .lengthSync()),
                                            //   fontWeight:
                                            //   FontWeight
                                            //       .w400,
                                            //   fontSize: 12,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      attachmetFileList.removeAt(index);
                                      filesData.removeAt(index);
                                    });
                                    print(
                                        "DDDD: Item at index $index removed");
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitLeaveRequest,
                    child:
                    Text('Submit', style: TextStyle(color: Colors.black87)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
