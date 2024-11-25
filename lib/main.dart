import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';

void main() {
  runApp(ImageDownloader());
}

class ImageDownloader extends StatelessWidget {
  const ImageDownloader({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late String activityMessage;
  AppLifecycleState? _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    activityMessage = "Activity Started";
    Constants.logger.w("initState: $activityMessage");
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Constants.logger.w("dispose: Cleaning up resources");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Constants.logger.w("didChangeDependencies called");
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Constants.logger.w("didUpdateWidget: Widget updated");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });

    switch (state) {
      case AppLifecycleState.resumed:
        Constants.logger.w("App is in resumed state");
        break;
      case AppLifecycleState.inactive:
        Constants.logger.w("App is in inactive state");
        break;
      case AppLifecycleState.paused:
        Constants.logger.w("App is in paused state");
        break;
      case AppLifecycleState.detached:
        Constants.logger.w("App is in detached state");
        break;
      default:
        AppLifecycleState.hidden;
    }
    super.didChangeAppLifecycleState(state);
  }

  bool downloading = false;
  String progress = "";
  String filePath = "";
  double downloadPercentage = 0.0;
  String imageUri =
      'https://images.unsplash.com/photo-1616418928117-4e6d19be2df1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  // Download Function
  // Future<void> downloadImage() async {
  //   Constants.logger.w('Download Image!');
  //   try {
  //     // Request storage permission

  //     if (await Permission.manageExternalStorage.request().isGranted) {
  //       Constants.logger.w("Manage storage permission granted");
  //     } else {
  //       Constants.logger.e("Permission denied. Cannot access the directory.");
  //     }
  //     // var status = await Permission.storage.request();
  //     if (await Permission.manageExternalStorage.request().isGranted) {
  //       setState(() {
  //         downloading = true;
  //         progress = "Downloading...";
  //       });

  //       // Get the device's directory to save the image
  //       Directory appDocDir = await getExternalStorageDirectory() ??
  //           await getApplicationDocumentsDirectory();

  //       Constants.logger.w(appDocDir.parent.parent.parent.parent.path);

  //       String loc = '${appDocDir.parent.parent.parent.parent.path}/Fzimages';

  //       Directory newDir = Directory(loc);

  //       String savePath = '';
  //       if (await newDir.exists()) {
  //         // savePath = "$newDir/1.jpg";
  //         Constants.logger.w('dir: $savePath');
  //       } else {
  //         try {
  //           await newDir.create(recursive: true);
  //           // savePath = "$newDir/1.jpg";
  //           Constants.logger.w('New dir created: $newDir');
  //         } catch (e) {
  //           Constants.logger.w(e);
  //         }
  //         savePath = "$loc/1.jpg";
  //         Constants.logger.w('dir: $savePath');
  //       }
  //       // Download the image
  //       var request = await http.get(Uri.parse(imageUri));
  //       if (request.statusCode == 200) {
  //         File file = File(savePath);
  //         await file.writeAsBytes(request.bodyBytes);

  //         setState(() {
  //           downloading = false;
  //           filePath = savePath;
  //           progress = "Download completed!";
  //         });
  //       } else {
  //         setState(() {
  //           downloading = false;
  //           progress =
  //               "Download failed with status code: ${request.statusCode}";
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         progress = "Permission Denied!";
  //       });
  //     }
  //     Constants.logger.w(progress);
  //     Constants.logger.w('Download Function Completed!');
  //   } catch (e) {
  //     Constants.logger.e(e);
  //     setState(() {
  //       downloading = false;
  //       progress = "Download failed!";
  //     });
  //   }
  // }

  // Generate a unique filename with the correct extension
  String generateFilename(String url) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    int randomNumber = Random().nextInt(100000);

    // Extract the file extension from the URL
    String extension = url.split('.').last.toLowerCase();

    // Validate the file extension
    switch (extension) {
      // Compressed formats
      case 'jpg': // Standard compressed format for images
      case 'jpeg': // Alternate for JPG
      case 'png': // Lossless format with transparency
      case 'gif': // Animation or simple graphic format
      case 'bmp': // Bitmap format with no compression
      case 'webp': // Modern high-efficiency image format

      // High-quality formats
      case 'tif': // Tagged Image File Format
      case 'tiff': // Alternate for TIF

      // Vector and special-purpose formats
      case 'svg': // Scalable Vector Graphics
      case 'ico': // Icon file format for apps

      // High-efficiency formats
      case 'heif': // High-Efficiency Image File Format
      case 'heic': // Alternate for HEIF

      // RAW formats for photography
      case 'cr2': // Canon RAW image format
      case 'nef': // Nikon RAW image format
      case 'arw': // Sony RAW image format
      case 'orf': // Olympus RAW image format
      case 'raf': // Fujifilm RAW image format
      case 'dng': // Adobe's Digital Negative RAW format
        break; // Valid extensions
      default:
        extension = 'jpg'; // Set default extension
    }

    return "fzimages_${timestamp}_$randomNumber.$extension";
  }

  // Download Function
  // Download Function
  Future<void> downloadImage() async {
    try {
      // Request storage permission
      if (await Permission.manageExternalStorage.request().isGranted) {
        setState(() {
          downloading = true;
          progress = "Starting download...";
          downloadPercentage = 0.0;
        });

        // Get the device's directory to save the image
        Directory appDocDir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();

        String loc = '${appDocDir.parent.parent.parent.parent.path}/Fzimages';
        Directory newDir = Directory(loc);

        if (!(await newDir.exists())) {
          await newDir.create(recursive: true);
        }

        // Generate a unique file path
        String savePath = "$loc/${generateFilename(imageUri)}";

        // Download the image with progress
        var request = http.Request('GET', Uri.parse(imageUri));
        var response = await request.send();

        if (response.statusCode == 200) {
          int totalBytes = response.contentLength ?? 0;
          int downloadedBytes = 0;

          File file = File(savePath);
          var sink = file.openWrite();

          await response.stream.listen(
            (data) {
              downloadedBytes += data.length;
              sink.add(data);

              setState(() {
                downloadPercentage = downloadedBytes / totalBytes;
                progress =
                    "Downloading: ${(downloadPercentage * 100).toStringAsFixed(1)}%";
              });
            },
            onDone: () async {
              await sink.close();
              setState(() {
                downloading = false;
                filePath = savePath;
                progress = "Download completed! Saved as $savePath";
              });
            },
            onError: (error) {
              setState(() {
                downloading = false;
                progress = "Download failed: $error";
              });
            },
            cancelOnError: true,
          );
        } else {
          setState(() {
            downloading = false;
            progress =
                "Download failed with status code: ${response.statusCode}";
          });
        }
      } else {
        setState(() {
          progress = "Permission Denied!";
        });
      }
    } catch (e) {
      setState(() {
        downloading = false;
        progress = "Download failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUri),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Text(
                progress,
                style: GoogleFonts.josefinSans(
                  color: Colors.white,
                  fontSize: width * .06,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => downloadImage(),
        tooltip: 'Download Image',
        child: const Icon(Icons.download),
      ),
    );
  }
}
