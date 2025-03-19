import 'dart:convert';

import 'package:customer/screen/chats/const.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ChatPages extends StatefulWidget {
  const ChatPages({super.key});

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends State<ChatPages> {
  static const String apiKey = GEMINI_API_KEY;
  late final GenerativeModel _model;
  final List<Content> _history = [];
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.0-pro-exp-02-05',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );
    _initDatabase();
    _loadChatHistory(); // Tải lịch sử khi khởi động
  }

  // Khởi tạo cơ sở dữ liệu SQLite
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'chat_history.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE chat_history (id INTEGER PRIMARY KEY, role TEXT, text TEXT)',
        );
      },
    );
  }

  // Tải lịch sử trò chuyện từ SQLite
  Future<void> _loadChatHistory() async {
    if (_database == null) {
      await _initDatabase();
    }
    final List<Map<String, dynamic>> rows =
        await _database!.query('chat_history');
    setState(() {
      _history.clear();
      _history.addAll(rows.map((row) {
        return Content(
          row['role'] as String,
          [TextPart(row['text'] as String)],
        );
      }));
    });
  }

  // Lưu lịch sử trò chuyện vào SQLite
  Future<void> _saveChatHistory() async {
    if (_database == null) {
      await _initDatabase();
    }
    await _database!.delete('chat_history');
    for (final content in _history) {
      await _database!.insert(
        'chat_history',
        {
          'role': content.role,
          'text': content.parts.whereType<TextPart>().map((p) => p.text).join(),
        },
      );
    }
  }

  // Gửi tin nhắn đến mô hình và lưu lịch sử
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userContent = Content('user', [TextPart(message)]);
    setState(() {
      _history.add(userContent);
      _isLoading = true;
    });
    await _saveChatHistory(); // Lưu lịch sử sau khi thêm tin nhắn
    _scrollToBottom();

    try {
      final response = await _model.generateContent(_history);
      final modelContent = Content('model', [
        TextPart(response.text ?? 'Không có phản hồi'),
      ]);
      setState(() {
        _history.add(modelContent);
        _isLoading = false;
      });
      await _saveChatHistory(); // Lưu lịch sử sau khi nhận phản hồi
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _history.add(Content('model', [TextPart('Lỗi: $e')]));
        _isLoading = false;
      });
      await _saveChatHistory(); // Lưu lịch sử ngay cả khi có lỗi
      _scrollToBottom();
    }

    _textController.clear();
  }

  // Cuộn ListView xuống dưới cùng
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // (Tùy chọn) Xóa lịch sử trò chuyện
  Future<void> _clearChatHistory() async {
    if (_database == null) await _initDatabase();
    await _database!.delete('chat_history');
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Gemini'),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              size: 30,
            ),
            onPressed: _clearChatHistory, // Thêm nút xóa lịch sử
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _history.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _history.length && _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final content = _history[index];
                final text = content.parts
                    .whereType<TextPart>()
                    .map((p) => p.text)
                    .join();
                final isUser = content.role == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '${isUser ? 'Bạn' : 'Trợ lý ảo'}: $text',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color.fromARGB(255, 235, 236, 235),
                      filled: true,
                    ),
                    onSubmitted: (_) => _sendMessage(_textController.text),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
