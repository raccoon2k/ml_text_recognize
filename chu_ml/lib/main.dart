import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:translator/translator.dart';

main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primaryColor: Colors.blue),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  VisionText _visionText;
  String _translated;

  void getImage(String src) async {
    var image = (src == "cam")
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      getText();
    }
  }

  void getText() async {
    if (this._image == null) return;
    FirebaseVisionImage firebaseVision = FirebaseVisionImage.fromFile(_image);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(firebaseVision);
    _visionText = visionText;
    setState(() {
      _visionText = visionText;
    });
  }

  void clean() {
    setState(() {
      this._image = null;
      this._translated = null;
    });
  }

  void translate() async {
    final translator = new GoogleTranslator();
    await translator
        .translate(_visionText.text, to: "vi")
        .then((text) => this._translated = text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bài tập lớn"),
      ),
      body: (_image == null)
          ? Center(child: Text("Ấn vào " "+" " để chọn ảnh"))
          : ListView(
              children: <Widget>[
                Image.file(this._image),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "   Chữ tìm được: ",
                  style: TextStyle(fontSize: 15),
                ),
                Text(_visionText.text),
                SizedBox(
                  height: 20,
                ),
                (_translated == null) ? SizedBox() : Text(_translated),
                RaisedButton(
                  color: Colors.blue,
                  colorBrightness: Brightness.dark,
                  child: Text("Dịch"),
                  onPressed: () => translate(),
                )
              ],
            ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        children: <SpeedDialChild>[
          SpeedDialChild(
            child: Icon(Icons.camera),
            onTap: () => getImage("cam"),
          ),
          SpeedDialChild(
            child: Icon(Icons.photo),
            onTap: () => getImage("photo"),
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            onTap: () => clean(),
          ),
        ],
      ),
    );
  }
}
