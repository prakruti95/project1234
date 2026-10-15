import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants.dart';
import 'categoryDB.dart';
import 'categoryDBModel.dart';

class Category extends StatefulWidget {
  var index;
  var category_name;

  Category({this.index, this.category_name});

  @override
  CategoryPage createState() => CategoryPage();
}

class CategoryPage extends State<Category> {
  var size;
  var category_id;
  var category_nm;

  CategoryPage({this.category_id, this.category_nm});

  late Future<List<dynamic>> categoryFuture;

  @override
  void initState() {
    super.initState();
    categoryFuture = viewCategoryItemsData();
  }

  Future<List<dynamic>> viewCategoryItemsData() async {
    final response = await http.get(
      Uri.parse(
        "https://shivaay.us.cc/Project/category_images_view.php?data=${widget.index}",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load category images');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid response from server');
    }

    return decoded;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category_name}".toUpperCase(),
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
        ),
        backgroundColor: kGold,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: categoryFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load images: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No images found'),
            );
          }

          return Items(
            list_: snapshot.data!,
            size_: size,
          );
        },
      ),
    );
  }
}

class Items extends StatefulWidget {
  final List<dynamic> list_;
  final dynamic size_;

  Items({required this.list_, this.size_});

  @override
  State<Items> createState() {
    return ItemsState(list: list_, size: size_);
  }
}

class ItemsState extends State<Items> {
  final List<dynamic> list;
  final dynamic size;

  DB db = DB();

  String savePath = "";

  ItemsState({required this.list, this.size});

  @override
  void initState() {
    super.initState();
    db = DB();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 2,
      children: List.generate(list.length, (index) {
        final imageUrl =
        (list[index]['category_img'] ?? '').toString().trim();

        return Card(
          elevation: 3,
          shadowColor: Colors.amber,
          color: Colors.blueGrey,
          child: Column(
            children: [
              imageUrl.isEmpty
                  ? SizedBox(
                height: size.height * 17.4 / 100,
                width: double.infinity,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                  ),
                ),
              )
                  : Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: size.height * 17.4 / 100,
                    width: double.infinity,
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 40,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return SizedBox(
                    height: size.height * 17.4 / 100,
                    width: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                height: size.height * 17.4 / 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Container(
                height: size.height * 6 / 120,
                child: Row(
                  children: [
                    SizedBox(width: size.width * 10 / 100),

                    InkWell(
                      onTap: () {
                        if (imageUrl.isNotEmpty) {
                          _share(imageUrl);
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Image URL not found',
                          );
                        }
                      },
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: size.width * 17 / 95),

                    InkWell(
                      onTap: () {
                        if (imageUrl.isNotEmpty) {
                          _save(imageUrl);
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Image URL not found',
                          );
                        }
                      },
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Share image directly
  Future<void> _share(String imageUrl) async {
    try {
      final uri = Uri.tryParse(imageUrl);

      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        Fluttertoast.showToast(msg: 'Invalid image URL');
        return;
      }

      final response = await http.get(uri);

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        Fluttertoast.showToast(msg: 'Failed to download image');
        return;
      }

      final temp = await getTemporaryDirectory();

      String fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'shared_image.jpg';

      if (!fileName.contains('.')) {
        fileName = 'shared_image.jpg';
      }

      final file = File('${temp.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Share error: $e');
      debugPrintStack(stackTrace: stackTrace);

      Fluttertoast.showToast(msg: 'Unable to share image');
    }
  }

  // Download image to gallery
  Future<void> _save(String imageUrl) async {
    if (imageUrl.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Image URL not found');
      return;
    }

    final uri = Uri.tryParse(imageUrl);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      Fluttertoast.showToast(msg: 'Invalid image URL');
      return;
    }

    bool dialogShown = false;

    try {
      String fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'image.jpg';

      if (!fileName.contains('.')) {
        fileName = 'image.jpg';
      }

      // Display progress dialog
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return const PopScope(
            canPop: false,
            child: SimpleDialog(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text('Downloading...'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

      dialogShown = true;

      // Download the image
      final response = await Dio().get<List<int>>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final bytes = response.data;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Downloaded image is empty');
      }

      // Save the image to the device gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        name: fileName,
      );

      debugPrint('Gallery save result: $result');

      final success =
          result is Map && result['isSuccess'] == true;

      if (!success) {
        throw Exception('Gallery save failed: $result');
      }

      // Store the saved image path in your database
      savePath = 'Pictures/$fileName';

      await db.insertData(
        CategoryModel(url: savePath),
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Image Downloaded Successfully',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Download error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Download failed. Check permissions and try again.',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      // Close the progress dialog even if download fails
      if (dialogShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}