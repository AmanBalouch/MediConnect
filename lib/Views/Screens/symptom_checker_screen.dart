import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/services/grok_service.dart';
import 'package:mediconnectcode/ViewModels/login_viewmodel.dart';
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

  Future<void> _onNavTap(int index) async {
    switch (index) {
      case 0:
        final role = await context.read<LoginViewModel>().getUserRole();
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          role == 1 ? '/doctor-home' : '/patient-home',
        );
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
            style: AppTheme.small(AppTheme.textTertiary),
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
              style: AppTheme.body(
                isUser ? Colors.white : (isAISuggest ? AppTheme.primaryBlueDark : AppTheme.textPrimary),
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
      // Navbar sits separately so text field never hides behind it
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2, onTap: _onNavTap),
      body: Column(
        children: [
          // Blue Gradient Header
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MediBot AI', style: AppTheme.label(Colors.white)),
                      Text('Symptoms checker · Doctor finder', style: AppTheme.small(Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildBubble(_messages[index]),
            ),
          ),

          // "Thinking..." indicator
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Thinking...', style: AppTheme.small(AppTheme.textSecondary)),
                ],
              ),
            ),

          // Text input field — sits above navbar, never hidden
          Container(
            color: AppTheme.cardColor,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                // Input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTheme.body(AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms...',
                      hintStyle: AppTheme.small(AppTheme.textTertiary),
                      filled: true,
                      fillColor: AppTheme.bgColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
