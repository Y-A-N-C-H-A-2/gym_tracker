import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../rest_timer.dart';
import '../store.dart';
import '../theme.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.store,
    required this.timer,
    required this.day,
    required this.index,
  });

  final WorkoutStore store;
  final RestTimerManager timer;
  final int day;
  final int index;

  Exercise get exercise => program[day].exercises[index];

  @override
  Widget build(BuildContext context) {
    final allDone = store.exerciseDone(day, index);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: allDone ? Palette.cardDone : Palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: allDone ? Palette.volt.withValues(alpha: 0.45) : Palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name.toUpperCase(),
                        style: condensed(21, height: 1.05)),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _TagChip(
                          label: 'TARGET ${exercise.reps}',
                          color: Palette.volt,
                          baseColor: Palette.volt,
                        ),
                        _TagChip(
                          label: 'REST ${formatRest(exercise.rest)}',
                          color: Palette.restText,
                          baseColor: Palette.restOrange,
                          onTap: () =>
                              timer.start(exercise.name, exercise.rest),
                        ),
                        _TagChip(
                          label: '▶ WATCH',
                          color: Palette.watchBlue,
                          baseColor: Palette.watchBase,
                          onTap: () => launchUrl(
                            exercise.watchUrl,
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: allDone ? 1 : 0,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: Palette.volt,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '✓',
                    style: condensed(17,
                        weight: FontWeight.w800, color: Palette.darkOnVolt),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var si = 0; si < exercise.sets; si++) ...[
            if (si > 0) const SizedBox(height: 9),
            _SetRow(
              store: store,
              timer: timer,
              day: day,
              exercise: index,
              set: si,
            ),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.baseColor,
    this.onTap,
  });

  final String label;
  final Color color;
  final Color baseColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: baseColor.withValues(alpha: 0.28)),
        ),
        child: Text(label, style: condensed(12, color: color)),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    required this.store,
    required this.timer,
    required this.day,
    required this.exercise,
    required this.set,
  });

  final WorkoutStore store;
  final RestTimerManager timer;
  final int day;
  final int exercise;
  final int set;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    final entry =
        widget.store.entry(widget.day, widget.exercise, widget.set);
    _weightCtrl = TextEditingController(text: entry.weight);
    _repsCtrl = TextEditingController(text: entry.reps);
  }

  @override
  void didUpdateWidget(_SetRow old) {
    super.didUpdateWidget(old);
    // The row was recycled for a different set (day switch): reload text.
    if (old.day != widget.day ||
        old.exercise != widget.exercise ||
        old.set != widget.set) {
      final entry =
          widget.store.entry(widget.day, widget.exercise, widget.set);
      _weightCtrl.text = entry.weight;
      _repsCtrl.text = entry.reps;
    } else {
      // External log change (e.g. reset day) while the widget stays put.
      final entry =
          widget.store.entry(widget.day, widget.exercise, widget.set);
      if (entry.weight != _weightCtrl.text && entry.weight.isEmpty) {
        _weightCtrl.text = entry.weight;
      }
      if (entry.reps != _repsCtrl.text && entry.reps.isEmpty) {
        _repsCtrl.text = entry.reps;
      }
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.store.entry(widget.day, widget.exercise, widget.set);
    final big = widget.store.bigNumbers;
    final fieldHeight = big ? 62.0 : 54.0;
    final fontSize = big ? 30.0 : 24.0;

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            'SET ${widget.set + 1}',
            style: condensed(
              13,
              weight: FontWeight.w800,
              color: entry.done ? Palette.volt : Palette.textFaint,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NumberField(
            controller: _weightCtrl,
            suffix: widget.store.unitLabel,
            height: fieldHeight,
            fontSize: fontSize,
            decimal: true,
            onChanged: (v) => widget.store
                .setWeight(widget.day, widget.exercise, widget.set, v),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NumberField(
            controller: _repsCtrl,
            suffix: 'REPS',
            height: fieldHeight,
            fontSize: fontSize,
            decimal: false,
            onChanged: (v) => widget.store
                .setReps(widget.day, widget.exercise, widget.set, v),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final nowDone = widget.store
                .toggleSet(widget.day, widget.exercise, widget.set);
            HapticFeedback.mediumImpact();
            if (nowDone && widget.store.autoRest) {
              final ex = program[widget.day].exercises[widget.exercise];
              widget.timer.start(ex.name, ex.rest);
            }
          },
          child: Container(
            width: big ? 58 : 52,
            height: fieldHeight,
            decoration: BoxDecoration(
              color: entry.done ? Palette.volt : Palette.surface2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: entry.done ? Palette.volt : Palette.border,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: entry.done
                ? Text(
                    '✓',
                    style: condensed(24,
                        weight: FontWeight.w800, color: Palette.darkOnVolt),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.suffix,
    required this.height,
    required this.fontSize,
    required this.decimal,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String suffix;
  final double height;
  final double fontSize;
  final bool decimal;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Palette.surface2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Palette.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            style: condensed(fontSize),
            cursorColor: Palette.volt,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: '–',
              hintStyle: condensed(fontSize, color: Palette.textGhost),
              contentPadding: const EdgeInsets.only(right: 4),
            ),
          ),
          Positioned(
            right: 9,
            child: IgnorePointer(
              child: Text(
                suffix,
                style: condensed(10,
                    color: Palette.textFaint, letterSpacing: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
