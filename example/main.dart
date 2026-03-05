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
                  final words = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
