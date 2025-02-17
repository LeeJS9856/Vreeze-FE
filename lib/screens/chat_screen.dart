import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../widgets/sidebar_widget.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> messages = [];
  final Record _record = Record();
  bool _isRecording = false;

  // 텍스트 메시지 전송 함수
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({"user": _messageController.text});
        messages.add({"bot": "Hello world"});
      });
      _messageController.clear();
    }
  }

  // 음성 녹음 토글 함수
  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      // 녹음 시작 전에 권한 확인
      bool hasPermission = await _record.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('녹음 권한이 필요합니다.')),
        );
        return;
      }
      // 녹음 시작 (AAC 대신 AAC Low Complexity 사용)
      await _record.start(
        encoder: AudioEncoder.aacLc, // 수정된 부분
        bitRate: 128000,
        samplingRate: 44100,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      // 녹음 중지
      String? path = await _record.stop();
      setState(() {
        _isRecording = false;
      });
      print("Recorded file path: $path");
      setState(() {
        messages.add({"user": "음성 메시지 (녹음 완료): $path"});
        messages.add({"bot": "Hello world"});
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.containsKey("user");
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.values.first,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : Colors.green.shade400,
                  ),
                  onPressed: _toggleRecording,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green.shade400),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
