import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

import 'common_method.dart';


class ImageSelectionWidget {
  File? imageFile;
  Function(File?)? onFileSelected;
  Function(File)? onImageUploaded;
  Function(int)? onUpdateStatus;
  bool? isDoc = false;

  Future<bool?> selectImageFromMedia(BuildContext context,
      {Function(File)? onImageUploaded,
        Function(int)? onUpdateStatus,
        bool? isDoc = false}) async {
    this.isDoc = isDoc;
    this.onFileSelected = onFileSelected;
    this.onImageUploaded = onImageUploaded;
    this.onUpdateStatus = onUpdateStatus;

    // Map<Permission, PermissionStatus> permissionStatuses =
    //     await [Permission.camera, Permission.storage].request();
    //
    // if (permissionStatuses[Permission.camera] != PermissionStatus.granted) {
    //   if (permissionStatuses[Permission.camera] !=
    //       PermissionStatus.permanentlyDenied) {
    //     printLog("Camera Permission Is Not Permanent given");
    //   } else {}
    //   return false;
    // } else if (permissionStatuses[Permission.storage] !=
    //     PermissionStatus.granted) {
    //   printLog("Storage Permission Is Not given");
    //   if (permissionStatuses[Permission.storage] !=
    //       PermissionStatus.permanentlyDenied) {
    //   } else {}
    //   return false;
    // } else {
    //   _showPicker(context);
    //   return true;
    // }

    _getStoragePermission().then((value) {
      print("======PERM====${value}");
      if (value == true) {
        _showPicker(context);
      }
        // else{
      //   _getStoragePermission();
      // }
      // else {
      //   print("======PERMELSE====${value}");
      // _getStoragePermission();
      // }
    });
    return true;
  }


  Future<bool> _getStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo? android;
    if (Platform.isAndroid) {
      android = await plugin.androidInfo;

      if (android != null) {
        print("SDK--->>");
        print(android.version.sdkInt!);
      }
    }

    bool permissionGranted = false;

