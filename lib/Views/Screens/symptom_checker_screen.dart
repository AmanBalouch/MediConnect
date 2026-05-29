import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/services/grok_service.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <Map<String, String>>[];
  bool _loading = false;

  final GrokService _service = GrokService();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text':
          'Hello! I\'m MediConnectBot. Tell me your symptoms and I\'ll help identify possible conditions and suggest the right specialist.',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _service.sendMessage(text);
      setState(() {
        _messages.add({'role': 'ai', 'text': reply});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Error: $e'});
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-home');
        break;
      case 1:
        // Navigate to Chat
        Navigator.pushNamed(context, '/chat');
        break;
      case 2:
        // Already on ChatBot
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBotLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'MediBot',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final isAISuggest =
        message['role'] == 'ai' &&
        (message['text']!.contains('Possible conditions') ||
            message['text']!.contains('Recommended'));

    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isUser) _buildBotLabel(),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppTheme.primaryTeal
                  : (isAISuggest ? AppTheme.primaryBlueLight : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
              border: !isUser
                  ? Border.all(
                      color: isAISuggest
                          ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                          : AppTheme.borderColor,
                    )
                  : null,
            ),
            child: Text(
              message['text']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUser
                    ? Colors.white
                    : (isAISuggest
                          ? AppTheme.primaryBlueDark
                          : AppTheme.textPrimary),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          // Blue Gradient Header (like login/signup pages)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              14,
              MediaQuery.of(context).padding.top + 8,
              14,
              16,
            ),
            child: Row(
              children: [
                // Bot Icon
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MediBot AI',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Symptom checker · Doctor finder',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chat Messages Area
          Expanded(
            child: Container(
              color: AppTheme.bgColor,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _buildBubble(_messages[i]),
              ),
            ),
          ),
          // Loading Indicator
          if (_loading)
            Container(
              height: 3,
              color: AppTheme.primaryBlue,
              child: const LinearProgressIndicator(
                value: null,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
              ),
            ),
          // Chat Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !_loading,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type symptoms...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        hintStyle: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppTheme.textTertiary),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loading ? null : _send,
                  child: Opacity(
                    opacity: _loading ? 0.6 : 1.0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlue,
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2, onTap: _onNavTap),
    );
  }
}
