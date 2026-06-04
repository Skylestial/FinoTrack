import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app/app_bloc.dart';
import '../blocs/app/app_event.dart';
import '../data/mock_data.dart';
import '../utils/formatters.dart';
import '../utils/theme_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: ThemeColors.backgroundFor(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AppBloc>().add(const TabSelected(0));
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AppBloc>().add(const ThemeToggled());
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Row(
            children: [
              _FilterChip(
                label: 'This Month',
                isSelected: true,
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'vs Last Month',
                isSelected: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InsightCard(
            title: 'Spending Trend',
            subtitle: formatCurrency(summaryData.totalSpend),
            changeLabel: '+ ${summaryData.percentChange.toStringAsFixed(1)}%',
            brightness: brightness,
          ),
          const SizedBox(height: 18),
          _CategoryInsight(brightness: brightness),
          const SizedBox(height: 18),
          _TipCard(
            title: 'Dining Out',
            subtitle: 'You spent 18% more',
            message: 'Try limiting to 1-2 times a week.',
            icon: Icons.restaurant,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _TipCard(
            title: 'Subscriptions',
            subtitle: 'Saving Opportunity',
            message: 'You can save up to \u20B91,240',
            icon: Icons.star,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 18),
          _AiInsightBanner(brightness: brightness),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? ThemeColors.primary : ThemeColors.surfaceFor(
          Theme.of(context).brightness,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : ThemeColors.textSecondaryFor(
                Theme.of(context).brightness,
              ),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.changeLabel,
    required this.brightness,
  });

  final String title;
  final String subtitle;
  final String changeLabel;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F9ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  changeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _TrendPainter(color: ThemeColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.6)
      ..lineTo(size.width * 0.65, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.15);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(size.width, size.height * 0.15), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryInsight extends StatelessWidget {
  const _CategoryInsight({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final category = categories.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondaryFor(brightness),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(category.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.percent.toStringAsFixed(0)}% of total spend',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondaryFor(brightness),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: category.percent / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF3E8FF),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFFEDD5),
                  child: Icon(category.icon, color: const Color(0xFFF97316)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.title,
    required this.subtitle,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondaryFor(brightness),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondaryFor(brightness),
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

class _AiInsightBanner extends StatelessWidget {
  const _AiInsightBanner({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEDE9FE),
            child: Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You spent 18% more on dining out. Try cooking at home 2 more times this week to save \u20B9650!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondaryFor(brightness),
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