    if (android != null && android.version.sdkInt! >= 33) {
      print("INSIDE33");
      var permission = Permission.photos.request();
      if (await permission.isGranted) {
        print("INSIDE33ANDGRANTED");

        var cam = Permission.camera.request();
        if (await cam.isGranted) {
          permissionGranted = true;
        } else if (await cam.isPermanentlyDenied) {
          await openAppSettings();
        } else if (await cam.isDenied) {
          permissionGranted = false;
        }
      } else if (await permission.isDenied) {
        print("INSIDE33ANDDEN");
        permissionGranted = false;
      } else if (await permission.isPermanentlyDenied) {
        print("INSIDE33ANDPERDEN");
        await openAppSettings();
      }
    }else if(Platform.isIOS){
      print("INSIDE33ANDGRANTED---isIOS");

      var permission = Permission.photos.request();
      if (await permission.isGranted) {
        print("INSIDE33ANDGRANTED");

        var cam = Permission.camera.request();
        if (await cam.isGranted) {
          permissionGranted = true;
        } else if (await cam.isPermanentlyDenied) {
          await openAppSettings();
        } else if (await cam.isDenied) {
          permissionGranted = false;
          await Permission.camera.request();
        }
      } else if (await permission.isDenied) {
        print("INSIDE33ANDDEN");
        permissionGranted = false;
        await Permission.camera.request();

      } else if (await permission.isPermanentlyDenied) {
        print("INSIDE33ANDPERDEN");
        await openAppSettings();
      }
    } else {
      var permission = Permission.storage.request();
      print("INSIDEELSE");

      if (await permission.isGranted) {
        var cam = Permission.camera.request();
        if (await cam.isGranted) {
          permissionGranted = true;
        } else if (await cam.isPermanentlyDenied) {
          await openAppSettings();
        } else if (await cam.isDenied) {
          permissionGranted = false;
        }
      } else if (await permission.isPermanentlyDenied) {
        await openAppSettings();
      } else if (await permission.isDenied) {
        permissionGranted = false;
      }

      // if (await Permission.storage.request().isGranted) {
      //   permissionGranted = true;
      // } else if (await Permission.camera.request().isDenied) {
      //   print("INDENIED");
      //   permissionGranted = false;
      // } else if (await Permission.storage.request().isPermanentlyDenied) {
      //   await openAppSettings();
      // }
    }
    return permissionGranted;
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery(bc);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () async {
                      var status = await Permission.camera.status;
                      print('HERE$status');
                      if (!status.isGranted) {
                        await openAppSettings();
                        // await Permission.camera.request();
                      } else {
                        _imgFromCameraProfile(bc);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  isDoc!
                      ? ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('Document'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            allowMultiple: false);

                        if (result != null &&
                            result.files.single.path != null) {
                          if (p.extension(result.files.single.path!) ==
                              ".pdf") {
                            File file = File(result.files.single.path!);

                            bool isGreaterThan5mb =
                            await checkImageSize(file.path);
                            print("------isGreaterThan5mb${isGreaterThan5mb}");
                            if (isGreaterThan5mb) {
                              print("------INIF");

                              onUpdateStatus!(-1);
                            } else {
                              // ImageUploadServiceOnS3()
                              //     .uploadFile(file)
                              //     .then((value) {
                              //   if (value != null && value.isNotEmpty) {
                              //     print("DocURL $value");
                              //     onImageUploaded!(value);
                              //     if (onUpdateStatus != null) {
                              //       onUpdateStatus!(2);
                              //     }
                              //   }
                              // });
                              onImageUploaded!(file);
                              print(file);
                            }
                          } else {
                            final snackBar = SnackBar(
                              content: Text(
                                'This format file is not supported. Select only pdf file.',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blueGrey.shade200,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        } else {
                          final snackBar = SnackBar(
                            content: Text(
                              'This format file is not supported. Select only pdf file.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor:Colors.blueGrey.shade200,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBar);
                        }
                      })
                      : Container(),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCameraProfile(BuildContext bc) async {
    try {
      print("_imgFromCamera Called 111");

      var temp = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 1920,
          maxWidth: 1024);
      print("_imgFromCamera Called 222");
      imageFile = File(temp!.path);
      print('IMAGEFILE-->>$imageFile');
      if (imageFile != null) {
        imageFile = await File(imageFile!.path);
        print('DATA$imageFile');
      } else {
        print("NULL12345678");
      }

      bool isGreaterThan5mb = await checkImageSize(temp.path);
      if (isGreaterThan5mb) {
        onUpdateStatus!(-1);
      } else {
        if (onImageUploaded != null) {
          print("ImagePath1 ${imageFile!.path}");
          if (onUpdateStatus != null) {
            onUpdateStatus!(1);
          }
          // ImageUploadServiceOnS3()
          //     .uploadFile(File(imageFile!.path))
          //     .then((value) {
          //   if (value != null && value.isNotEmpty) {
          //     print("ImageURL $value");
          //     onImageUploaded!(value);
          //     if (onUpdateStatus != null) {
          //       onUpdateStatus!(2);
          //     }
          //   }
          // });
          onImageUploaded!(imageFile!);
        } else {
          print("On File Selected Null");
        }
      }
    } catch (e) {
      print("Error ${e.toString()}");
    }
  }

  _imgFromCamera(BuildContext context, String imagePath) async {
    try {
      print("_imgFromCamera Called");

      // imageFile = await ImagePicker.pickImage(
      //   source: ImageSource.camera
      // );
      //
      // if(imageFile!=null) {
      //   imageFile = await _cropImage(imageFile!.path);
      // }

      if (onImageUploaded != null) {
        print("ImagePath1 $imagePath");
        if (onUpdateStatus != null) {
          onUpdateStatus!(1);
        }
        // ImageUploadServiceOnS3().uploadFile(File(imagePath)).then((value) {
        //   if (value != null && value.isNotEmpty) {
        //     print("ImageURL $value");
        //     onImageUploaded!(value);
        //     if (onUpdateStatus != null) {
        //       onUpdateStatus!(2);
        //     }
        //   }
        // });
      } else {
        print("On File Selected Null");
      }
    } catch (e) {
      print("Error ${e.toString()}");
    }
  }

  _imgFromGallery(BuildContext bc) async {
    var temp = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    imageFile = File(temp!.path);

    print(imageFile.toString());
    if (imageFile != null) {
      imageFile = await File(imageFile!.path);
    }

    bool isGreaterThan5mb = await checkImageSize(temp.path);
    if (isGreaterThan5mb) {
      onUpdateStatus!(-1);
    } else {
      if (onImageUploaded != null) {
        if (imageFile != null) {
          print("ImagePath ${imageFile!}");
        } else {
          print("NUlL");
        }
        if (onUpdateStatus != null) {
          onUpdateStatus!(1);
        }
        // ImageUploadServiceOnS3()
        //     .uploadFile(File(imageFile!.path))
        //     .then((value) {
        //   if (value != null && value.isNotEmpty) {
        //     onImageUploaded!(value);
        //     if (onUpdateStatus != null) {
        //       onUpdateStatus!(2);
        //     }
        //   }
        // });
        onImageUploaded!(imageFile!);
      } else {
        print("On File Selected Null");
      }
    }
  }
}