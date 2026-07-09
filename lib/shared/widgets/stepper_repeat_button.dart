import 'dart:async';

import 'package:flutter/material.dart';

/// Icon button with tap + long-press auto-repeat (accelerating).
///
/// Uses pointer down/up for reliable hold-to-repeat. [IconButton.onPressed]
/// is a no-op when enabled so Material enabled/disabled styling and tests that
/// inspect `onPressed == null` keep working without double-firing steps.
class StepperRepeatButton extends StatefulWidget {
  const StepperRepeatButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onStep,
    this.iconSize = 22,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onStep;
  final double iconSize;

  @override
  State<StepperRepeatButton> createState() => _StepperRepeatButtonState();
}

class _StepperRepeatButtonState extends State<StepperRepeatButton> {
  Timer? _holdDelayTimer;
  Timer? _repeatTimer;
  int _repeatTicks = 0;

  static const _holdDelay = Duration(milliseconds: 380);
  static const _initialInterval = Duration(milliseconds: 120);
  static const _fastInterval = Duration(milliseconds: 50);
  static const _accelerateAfterTicks = 6;

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StepperRepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _stopRepeat();
    }
  }

  void _stopRepeat() {
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _repeatTicks = 0;
  }

  void _fireStep() {
    if (!widget.enabled) {
      _stopRepeat();
      return;
    }
    widget.onStep();
  }

  void _onPointerDown(PointerDownEvent _) {
    if (!widget.enabled) return;
    _fireStep();
    _holdDelayTimer = Timer(_holdDelay, () {
      _scheduleRepeat(_initialInterval);
    });
  }

  void _onPointerUp(PointerEvent _) {
    _stopRepeat();
  }

  void _scheduleRepeat(Duration interval) {
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(interval, (_) {
      if (!widget.enabled) {
        _stopRepeat();
        return;
      }
      _repeatTicks++;
      _fireStep();
      if (_repeatTicks == _accelerateAfterTicks && interval != _fastInterval) {
        _scheduleRepeat(_fastInterval);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.tooltip,
      child: Listener(
        onPointerDown: enabled ? _onPointerDown : null,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        child: IconButton(
          tooltip: widget.tooltip,
          // No-op when enabled: steps come from [Listener] to support hold
          // without double-firing. Null when disabled for tests/a11y.
          onPressed: enabled ? () {} : null,
          icon: Icon(widget.icon, size: widget.iconSize),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
          ),
        ),
      ),
    );
  }
}
