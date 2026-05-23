import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  String selectedFormat = "PDF";
  String fileName = "No file selected";
  String? filePath;
  String? savedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File Converter")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // File Name
              Text(fileName, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),

              // Upload Button
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );

                  if (result != null) {
                    setState(() {
                      fileName = result.files.single.name;
                      filePath = result.files.single.path;
                    });
                  }
                },
                child: const Text("Upload File"),
              ),

              const SizedBox(height: 20),

              // Dropdown
              DropdownButton<String>(
                value: selectedFormat,
                isExpanded: true,
                items: ["PDF", "JPG", "PNG"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFormat = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Convert Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () async {
                    if (filePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select an image")),
                      );
                      return;
                    }

                    final pdf = pw.Document();

                    final imageBytes =
                        File(filePath!).readAsBytesSync();

                    final image = pw.MemoryImage(imageBytes);

                    pdf.addPage(
                      pw.Page(
                        build: (context) {
                          return pw.Center(
                              child: pw.Image(image));
                        },
                      ),
                    );

                    // Save to Downloads
                    final directory = await getApplicationDocumentsDirectory();

                    final file = File(
                      "${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.pdf",
                    );

                    await file.writeAsBytes(await pdf.save());

                    setState(() {
                      savedFilePath = file.path;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Saved: ${file.path}")),
                    );
                  },
                  child: const Text("Convert"),
                ),
              ),

              // 🔥 OPEN + SHARE BUTTONS
              if (savedFilePath != null) ...[
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    OpenFile.open(savedFilePath!);
                  },
                  child: const Text("Open PDF"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    Share.shareXFiles([XFile(savedFilePath!)]);
                  },
                  child: const Text("Share PDF"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}