import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import '../../config/api_config.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  bool _isTesting = false;
  Map<String, dynamic>? _testResult;

  Future<void> _testApi() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final service = GeminiService(apiKey: ApiConfig.geminiApiKey);
      final result = await service.testApi();
      
      setState(() {
        _testResult = result;
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _testResult = {
          'success': false,
          'error': e.toString(),
        };
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Anahtarı:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ApiConfig.geminiApiKey.substring(0, 20)}...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testApi,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isTesting ? 'Test Ediliyor...' : 'API\'yi Test Et'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 24),
              Card(
                color: _testResult!['success'] == true
                    ? Colors.green[50]
                    : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _testResult!['success'] == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: _testResult!['success'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _testResult!['success'] == true
                                ? 'Test Başarılı!'
                                : 'Test Başarısız',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _testResult!['success'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_testResult!['statusCode'] != null)
                        Text(
                          'HTTP Status: ${_testResult!['statusCode']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (_testResult!['model'] != null)
                        Text(
                          'Model: ${_testResult!['model']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (_testResult!['availableModels'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Mevcut Modeller:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (_testResult!['availableModels'] as List).join('\n'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                      if (_testResult!['body'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Yanıt:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _testResult!['body'].toString().length > 500 
                                ? _testResult!['body'].toString().substring(0, 500)
                                : _testResult!['body'].toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                      if (_testResult!['error'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Hata:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _testResult!['error'].toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red[900],
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

