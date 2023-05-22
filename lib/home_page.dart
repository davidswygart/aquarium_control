import 'package:aquarium_control/bluetooth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage>{
  @override
  void initState() {
    BlueToothHandler().scanForEsp32();
    super.initState();
  }

  // create some values
  Color pickerColor = const Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    BlueToothHandler().writeLED(color);
  }

  partyTime() {BlueToothHandler().partyTime();}
  stopParty() {BlueToothHandler().stopParty();}

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,
          labelTypes: const [ColorLabelType.rgb],
        ),
        ElevatedButton(
            onPressed: (){partyTime();},
            child: const Text("Party Time!!")),
        ElevatedButton(
            onPressed: (){stopParty();},
            child: const Text("Stop the party :(")),
      ],
    );
  }


}


