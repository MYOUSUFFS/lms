import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// AI Tool types available in the panel
enum AITool {
  summary,
  flashcards,
  quiz,
  report,
  mindMap,
  infographic,
  audioOverview,
}

extension AIToolExtension on AITool {
  String get title {
    switch (this) {
      case AITool.summary:
        return 'Summary';
      case AITool.flashcards:
        return 'Flashcards';
      case AITool.quiz:
        return 'Quiz';
      case AITool.report:
        return 'Report';
      case AITool.mindMap:
        return 'Mind Map';
      case AITool.infographic:
        return 'Infographic';
      case AITool.audioOverview:
        return 'Audio Overview';
    }
  }

  String get description {
    switch (this) {
      case AITool.summary:
        return 'Generate a concise summary of your documents';
      case AITool.flashcards:
        return 'Create study flashcards from key concepts';
      case AITool.quiz:
        return 'Test your knowledge with auto-generated quizzes';
      case AITool.report:
        return 'Generate detailed analysis reports';
      case AITool.mindMap:
        return 'Visualize concepts and relationships';
      case AITool.infographic:
        return 'Create visual representations of data';
      case AITool.audioOverview:
        return 'Listen to an audio summary';
    }
  }

  IconData get icon {
    switch (this) {
      case AITool.summary:
        return Icons.summarize;
      case AITool.flashcards:
        return Icons.style;
      case AITool.quiz:
        return Icons.quiz;
      case AITool.report:
        return Icons.assessment;
      case AITool.mindMap:
        return Icons.hub;
      case AITool.infographic:
        return Icons.auto_graph;
      case AITool.audioOverview:
        return Icons.headphones;
    }
  }

  Color get color {
    switch (this) {
      case AITool.summary:
        return Colors.blue;
      case AITool.flashcards:
        return Colors.orange;
      case AITool.quiz:
        return Colors.green;
      case AITool.report:
        return Colors.purple;
      case AITool.mindMap:
        return Colors.teal;
      case AITool.infographic:
        return Colors.pink;
      case AITool.audioOverview:
        return Colors.indigo;
    }
  }
}

/// Right panel showing AI Tools for document processing
class AIToolsPanel extends StatefulWidget {
  final bool hasDocuments;
  final Function(AITool)? onToolSelected;
  final AITool? selectedTool;

  const AIToolsPanel({
    super.key,
    this.hasDocuments = false,
    this.onToolSelected,
    this.selectedTool,
  });

  @override
  State<AIToolsPanel> createState() => _AIToolsPanelState();
}

class _AIToolsPanelState extends State<AIToolsPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Tools list
          Expanded(
            child: widget.hasDocuments
                ? _buildToolsList(context)
                : _buildNoDocumentsState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tools',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Enhance your learning',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
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

  Widget _buildToolsList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(context, 'Study Tools'),
        const SizedBox(height: 8),
        _buildToolCard(context, AITool.summary),
        _buildToolCard(context, AITool.flashcards),
        _buildToolCard(context, AITool.quiz),

        const SizedBox(height: 20),
        _buildSectionTitle(context, 'Analysis'),
        const SizedBox(height: 8),
        _buildToolCard(context, AITool.report),
        _buildToolCard(context, AITool.mindMap),

        const SizedBox(height: 20),
        _buildSectionTitle(context, 'Visual & Audio'),
        const SizedBox(height: 8),
        _buildToolCard(context, AITool.infographic),
        _buildToolCard(context, AITool.audioOverview),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, AITool tool) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedTool == tool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected ? tool.color.withValues(alpha: 0.1) : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => widget.onToolSelected?.call(tool),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? tool.color.withValues(alpha: 0.3)
                    : theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tool.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tool.icon, color: tool.color, size: 20),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: theme.iconTheme.color?.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDocumentsState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI Tools Unavailable',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a document to unlock AI-powered learning tools',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
