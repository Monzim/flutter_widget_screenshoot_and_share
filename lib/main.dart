import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToolPage(),
    );
  }
}

class ToolPage extends StatefulWidget {
  const ToolPage({Key? key}) : super(key: key);

  @override
  _ToolPageState createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final controller = ScreenshotController();
  final snackBar = SnackBar(
    content: Text('Image Downloaded!'),
    action: SnackBarAction(
      label: 'Okay',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          elevation: 0,
          title: Text('Picture Saving'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Align(alignment: Alignment.center, child: buildImage(context)),
              ElevatedButton(
                onPressed: () async {
                  final image = await controller.capture();
                  if (image == null) return;
                  await saveImage(image);

                  Timer(Duration(seconds: 1), () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                child: Text('Download Full Screen'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final image =
                      await controller.captureFromWidget(buildImage(context));
                  await saveImage(image);
                  Timer(Duration(seconds: 1), () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.redAccent)),
                child: Text('Download Image Only'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final image =
                      await controller.captureFromWidget(buildImage(context));

                  await saveAndShare(image);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.yellow)),
                child: SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Share Image',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future saveAndShare(Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final image = File('${directory.path}/flutter.png');
  final text = 'Image From App';
  image.writeAsBytesSync(bytes);
  await Share.shareFiles([image.path], text: text);
}

Future<String> saveImage(Uint8List bytes) async {
  await [Permission.storage].request();
  final time = DateTime.now()
      .toIso8601String()
      .replaceAll('.', '_')
      .replaceAll(':', '_');

  final nameOfImage = 'screenshoot_$time';
  final result =
      await ImageGallerySaver.saveImage(bytes, name: nameOfImage, quality: 90);
  return result['filePath'];
}

Widget buildImage(context) => Container(
      width: MediaQuery.of(context).size.width * .8,
      height: MediaQuery.of(context).size.height * .5,
      color: Colors.black45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // AspectRatio(
          //   aspectRatio: 0.5,
          //   child: Image.network(
          //     'https://images.pexels.com/photos/2387876/pexels-photo-2387876.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
          //   ),
          // ),
          Image.network(
            'https://images.pexels.com/photos/1517595/pexels-photo-1517595.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // 'https://images.pexels.com/photos/2557527/pexels-photo-2557527.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            width: MediaQuery.of(context).size.width * .8,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            // bottom: 0,

            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.green[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Text(
                'Lest Go here',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
