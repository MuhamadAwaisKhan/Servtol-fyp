//
//
// import 'package:flutter/material.dart';
//
// class OrContinueWithWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Divider(
//           height: 20,
//           thickness: 2,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10.0),
//           child: Text(
//             "Or Continue With",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FlatButton(
//               onPressed: () {
//                 // Action when user continues with option 1
//               },
//               child: Text(
//                 "Option 1",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//             SizedBox(width: 20),
//             FlatButton(
//               onPressed: () {
//                 // Action when user continues with option 2
//               },
//               child: Text(
//                 "Option 2",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Or Continue With Example'),
//       ),
//       body: Center(
//         child: OrContinueWithWidget(),
//       ),
//     ),
//   ));
// }
//
// // import 'package:flutter/material.dart';
// //
// //
// // class DropDownHelper extends StatefulWidget {
// //   const DropDownHelper({Key? key}) : super(key: key);
// //
// //   @override
// //   State<DropDownHelper> createState() => _DropDownHelperState();
// // }
// //
// // class _DropDownHelperState extends State<DropDownHelper> {
// //   List dropDownListData = [
// //     {"title": "BCA", "value": "1"},
// //     {"title": "MCA", "value": "2"},
// //     {"title": "B.Tech", "value": "3"},
// //     {"title": "M.Tech", "value": "4"},
// //   ];
// //
// //   String defaultValue = "";
// //   String secondDropDown = "";
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         centerTitle: true,
// //         title: const Text("DropDown Example"),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(10.0),
// //         child: ListView(children: [
// //           const SizedBox(
// //             height: 20,
// //           ),
// //           InputDecorator(
// //             decoration: InputDecoration(
// //               border:
// //               OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
// //               contentPadding: const EdgeInsets.all(10),
// //             ),
// //             child: DropdownButtonHideUnderline(
// //               child: DropdownButton<String>(
// //                   isDense: true,
// //                   value: defaultValue,
// //                   isExpanded: true,
// //                   menuMaxHeight: 350,
// //                   items: [
// //                     const DropdownMenuItem(
// //                         child: Text(
// //                           "Select Course",
// //                         ),
// //                         value: ""),
// //                     ...dropDownListData.map<DropdownMenuItem<String>>((data) {
// //                       return DropdownMenuItem(
// //                           child: Text(data['title']), value: data['value']);
// //                     }).toList(),
// //                   ],
// //                   onChanged: (value) {
// //                     print("selected Value $value");
// //                     setState(() {
// //                       defaultValue = value!;
// //                     });
// //                   }),
// //             ),
// //           ),
// //           const SizedBox(
// //             height: 20,
// //           ),
// //           InputDecorator(
// //             decoration: InputDecoration(
// //               border:
// //               OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
// //               contentPadding: const EdgeInsets.all(10),
// //             ),
// //             child: DropdownButtonHideUnderline(
// //               child: DropdownButton<String>(
// //                   isDense: true,
// //                   value: secondDropDown,
// //                   isExpanded: true,
// //                   menuMaxHeight: 350,
// //                   items: [
// //                     const DropdownMenuItem(
// //                         child: Text(
// //                           "Select Course",
// //                         ),
// //                         value: ""),
// //                     ...dropDownListData.map<DropdownMenuItem<String>>((data) {
// //                       return DropdownMenuItem(
// //                           child: Text(data['title']), value: data['value']);
// //                     }).toList(),
// //                   ],
// //                   onChanged: (value) {
// //                     print("selected Value $value");
// //                     setState(() {
// //                       secondDropDown = value!;
// //                     });
// //                   }),
// //             ),
// //           ),
// //           const SizedBox(
// //             height: 20,
// //           ),
// //           ElevatedButton(
// //               onPressed: () {
// //                 if (secondDropDown == "") {
// //                   print("Please select a course");
// //                 } else {
// //                   print("user selected course $defaultValue");
// //                 }
// //               },
// //               child: const Text("Submit"))
// //         ]),
// //       ),
// //     );
// //   }
// // }
// // // DropdownButtonHideUnderline(
// // // child: DropdownButton<String>(
// // // isDense: true,
// // // value: _selectedRole,
// // // isExpanded: true,
// // // menuMaxHeight: 200,
// // // items: [
// // // const DropdownMenuItem(
// // // child: Text("Role"),
// // // value: "",
// // // ),
// // // ...dropDownListData.map((data) {
// // // return DropdownMenuItem(
// // // child: Text(data['title']!),
// // // value: data['value'],
// // // );
// // // }).toList(),
// // // ],
// // // onChanged: (value) {
// // // setState(() {
// // // _selectedRole = value!;
// // // });
// // // },
// // // ),
// // // ),
// // // if (_selectedRole == "1") // If provider is selected
// // // Padding(
// // // padding: const EdgeInsets.only(top: 10),
// // // child: TextFormField(
// // // decoration: InputDecoration(
// // // labelText: "Enter Provider Name",
// // // border: OutlineInputBorder(
// // // borderRadius: BorderRadius.circular(10),
// // // ),
// // // contentPadding: EdgeInsets.symmetric(
// // // vertical: 12, horizontal: 10),
// // // ),
// // // ),
// // // ),
// //
// // // (mobileNumber) {
// // // numbercontroller.text = mobileNumber.parseNumber();
// // // }
// // // child: Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         DropdownButtonHideUnderline(
// // //           child: DropdownButton<String>(
// // //             isDense: true,
// // //             value: _selectedRole,
// // //             isExpanded: true,
// // //             menuMaxHeight: 200,
// // //             items: [
// // //               const DropdownMenuItem<String>(
// // //                 child: Text("Role"),
// // //                 value: "",
// // //               ),
// // //               ...dropDownListData.map<DropdownMenuItem<String>>((data) {
// // //                 return DropdownMenuItem<String>(
// // //                   child: Text(data['title']!),
// // //                   value: data['value'],
// // //                 );
// // //               }).toList(),
// // //             ],
// // //             onChanged: (value) {
// // //               setState(() {
// // //                 _selectedRole = value!;
// // //               });
// // //             },
// // //           ),
// // //         ),
// // //
// // //         if (_selectedRole == "1") // If provider is selected
// // //           Padding(
// // //             padding: const EdgeInsets.only(top: 10),
// // //             child: TextFormField(
// // //               decoration: InputDecoration(
// // //                 labelText: "Enter Provider Name",
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(10),
// // //                 ),
// // //                 contentPadding: EdgeInsets.symmetric(
// // //                     vertical: 12, horizontal: 10),
// // //               ),
// // //             ),
// // //           ),
// // //       ],
// // //     ),
// // //   ),
// // // ),
// // // String _selectedRole = "";
// // //
// // // List dropDownListData = [
// // //   {"title": "Provider", "value": "1"},
// // //   {"title": "Customer", "value": "2"},
// // // ];