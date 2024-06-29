import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'Model/shown_profile_model.dart';

class ShownProfilePage extends StatefulWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
    );
  }

  ShownProfilePage({Key? key}) : super(key: key);

  @override
  State<ShownProfilePage> createState() => _ShownProfilePageState();
}

class _ShownProfilePageState extends State<ShownProfilePage> {
  File? _image;

  List<Map<String, dynamic>> package = [
    {
      "name": 'Photo',
      "time": '60',
      "price": '90',
    },
    {
      "name": 'Photo',
      "time": '90',
      "price": '110',
    },
    {
      'name': 'Photo',
      'time': '120',
      'price': '120',
    },
    {
      'name': 'Photo',
      'time': '150',
      'price': '140',
    },
    {
      'name': 'Photo',
      'time': '180',
      'price': '160',
    },
  ];

  final _formKey = GlobalKey<FormState>();
  String _igusername = '';
  String _phrase = '';
  Map<String, dynamic>? _package;

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      // final imageTemporary = File(image.path);
      final imageTemporary = await saveFilePeramanetly(image.path);
      setState(() {
        this._image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File> saveFilePeramanetly(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('แจก IG คนเหงา'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                //for popup messeng to user, sample locking page
                SnackBar(
                  content: Text('Hello....'),
                ),
              );
            },
            icon: Icon(Icons.add_alert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.left,
                'รบกวนกรอกข้อมูลให้ครบถ้วน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _igusername = value;
                          });
                          print(_igusername);
                        },
                        decoration: InputDecoration(
                          labelText: 'IG Username',
                          labelStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your message';
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          _igusername = newValue!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _phrase = value;
                          });
                          print(_phrase);
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        decoration: InputDecoration(
                          labelText: 'Your Phrase',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary),
                          counterText: '${_phrase.length.toString()}/50',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your message';
                          }
                          if (value.length > 50) {
                            return 'Long message';
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          _phrase = newValue!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: package[0],
                        decoration: InputDecoration(
                          labelText: 'Package',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        onChanged: (value) {
                          setState(
                            () {
                              _package = value;
                            },
                          );
                          print(_package);
                        },
                        items: package
                            .map(
                              (value) => DropdownMenuItem<Map<String, dynamic>>(
                                value: value,
                                child: Row(
                                  children: [
                                    Text(
                                      value['name'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      value['time'] + ' Secondminute',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'THB ' + value['price'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาเลือก Package';
                          }
                        },
                        onSaved: (newValue) {},
                      ),
                    ),
                  ],
                ),
              ),
              // DropdownButton widget
              SizedBox(
                height: 10,
              ),
              Text(
                'กรุณาเลือกรูปภาพ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(
                height: 30,
              ),

              CustomButtom(
                title: 'Pick from Gallery',
                icon: Icons.image_outlined,
                onClick: () => getImage(ImageSource.gallery),
              ),
              SizedBox(
                height: 30,
              ),
              _image != null
                  ? Image.file(
                      _image!,
                      width: 400,
                      height: 400,
                      fit: BoxFit.cover,
                    )
                  : Image.asset('images/logo.png'),
              SizedBox(
                height: 10,
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // final ShownProfileController controller =
                    //     Get.put(ShownProfileController());

                    // controller.formData.igusername = _igusername;
                    // controller.formData.phrase = _phrase;
                    // // controller.formData.package = _package;
                    // controller.formData.image = _image;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShownProfileRequestPage(
                          detail: ShownProfileDetail(
                            igusername: _igusername,
                            phrase: _phrase,
                            package: _package,
                            image: _image,
                          ),
                        ),
                      ),
                    );
                    // controller.onSubmit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  // primary: Colors.blue,
                  // onPrimary: Colors.white,
                  padding: EdgeInsets.fromLTRB(120, 10, 120, 10),
                  textStyle: TextStyle(
                      fontSize: 25, // Text size
                      fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Button border radius
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget CustomButtom({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return Container(
    width: 280,
    child: ElevatedButton(
      onPressed: onClick,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(
            width: 20,
          ),
          Text(title),
        ],
      ),
    ),
  );
}

class ShownProfileRequestPage extends StatelessWidget {
  final ShownProfileDetail detail;

  const ShownProfileRequestPage({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        title: Text('Show IG Request'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Submit Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              detail.igusername,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              detail.phrase,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            // Text(
            //   detail.package,
            //   style: TextStyle(
            //     fontSize: 20,
            //     color: Theme.of(context).colorScheme.onBackground,
            //   ),
            // ),
            // Image(image: image),
          ],
        ),
      ),
    );
  }
}

class ShownProfileDetail {
  final String igusername;
  final String phrase;
  final Map<String, dynamic>? package;
  final File? image;

  ShownProfileDetail({
    required this.igusername,
    required this.phrase,
    required this.package,
    required this.image,
  });
}
