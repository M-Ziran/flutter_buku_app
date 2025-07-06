import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class DetailPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final String link;
  final String image;

  const DetailPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.link,
    required this.image,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? localPath;
  bool isLoading = true;
  int totalPages = 0;
  int currentPage = 0;
  int bookmarkedPage = 0;
  PDFViewController? pdfController;
  final TextEditingController pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    downloadPDF();
  }

  Future<void> downloadPDF() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/buku.pdf");
      await Dio().download(widget.link, file.path);
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Download error: $e");
      setState(() => isLoading = false);
    }
  }

  void openFullScreenPDF() {
    if (localPath == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text("Full Screen PDF")),
          body: PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = widget.link.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Detail Buku")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Hero(
                  tag: widget.image,
                  child: Image.asset(
                    widget.image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 4),
                      Text(widget.subtitle,
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 10),
                      Text(widget.description),
                      SizedBox(height: 16),
                      if (isLoading && hasLink)
                        Center(child: CircularProgressIndicator()),
                      if (!isLoading && localPath != null)
                        Column(
                          children: [
                            SizedBox(
                              height: 520,
                              child: Stack(
                                children: [
                                  PDFView(
                                    filePath: localPath!,
                                    enableSwipe: true,
                                    swipeHorizontal: false,
                                    autoSpacing: true,
                                    pageFling: true,
                                    pageSnap: true,
                                    onRender: (pages) {
                                      setState(() => totalPages = pages ?? 0);
                                    },
                                    onViewCreated: (controller) {
                                      pdfController = controller;
                                    },
                                    onPageChanged: (page, _) {
                                      setState(() => currentPage = page ?? 0);
                                    },
                                  ),
                                  if (totalPages > 0)
                                    Positioned(
                                      right: 8,
                                      top: 10,
                                      bottom: 10,
                                      child: Tooltip(
                                        message: "Navigasi Halaman",
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Slider(
                                            min: 0,
                                            max: (totalPages - 1).toDouble(),
                                            divisions: totalPages > 1
                                                ? totalPages - 1
                                                : 1,
                                            value: currentPage.toDouble().clamp(
                                                0, (totalPages - 1).toDouble()),
                                            onChanged: (value) {
                                              setState(() {
                                                currentPage = value.toInt();
                                                pdfController
                                                    ?.setPage(currentPage);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),

                            // Navigasi Halaman
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: "Halaman Sebelumnya",
                                  icon: Icon(Icons.arrow_back_ios),
                                  onPressed: currentPage > 0
                                      ? () => pdfController
                                          ?.setPage(currentPage - 1)
                                      : null,
                                ),
                                Text(
                                  "Halaman ${currentPage + 1} dari $totalPages",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  tooltip: "Halaman Berikutnya",
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed: currentPage + 1 < totalPages
                                      ? () => pdfController
                                          ?.setPage(currentPage + 1)
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Bookmark, Ke Bookmark, Fullscreen
                            Wrap(
                              spacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    bookmarkedPage = currentPage;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "📌 Halaman ${bookmarkedPage + 1} dibookmark")),
                                    );
                                  },
                                  icon: Icon(Icons.bookmark_add),
                                  label: Text("Bookmark"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    pdfController?.setPage(bookmarkedPage);
                                  },
                                  icon: Icon(Icons.push_pin),
                                  label: Text("Ke Bookmark"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: openFullScreenPDF,
                                  icon: Icon(Icons.fullscreen),
                                  label: Text("Fullscreen"),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            // Masukkan halaman
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: pageController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Hal. ke...",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    final page =
                                        int.tryParse(pageController.text);
                                    if (page != null &&
                                        page > 0 &&
                                        page <= totalPages) {
                                      pdfController?.setPage(page - 1);
                                    }
                                  },
                                  child: Text("Buka"),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.arrow_back),
                  label: Text("Kembali"),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.notifications_active_outlined),
                  label: Text("Notif"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '📘 Judul: ${widget.title}\n🖊️ Subjudul: ${widget.subtitle}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
