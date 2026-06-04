import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../blocs/app/app_bloc.dart';
import '../blocs/app/app_state.dart';
import '../utils/app_constants.dart';
import '../utils/theme_colors.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum _Role { user, assistant }

class _ChatMessage {
  _ChatMessage({required this.role, required this.text, this.isLoading = false});

  final _Role role;
  final String text;
  final bool isLoading;

  bool get isUser => role == _Role.user;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  static const int _maxInputLength = 500;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      role: _Role.assistant,
      text:
          'Hi! I\'m your FinoTrack AI assistant. Ask me anything about your spending, budgeting tips, or financial goals. 💰',
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Cerebras API call (OpenAI-compatible)
  // -------------------------------------------------------------------------

  // Build a concise financial summary from live app state
  String _buildFinancialContext(AppState appState) {
    final summary = appState.summary;
    final categories = appState.categories;
    final transactions = appState.transactions;

    final sb = StringBuffer();
    sb.writeln('Here is the user financial snapshot for ${summary.monthLabel}:');
    sb.writeln('Total spent this month: \u20b9${summary.totalSpend.toStringAsFixed(0)} '
        '(${summary.percentChange > 0 ? '+' : ''}${summary.percentChange}% vs last month)');
    sb.writeln();

    sb.writeln('Spending by category:');
    for (final cat in categories) {
      sb.writeln(
          '  ${cat.name}: \u20b9${cat.amount.toStringAsFixed(0)} '
          '(${cat.percent.toStringAsFixed(0)}% of total spending)');
    }
    sb.writeln();

    sb.writeln('Recent transactions:');
    final recent = transactions.take(15).toList();
    for (final t in recent) {
      final sign = t.isIncome ? '+' : '-';
      sb.writeln(
          '  ${t.title}: $sign\u20b9${t.amount.toStringAsFixed(0)} '
          '(${t.category}, ${t.timeLabel})');
    }

    return sb.toString();
  }

  Future<String> _callCerebras(String userMessage) async {
    final apiKey = dotenv.env[aiApiKeyEnv] ?? '';

    // Read live app state for financial context
    final appState = context.read<AppBloc>().state;
    final financialContext = _buildFinancialContext(appState);

    // Build conversation history in OpenAI message format
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are FinoTrack AI — a warm, sharp financial buddy inside the FinoTrack app. '
            'You talk like a smart friend who really knows finance, not like a bank or a bot. '
            'You have the user\'s real spending data (shared below) and you MUST use it — '
            'name actual transactions, real rupee amounts, specific categories. Never be vague or generic. '
            '\n\nTone rules (very important):\n'
            '- Write naturally, like you\'re texting a friend. Short paragraphs, no walls of text.\n'
            '- Never start with "Based on your data" or "According to the information provided" or similar robotic phrases.\n'
            '- No asterisks, no markdown formatting, no bullet dashes in responses. Just plain, flowing sentences.\n'
            '- Use emojis occasionally but sparingly — only when they feel natural.\n'
            '- Be encouraging and a little warm, not clinical.\n'
            '- If the user writes in Hindi or Hinglish, reply in the same language naturally.\n'
            '- Keep answers focused — 2 to 4 short paragraphs max.\n'
            '\n$financialContext',
      },
    ];

    // Add last 6 prior messages (skip loading bubbles) to keep tokens low
    final history = _messages.where((m) => !m.isLoading).toList();
    final recent = history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final m in recent) {
      messages.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      });
    }

    // Add the new user message
    messages.add({'role': 'user', 'content': userMessage});

    final body = jsonEncode({
      'model': 'gpt-oss-120b',
      'messages': messages,
      'temperature': 0.7,
      'max_completion_tokens': 550,
    });

    final response = await http
        .post(
          Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final msg = choices[0]['message'] as Map<String, dynamic>;
        return (msg['content'] as String?) ?? 'No response received.';
      }
      return 'No response received.';
    } else if (response.statusCode == 429) {
      throw Exception(
          'Rate limit reached. Please wait a few seconds before sending another message.');
    } else {
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      final errMsg =
          (err['error'] as Map<String, dynamic>?)?['message'] as String? ??
              'API error ${response.statusCode}';
      throw Exception(errMsg);
    }
  }

  // -------------------------------------------------------------------------
  // Send message
  // -------------------------------------------------------------------------

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    final apiKey = dotenv.env[aiApiKeyEnv] ?? '';
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI_API_KEY not set in .env file.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _messages
          .add(_ChatMessage(role: _Role.assistant, text: '', isLoading: true));
      _sending = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final reply = await _callCerebras(text);
      if (!mounted) return;
      setState(() {
        _messages.removeLast(); // remove loading bubble
        _messages.add(_ChatMessage(role: _Role.assistant, text: reply));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(
          role: _Role.assistant,
          text:
              'Sorry, I ran into an issue: ${e.toString().replaceFirst('Exception: ', '')}',
        ));
        _sending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env[aiApiKeyEnv] ?? '';
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: ThemeColors.backgroundFor(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  // Never show the actual key — just show connection status
                  apiKey.isNotEmpty
                      ? 'Online · Powered by Cerebras'
                      : 'API key missing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: apiKey.isNotEmpty
                            ? const Color(0xFF16A34A)
                            : Colors.red,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: msg.isLoading
                      ? _LoadingBubble(brightness: brightness)
                      : _ChatBubble(message: msg, brightness: brightness),
                );
              },
            ),
          ),

          // Input bar
          _buildInputBar(brightness),
        ],
      ),
    );
  }

  Widget _buildInputBar(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  maxLength: _maxInputLength,
                  maxLines: 3,
                  minLines: 1,
                  enabled: !_sending,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Ask anything about your finances…',
                    hintStyle: TextStyle(
                      color: ThemeColors.textSecondaryFor(brightness),
                    ),
                    filled: true,
                    fillColor: ThemeColors.backgroundFor(brightness),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    counterText: '', // hide built-in counter
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedOpacity(
                opacity: _sending ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _sending ? null : _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // Character counter
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 58),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _inputCtrl,
              builder: (ctx, value, child) {
                final remaining = _maxInputLength - value.text.length;
                final isNearLimit = remaining < 60;
                return Text(
                  '${value.text.length}/$_maxInputLength',
                  style: TextStyle(
                    fontSize: 11,
                    color: isNearLimit
                        ? Colors.orange
                        : ThemeColors.textSecondaryFor(brightness),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.brightness});

  final _ChatMessage message;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubbleColor =
        isUser ? const Color(0xFF7C3AED) : ThemeColors.surfaceFor(brightness);
    final textColor =
        isUser ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 6),
                Text(
                  'FinoTrack AI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textSecondaryFor(brightness),
                      ),
                ),
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: textColor, height: 1.45),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading bubble
// ---------------------------------------------------------------------------

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
            ),
          ),
          child:
              const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: ThemeColors.surfaceFor(brightness),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const _TypingDots(),
        ),
      ],
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final bounce = (t < 0.5 ? 2 * t : 2 * (1 - t));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7 + bounce * 5,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED)
                    .withValues(alpha: 0.6 + bounce * 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
