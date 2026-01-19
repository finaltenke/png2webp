import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const Png2WebpApp());
}

// Localization
class L10n {
  static Locale? _locale;

  static void init(BuildContext context) {
    _locale = Localizations.localeOf(context);
  }

  static bool get isZh => _locale?.languageCode == 'zh';

  static String get quality => isZh ? '品質：' : 'Quality:';
  static String get converting => isZh ? '轉換中...' : 'Converting...';
  static String get dropToConvert => isZh ? '放開以轉換' : 'Drop to convert';
  static String get dragPngHere => isZh ? '拖放 PNG 檔案到這裡' : 'Drag & drop PNG files here';
  static String get outputSameLocation => isZh ? '輸出檔案會儲存在相同位置' : 'Output saved to same location';
  static String get results => isZh ? '轉換結果' : 'Results';
  static String get clear => isZh ? '清除' : 'Clear';
  static String get fileNotFound => isZh ? '檔案不存在' : 'File not found';
  static String get pngOnly => isZh ? '只支援 PNG 檔案' : 'Only PNG files supported';
  static String get success => isZh ? '轉換成功！' : 'Conversion successful!';
  static String conversionFailed(String err) => isZh ? '轉換失敗：$err' : 'Conversion failed: $err';
  static String error(String err) => isZh ? '發生錯誤：$err' : 'Error: $err';
  static String get cwebpNotFound => isZh ? '找不到 cwebp，請先執行：brew install webp' : 'cwebp not found. Please run: brew install webp';
  static String get showInFinder => isZh ? '在 Finder 中顯示' : 'Show in Finder';
  static String qualityLabel(int q) => isZh ? '品質: $q' : 'Quality: $q';
}

class Png2WebpApp extends StatelessWidget {
  const Png2WebpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PNG to WebP Converter',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh', 'TW'),
        Locale('zh', 'HK'),
        Locale('zh', 'CN'),
        Locale('zh'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
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
  bool _isDragging = false;
  double _quality = 80;
  final List<ConversionResult> _results = [];
  bool _isConverting = false;

  Future<void> _convertFile(String inputPath) async {
    debugPrint('[PNG2WebP] ========================================');
    debugPrint('[PNG2WebP] Processing: $inputPath');

    final file = File(inputPath);
    if (!await file.exists()) {
      debugPrint('[PNG2WebP] Error: File not found');
      _addResult(ConversionResult(
        inputPath: inputPath,
        success: false,
        message: L10n.fileNotFound,
      ));
      return;
    }

    final ext = p.extension(inputPath).toLowerCase();
    debugPrint('[PNG2WebP] Extension: $ext');
    if (ext != '.png') {
      debugPrint('[PNG2WebP] Error: Not a PNG file');
      _addResult(ConversionResult(
        inputPath: inputPath,
        success: false,
        message: L10n.pngOnly,
      ));
      return;
    }

    final outputPath = '${p.withoutExtension(inputPath)}.webp';
    debugPrint('[PNG2WebP] Output: $outputPath');
    debugPrint('[PNG2WebP] Quality: ${_quality.toInt()}');

    final command = 'cwebp';
    final args = ['-q', _quality.toInt().toString(), inputPath, '-o', outputPath];
    debugPrint('[PNG2WebP] Command: $command ${args.join(' ')}');

    try {
      final result = await Process.run(command, args);

      debugPrint('[PNG2WebP] Exit code: ${result.exitCode}');
      debugPrint('[PNG2WebP] stdout: ${result.stdout}');
      debugPrint('[PNG2WebP] stderr: ${result.stderr}');

      if (result.exitCode == 0) {
        final inputSize = await file.length();
        final outputFile = File(outputPath);
        final outputSize = await outputFile.length();
        final ratio = (outputSize / inputSize * 100).toStringAsFixed(1);

        debugPrint('[PNG2WebP] Success! $inputSize bytes → $outputSize bytes ($ratio%)');

        _addResult(ConversionResult(
          inputPath: inputPath,
          outputPath: outputPath,
          success: true,
          message: L10n.success,
          inputSize: inputSize,
          outputSize: outputSize,
          compressionRatio: ratio,
          quality: _quality.toInt(),
        ));
      } else {
        debugPrint('[PNG2WebP] Failed: ${result.stderr}');
        _addResult(ConversionResult(
          inputPath: inputPath,
          success: false,
          message: L10n.conversionFailed(result.stderr.toString()),
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('[PNG2WebP] Exception: $e');
      debugPrint('[PNG2WebP] StackTrace: $stackTrace');

      String errorMessage = L10n.error(e.toString());
      if (e.toString().contains('cwebp')) {
        errorMessage = L10n.cwebpNotFound;
      }
      _addResult(ConversionResult(
        inputPath: inputPath,
        success: false,
        message: errorMessage,
      ));
    }
  }

  void _addResult(ConversionResult result) {
    setState(() {
      _results.insert(0, result);
    });
  }

  Future<void> _handleDrop(List<String> paths) async {
    setState(() {
      _isConverting = true;
    });

    for (final path in paths) {
      await _convertFile(path);
    }

    setState(() {
      _isConverting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    L10n.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PNG to WebP Converter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(L10n.quality),
                    Expanded(
                      child: Slider(
                        value: _quality,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: _quality.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _quality = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_quality.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: DropTarget(
                onDragEntered: (_) => setState(() => _isDragging = true),
                onDragExited: (_) => setState(() => _isDragging = false),
                onDragDone: (details) {
                  setState(() => _isDragging = false);
                  final paths = details.files.map((f) => f.path).toList();
                  _handleDrop(paths);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isDragging
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDragging
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: _isDragging ? 3 : 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Center(
                    child: _isConverting
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(L10n.converting),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isDragging ? Icons.file_download : Icons.image,
                                size: 64,
                                color: _isDragging
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isDragging ? L10n.dropToConvert : L10n.dragPngHere,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _isDragging
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                L10n.outputSameLocation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    L10n.results,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _results.clear()),
                    child: Text(L10n.clear),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ResultCard(result: result);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ConversionResult {
  final String inputPath;
  final String? outputPath;
  final bool success;
  final String message;
  final int? inputSize;
  final int? outputSize;
  final String? compressionRatio;
  final int? quality;

  ConversionResult({
    required this.inputPath,
    this.outputPath,
    required this.success,
    required this.message,
    this.inputSize,
    this.outputSize,
    this.compressionRatio,
    this.quality,
  });
}

class ResultCard extends StatelessWidget {
  final ConversionResult result;

  const ResultCard({super.key, required this.result});

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.basename(result.inputPath),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (result.success && result.inputSize != null && result.outputSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatSize(result.inputSize!)} → ${_formatSize(result.outputSize!)} (${result.compressionRatio}%) | ${L10n.qualityLabel(result.quality!)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (result.success)
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: L10n.showInFinder,
                onPressed: () {
                  Process.run('open', ['-R', result.outputPath!]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
