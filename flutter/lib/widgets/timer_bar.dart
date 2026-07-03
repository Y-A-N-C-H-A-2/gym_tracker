import 'package:flutter/material.dart';

import '../models.dart';
import '../rest_timer.dart';
import '../theme.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({super.key, required this.timer});

  final RestTimerManager timer;

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.timer;

    if (t.isFinished && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!t.isFinished && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1.0;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      child: ScaleTransition(
        scale: _pulse,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: t.isFinished ? Palette.volt : Palette.restOrange,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 34,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: t.progress,
                  minHeight: 5,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                  valueColor: AlwaysStoppedAnimation(
                    Palette.darkOnTimer.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.label,
                        style: condensed(
                          12,
                          weight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: Palette.darkOnTimer.withValues(alpha: 0.62),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: Text(
                          t.exerciseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: condensed(14, color: Palette.darkOnTimer),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Text(
                      formatClock(t.remaining),
                      textAlign: TextAlign.center,
                      style: condensed(
                        40,
                        weight: FontWeight.w800,
                        color: Palette.darkOnTimer,
                        height: 1.0,
                      ),
                    ),
                  ),
                  _TimerButton(
                    label: t.isRunning || t.remaining <= 0 ? 'PAUSE' : 'RESUME',
                    minWidth: 58,
                    onTap: t.togglePause,
                  ),
                  const SizedBox(width: 7),
                  _TimerButton(label: '+15', onTap: t.addFifteen),
                  const SizedBox(width: 7),
                  _TimerButton(label: '✕', onTap: t.stop),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.label, required this.onTap, this.minWidth = 0});

  final String label;
  final VoidCallback onTap;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Palette.darkOnTimer.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: condensed(13,
              weight: FontWeight.w800, color: Palette.darkOnTimer),
        ),
      ),
    );
  }
}
