import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/colors.dart'; // Import colors.dart
import 'library_card.dart';
import 'package:greenly_app/models/library.dart';
import 'package:greenly_app/services/library_service.dart';

class GreenLibrary extends StatefulWidget {
  const GreenLibrary({super.key});

  @override
  _GreenLibraryState createState() => _GreenLibraryState();
}

class _GreenLibraryState extends State<GreenLibrary> {
  final LibraryService _libraryService = LibraryService();
  // Danh sách các chiến dịch xanh với processId thêm vào
  final List<LibraryDocument> documents = [];

  // Hàm hiển thị dialog lỗi
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error',
            style: TextStyle(fontFamily: 'montserrat', fontWeight: FontWeight.w900)),
        content: Text('Failed to load process: $errorMessage',
            style: const TextStyle(fontFamily: 'montserrat')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: const Text('Close',
                style: TextStyle(fontFamily: 'montserrat', color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _libraryService.fetchAllDocuments().then((fetchedDocuments) {
      setState(() {
        // Cập nhật danh sách documents với dữ liệu từ API
        documents.addAll(fetchedDocuments);
        // In ra danh sách tài liệu đã lấy được
        print('Fetched documents: ${documents.length}');
      });
    }).catchError((error) {
      print('Error fetching documents: $error');
      _showErrorDialog(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Set status bar color
        statusBarIconBrightness: Brightness.light, // Dark icons for status bar
      ),
    );
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Green Library',
          style: TextStyle(
            fontFamily: 'montserrat',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: documents.isEmpty
            ? const Center(
                child: Text(
                  'Không có tài liệu',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return LibraryCard(
                    document: document,
                    // onTap: _showProcessDialog,
                  );
                },
              ),
      ),
    );
  }
}
