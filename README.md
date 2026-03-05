# Draggable Range Selector

A flexible Flutter widget for selecting ranges of items with draggable handles. Features a dynamic grid layout, two display modes (transparent overlay or lens effect), and full customization options.

## Features

✨ **Dynamic Grid Layout** - Automatically arranges items based on their actual widths, not fixed columns

🎯 **Draggable Handles** - Intuitive range selection with smooth drag interactions
![msedge_M1dc6w1GYM](https://github.com/user-attachments/assets/82a7887b-fdc2-4bc5-b469-bab3ac91adfc)


🎨 **Two Display Modes**:
  - Transparent overlay mode for subtle visual feedback
  - Lens effect mode that reveals content underneath

⚙️ **Fully Customizable**:
  - Colors (selection, handles, cells, text)
  - Sizes (cells, handles, spacing, font)
  - Layout parameters
  - Transparency levels

🔧 **Built-in Item Management**:
  - Add new items
  - Edit existing items
  - Move items to different positions

📱 **Embeddable** - Works in any container (dialogs, bottom sheets, columns, tabs, etc.)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  draggable_range_selector: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:draggable_range_selector/draggable_range_selector.dart';

DraggableRangeSelector(
  initialWords: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  initialSelectedStart: 0,
  initialSelectedEnd: 4,
  onSelectionChanged: (start, end) {
    print('Selected: $start to $end');
  },
)
```

### Custom Styling

```dart
DraggableRangeSelector(
  initialWords: const ['Apple', 'Banana', 'Cherry', 'Date'],
  initialSelectedStart: 0,
  initialSelectedEnd: 2,
  config: const DraggableRangeSelectorConfig(
    selectionColor: Color(0xFF9C27B0),
    handleColor: Color(0xFF7B1FA2),
    cellBackgroundColor: Color(0xFFE1BEE7),
    cellHeight: 60.0,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    minCellWidth: 70.0,
    maxCellWidth: 180.0,
  ),
  onSelectionChanged: (start, end) {
    print('Selected range: $start to $end');
  },
)
```

## Configuration Options

### Colors

| Parameter | Default | Description |
|-----------|---------|-------------|
| `selectionColor` | `Color(0xFF2196F3)` | Color of the selection overlay/fill |
| `handleColor` | `Color(0xFF1976D2)` | Color of the drag handles |
| `handleBorderColor` | `Colors.white` | Border color of handles |
| `cellBackgroundColor` | `Color(0xFFE0E0E0)` | Background color of cells |
| `selectedCellBackgroundColor` | `Colors.transparent` | Background for selected cells in lens mode |
| `textColor` | `Colors.black87` | Text color for unselected items |
| `selectedTextColor` | `Colors.white` | Text color for selected items |

### Sizing

| Parameter | Default | Description |
|-----------|---------|-------------|
| `cellHeight` | `50.0` | Height of each item cell |
| `minCellWidth` | `60.0` | Minimum cell width |
| `maxCellWidth` | `150.0` | Maximum cell width |
| `cellPadding` | `16.0` | Padding added to text width |
| `rowSpacing` | `8.0` | Vertical space between rows |
| `handleSize` | `28.0` | Width of drag handles |
| `fontSize` | `14.0` | Text size |
| `borderRadius` | `8.0` | Corner radius of cells |

### Behavior

| Parameter | Default | Description |
|-----------|---------|-------------|
| `initialDisplayMode` | `0` | Display mode: 0 (transparent) or 1 (lens) |
| `initialTransparency` | `50.0` | Opacity for transparent mode (0-100) |
| `showManagementUI` | `true` | Show/hide add/edit/move buttons |

## Callbacks

### `onSelectionChanged`
Called when the user changes the selection range:

```dart
onSelectionChanged: (int start, int end) {
  print('Range: $start to $end');
}
```

### `onWordsChanged`
Called when items are added, edited, or removed:

```dart
onWordsChanged: (List<String> items) {
  print('Items: ${items.join(", ")}');
}
```

## Display Modes

### Mode 0: Transparent Overlay
Shows a semi-transparent overlay over the selected range. Adjust opacity with `initialTransparency` (0-100).

### Mode 1: Lens Effect
Creates a "lens" effect where selected cells become transparent, revealing the blue selection color underneath while keeping the text visible.

## Examples

See the `example/` directory for complete working examples including:
- Basic usage with default configuration
- Custom theme with purple colors
- Callback handling with state updates

Run the example app:

```bash
cd example
flutter run
```

## Advanced: Embedding in Other Widgets

The widget returns a `SingleChildScrollView`, making it easy to embed anywhere:

```dart
// In a dialog
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: DraggableRangeSelector(
      initialWords: const ['A', 'B', 'C', 'D', 'E'],
      initialSelectedStart: 0,
      initialSelectedEnd: 3,
    ),
  ),
);

// In a bottom sheet
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableRangeSelector(
    initialWords: const ['X', 'Y', 'Z'],
    initialSelectedStart: 0,
    initialSelectedEnd: 2,
  ),
);
```

## Requirements

- Flutter 3.13.0 or higher
- Dart 3.0.0 or higher

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please open an issue on [GitHub](https://github.com/AIPEAC/draggable-range-selector).
