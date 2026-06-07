import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/enum_labels.dart';
import 'package:task_manager/domain/entities/task.dart';

import '../../application/project_list_provider.dart';
import '../../application/stats_provider.dart';
import '../theme/priority_colors.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(taskStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (stats) {
          if (stats.total == 0) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights, size: 56, color: theme.hintColor),
                  const SizedBox(height: 12),
                  Text('Aucune donnée à afficher',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Créez des tâches pour voir vos statistiques',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle(context, 'Vue d\'ensemble'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(label: 'Total', value: stats.total),
                  _MetricCard(
                      label: 'À faire', value: stats.todo, color: Colors.grey),
                  _MetricCard(
                      label: 'En cours',
                      value: stats.inProgress,
                      color: Colors.blue),
                  _MetricCard(
                      label: 'Terminée',
                      value: stats.done,
                      color: Colors.green),
                  _MetricCard(
                    label: 'En retard',
                    value: stats.overdue,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Par priorité'),
              const SizedBox(height: 12),
              ...Priority.values.map((p) {
                final colors = theme.extension<PriorityColors>()!;
                return _BarRow(
                  label: p.label,
                  count: stats.byPriority[p] ?? 0,
                  total: stats.total,
                  color: colors.forPriority(p),
                );
              }),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Par projet'),
              const SizedBox(height: 12),
              _ProjectBreakdown(stats: stats),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _MetricCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          Text('$value',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: theme.textTheme.bodyMedium),
              ),
              Text('$count',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: color.withValues(alpha: 0.15),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectBreakdown extends ConsumerWidget {
  final TaskStats stats;

  const _ProjectBreakdown({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erreur : $e'),
      data: (projects) {
        final rows = <Widget>[];

        for (final p in projects) {
          rows.add(_projectRow(
            theme,
            color: Color(p.color),
            name: p.name,
            count: stats.byProject[p.id] ?? 0,
          ));
        }

        final sansProjet = stats.byProject[null] ?? 0;
        if (sansProjet > 0) {
          rows.add(_projectRow(
            theme,
            color: theme.hintColor,
            name: 'Sans projet',
            count: sansProjet,
          ));
        }

        if (rows.isEmpty) {
          return Text('Aucun projet',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor));
        }
        return Column(children: rows);
      },
    );
  }

  Widget _projectRow(ThemeData theme,
      {required Color color, required String name, required int count}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          Text('$count',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
