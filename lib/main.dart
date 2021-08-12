import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kids_camera_app/ColorHint.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioCache audioCache = AudioCache();
  CameraDescription? camera;
  CameraController? controller;
  bool _isInited = false;
  String? _url;
  XFile? imageFile;
  int select = 0;


  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final cameras = await availableCameras();
      print(cameras);

      controller = CameraController(cameras[select], ResolutionPreset.medium);
      controller!.initialize().then((value) => {
        setState(() {
          _isInited = true;
        })
      });
    });
  }
  @override
  void  dispose() {
    controller!.dispose();
    super.dispose();
  }
  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
        });
      }
    });
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      return null;
    }
  }

  void changeCam(){
    setState(() {
      select==0?select=1:select=0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("D6D2C4"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _isInited
                  ? AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                    child: CameraPreview(controller!),
              )
                  : Container(),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        child: imageFile != null
                            ? Image.file(
                          File(imageFile!.path),
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width * 0.4,
                        )
                            : Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width * 0.4,
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: -10,
                        child: Image(image: AssetImage("assets/12216.png"),
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: MediaQuery.of(context).size.width * 0.45,
                        ),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: (){
                        audioCache.play('sounds/mp3-1.mp3');
                        onTakePictureButtonPressed();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow:[
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(0,0),
                            blurRadius: 20.0,
                            spreadRadius: 5.0
                          )
                        ],
                        color: HexColor("FFF5DA"),
                        shape: BoxShape.circle
                      ),
                      width: 120,
                      height: 120,
                      child: Icon(Icons.camera_alt_sharp,size: 50,),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
