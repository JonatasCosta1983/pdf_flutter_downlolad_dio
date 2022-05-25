import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/Home/HomeController/PermissaoController.dart';
import 'package:dio/dio.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path_provider/path_provider.dart' as p;

class HomePager extends StatefulWidget {
  const HomePager({Key key}) : super(key: key);

  @override
  _HomePagerState createState() => _HomePagerState();
}

class _HomePagerState extends State<HomePager> {
  final permisionController = PermissaoController();
  get funcionPermision => permisionController.permision();

  String _fileFullPath;
  String progress;
  Dio dio;

  final urlPdf =
      "https://www.scielo.cl/pdf/ijmorphol/v40n1/0717-9502-ijmorphol-40-01-98.pdf";

  @override
  void initState() {
    dio = Dio();
    super.initState();
  }

  Future<List<Directory>> _getExternalStoragePath() {
    return p.getExternalStorageDirectories(type: p.StorageDirectory.documents);
  }

  Future _downloadAndSaveFileToStorage(
      BuildContext context, String urlPath, String fileName) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Download file");

    try {
      await pr.show();
      final dirList = await _getExternalStoragePath();
      final path = dirList[0].path;
      final file = File('$path/$fileName');
      await dio.download(urlPath, file.path, onReceiveProgress: (rec, total) {
        setState(() {
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
          print(progress);
          pr.update(message: "Por favor aguarde: $progress");
        });
      });
      pr.hide();
      _fileFullPath = file.path;
    } catch (e) {
      print(e);
    }
    setState(() {
      print('Caminho que foi salvo o pdf: $_fileFullPath');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pdf Tester'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              permisionController.permision();
              _downloadAndSaveFileToStorage(context, urlPdf, "documento.pdf");
            },
            child: Text('Salvar pdf '),
          ),
        ));
  }
}
