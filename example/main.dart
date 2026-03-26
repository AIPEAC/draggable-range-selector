import 'package:flutter/material.dart';
import 'package:draggable_range_selector/draggable_range_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Range Selector Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DemosPage(),
    );
  }
}

class DemosPage extends StatelessWidget {
  const DemosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Range Selector')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            'Basic Example',
            'Default blue theme with item management',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BasicExample()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Custom Theme',
            'Purple theme with larger text and cells',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomThemeExample()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Callback Example',
            'Shows how to listen to selection changes',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CallbackExample()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'March 2026 (Lens Mode)',
            'Month grid with 7-day rows and snap-updating range text',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const March2026LensExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 1: Basic usage with default configuration
class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Example')),
      body: DraggableRangeSelector(
        title: 'Select a Range',
        initialWords: const [
          'cat',
          'elephant',
          'dog',
          'butterfly',
          'ant',
          'rhinoceros',
          'bee',
          'tiger',
          'ox',
          'penguin',
          'frog',
          'hippopotamus',
        ],
        initialSelectedStart: 2,
        initialSelectedEnd: 9,
        showManagementUI: true,
        onSelectionChanged: (start, end) {
          debugPrint('Selection changed: $start to $end');
        },
        onWordsChanged: (words) {
          debugPrint('Words changed: ${words.length} items');
        },
      ),
    );
  }
}

/// Example 2: Custom theme configuration
class CustomThemeExample extends StatelessWidget {
  const CustomThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Theme Example')),
      body: DraggableRangeSelector(
        title: 'Custom Styled Selection',
        initialWords: const [
          'alpha',
          'beta',
          'gamma',
          'delta',
          'epsilon',
          'zeta',
          'eta',
          'theta',
        ],
        initialSelectedStart: 0,
        initialSelectedEnd: 5,
        showManagementUI: true,
        config: const DraggableRangeSelectorConfig(
          selectionColor: Color(0xFF9C27B0),
          handleColor: Color(0xFF7B1FA2),
          cellBackgroundColor: Color(0xFFE1BEE7),
          textColor: Color(0xFF4A148C),
          selectedTextColor: Colors.white,
          cellHeight: 60.0,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          minCellWidth: 70.0,
          maxCellWidth: 180.0,
        ),
        onSelectionChanged: (start, end) {
          debugPrint('Custom selection: $start to $end');
        },
      ),
    );
  }
}

/// Example 3: Demonstrates callbacks
class CallbackExample extends StatefulWidget {
  const CallbackExample({super.key});

  @override
  State<CallbackExample> createState() => _CallbackExampleState();
}

class _CallbackExampleState extends State<CallbackExample> {
  late String selectedRange;
  late int itemCount;

  @override
  void initState() {
    super.initState();
    selectedRange = 'Mon - Fri';
    itemCount = 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Callback Example')),
      body: Column(
        children: [
          Container(
            color: Colors.blue[50],
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current State:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('Selected: $selectedRange'),
                Text('Total Items: $itemCount'),
              ],
            ),
          ),
          Expanded(
            child: DraggableRangeSelector(
              title: 'Days of Week',
              initialWords: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
              initialSelectedStart: 0,
              initialSelectedEnd: 4,
              showManagementUI: true,
              onSelectionChanged: (start, end) {
                setState(() {
                  const words = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  selectedRange = '${words[start]} - ${words[end]}';
                });
              },
              onWordsChanged: (words) {
                setState(() {
                  itemCount = words.length;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Month-style calendar selection in lens mode
class March2026LensExample extends StatefulWidget {
  const March2026LensExample({super.key});

  @override
  State<March2026LensExample> createState() => _March2026LensExampleState();
}

class _March2026LensExampleState extends State<March2026LensExample> {
  static const String _emptyCell = '--';
  static const List<int?> _marchSlots = [
    1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28,
    29, 30, 31, null, null, null, null,
  ];

  late int _start;
  late int _end;

  List<String> get _words => _marchSlots
      .map((day) => day == null ? _emptyCell : day.toString().padLeft(2, '0'))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _start = 7; // 03/08
    _end = 13; // 03/14
  }

  int _nearestRealDayIndex(int index, {required bool searchForward}) {
    if (_marchSlots[index] != null) return index;
    if (searchForward) {
      for (int i = index; i < _marchSlots.length; i++) {
        if (_marchSlots[i] != null) return i;
      }
    } else {
      for (int i = index; i >= 0; i--) {
        if (_marchSlots[i] != null) return i;
      }
    }
    return 0;
  }

  String _formatAt(int index, {required bool isStart}) {
    final resolved = _nearestRealDayIndex(index, searchForward: isStart);
    final day = _marchSlots[resolved] ?? 1;
    return '03/${day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('March 2026 Lens Example')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = 48.0;
            const rowSpacing = 8.0;
            const interCellSpacingTarget = 8.0;
            final usableWidth = (constraints.maxWidth - horizontalPadding).clamp(280.0, 900.0);
            final cellWidth = (usableWidth - (6 * interCellSpacingTarget)) / 7;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'March 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'SUN  MON  TUE  WED  THU  FRI  SAT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'You have selected: "${_formatAt(_start, isStart: true)}" to "${_formatAt(_end, isStart: false)}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 520,
                  child: DraggableRangeSelector(
                    title: null,
                    initialWords: _words,
                    initialSelectedStart: _start,
                    initialSelectedEnd: _end,
                    showManagementUI: false,
                    config: DraggableRangeSelectorConfig(
                      initialDisplayMode: 1, // lens mode
                      rowSpacing: rowSpacing,
                      minCellWidth: cellWidth,
                      maxCellWidth: cellWidth,
                      cellPadding: 0,
                      cellHeight: 52,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      selectionColor: const Color(0xFF1976D2),
                      handleColor: const Color(0xFF0D47A1),
                      cellBackgroundColor: const Color(0xFFE6E9EF),
                      selectedCellBackgroundColor: Colors.transparent,
                      textColor: const Color(0xFF374151),
                      selectedTextColor: Colors.white,
                      borderRadius: 8,
                    ),
                    onSelectionChanged: (start, end) {
                      setState(() {
                        _start = start;
                        _end = end;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}
