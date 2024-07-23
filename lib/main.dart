import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to WebP Conversion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageConversionPage(),
    );
  }
}

class ImageConversionPage extends StatefulWidget {
  const ImageConversionPage({super.key});

  @override
  State<ImageConversionPage> createState() => _ImageConversionPageState();
}

class _ImageConversionPageState extends State<ImageConversionPage> {
  File? _image;
  File? _webpImage;
  int? _originalSize;
  int? _webpSize;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _originalSize = _image!.lengthSync();
        _webpImage = null;
        _webpSize = null;
      });
    }
  }

  Future<void> _convertToWebP() async {
    if (_image == null) return;

    final String targetPath = '${_image!.parent.path}/converted.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      _image!.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: 1,
    );

    if (result != null) {
      setState(() {
        _webpImage = File(result.path);
        _webpSize = _webpImage!.lengthSync();
      });
    }
  }

  Future<void> _saveWebPImage() async {
    if (_webpImage == null) return;

    final result = await ImageGallerySaver.saveFile(_webpImage!.path);
    if (result['isSuccess']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WebP image saved to gallery')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to WebP Conversion'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              if (_image != null) ...[
                const Text('Original Image'),
                Image.file(_image!, height: 200),
                Text('Size: ${(_originalSize! / 1024).toStringAsFixed(2)} KB'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _convertToWebP,
                  child: const Text('Convert to WebP'),
                ),
              ],
              if (_webpImage != null) ...[
                const SizedBox(height: 20),
                const Text('WebP Image'),
                Image.file(_webpImage!, height: 200),
                Text('Size: ${(_webpSize! / 1024).toStringAsFixed(2)} KB'),
                Text(
                    'Compression Ratio: ${((_originalSize! - _webpSize!) / _originalSize! * 100).toStringAsFixed(2)}%'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveWebPImage,
                  child: const Text('Save WebP Image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
