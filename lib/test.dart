//
//
//
//
//
// class _MyHomePageState extends State<MyHomePage> {
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 buildToggleSwitch('Interior Lamp', toggle1, (value) {
//                   setState(() {
//                     toggle1 = value;
//                     publishMessage('Interior Lamp', toggle1 ? '1' : '0');
//                   });
//                 }),
//                 buildToggleSwitch('Exterior Lamp', toggle2, (value) {
//                   setState(() {
//                     toggle2 = value;
//                     publishMessage('Exterior Lamp', toggle2 ? '1' : '0');
//                   });
//                 }),
//                 buildToggleSwitch('Garage', toggle3, (value) {
//                   setState(() {
//                     toggle3 = value;
//                     publishMessage('Garage', toggle3 ? '1' : '0');
//                   });
//                 }),
//               ],
//             ),
//           ),
//           buildMicInput(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildToggleSwitch(String label, bool toggle, ValueChanged<bool> onChanged) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: toggle ? Colors.greenAccent.shade100.withOpacity(0.2) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 3,
//             blurRadius: 7,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Image.asset(toggle ? 'images/lamp_on.png' : 'images/lamp_off.png', width: 50, height: 50),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 22,
//               ),
//             ),
//             Switch(
//               activeColor: Colors.greenAccent.shade400,
//               value: toggle,
//               onChanged: onChanged,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Positioned buildMicInput() {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 20,
//       child: Container(
//         margin: const EdgeInsets.all(10),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(textSpeech),
//             GestureDetector(
//               onTap: () async {
//                 if (!isListening) {
//                   bool micAvailable = await speechToText.initialize();
//                   if (micAvailable) {
//                     setState(() {
//                       isListening = true;
//                     });
//                     speechToText.listen(
//                       listenFor: const Duration(seconds: 20),
//                       onResult: (result) {
//                         setState(() {
//                           textSpeech = result.recognizedWords;
//                         });
//                       },
//                     );
//                   }
//                 } else {
//                   setState(() {
//                     speechToText.stop();
//                     isListening = false;
//                   });
//                 }
//               },
//               child: CircleAvatar(
//                 child: isListening ? const Icon(Icons.record_voice_over) : const Icon(Icons.mic),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
