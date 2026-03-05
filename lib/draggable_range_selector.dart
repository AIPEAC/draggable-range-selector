/// Draggable Range Selector - A flexible widget for selecting ranges of items
///
/// This widget provides a dynamic grid layout with:
/// - Automatic layout based on actual item widths (not fixed columns)
/// - Draggable handles for intuitive range selection
/// - Two display modes: transparent overlay or lens effect
/// - Full customization of colors, sizes, and behavior
///
/// ## Basic Usage:
///
/// ```dart
/// DraggableRangeSelector(
///   initialItems: const ['cat', 'dog', 'bird'],
///   initialSelectedStart: 0,
///   initialSelectedEnd: 2,
///   onSelectionChanged: (start, end) {
///     print('Selected: $start to $end');
///   },
/// )
/// ```
///
/// ## Advanced Customization:
///
/// ```dart
/// DraggableRangeSelector(
///   initialItems: myItemList,
///   config: DraggableRangeSelectorConfig(
///     selectionColor: Colors.purple,
///     handleColor: Colors.deepPurple,
///     cellHeight: 60.0,
///     fontSize: 16.0,
///     minCellWidth: 80.0,
///     maxCellWidth: 200.0,
///   ),
///   showManagementUI: false, // Hide add/edit/move buttons
///   onSelectionChanged: (start, end) {
///     // Handle selection changes
///   },
///   onItemsChanged: (items) {
///     // Handle item list changes
///   },
/// )
/// ```
///
/// ## Configuration Options:
///
/// **Colors:**
/// - `selectionColor`: Color of the selection overlay/fill
/// - `handleColor`: Color of the drag handles
/// - `handleBorderColor`: Border color of handles
/// - `cellBackgroundColor`: Background color of word cells
/// - `selectedCellBackgroundColor`: Background for selected cells (lens mode)
/// - `textColor`: Text color for unselected words
/// - `selectedTextColor`: Text color for selected words
///
/// **Sizes:**
/// - `cellHeight`: Height of each word cell (default: 50.0)
/// - `minCellWidth`: Minimum cell width (default: 60.0)
/// - `maxCellWidth`: Maximum cell width (default: 150.0)
/// - `cellPadding`: Padding added to text width (default: 16.0)
/// - `rowSpacing`: Vertical space between rows (default: 8.0)
/// - `handleSize`: Size of drag handles (default: 28.0)
/// - `fontSize`: Text size (default: 14.0)
/// - `borderRadius`: Corner radius (default: 8.0)
///
/// **Behavior:**
/// - `initialDisplayMode`: 0 (transparent) or 1 (lens effect)
/// - `initialTransparency`: Opacity percentage for mode 0 (0-100)
/// - `showManagementUI`: Show/hide word management buttons
///
library draggable_range_selector;

import 'package:flutter/material.dart';

/// Configuration for DraggableRangeSelector appearance and behavior
class DraggableRangeSelectorConfig {
  // Selection colors
  final Color selectionColor;
  final Color handleColor;
  final Color handleBorderColor;

  // Cell colors
  final Color cellBackgroundColor;
  final Color selectedCellBackgroundColor;
  final Color textColor;
  final Color selectedTextColor;

  // Sizes
  final double cellHeight;
  final double minCellWidth;
  final double maxCellWidth;
  final double cellPadding;
  final double rowSpacing;
  final double handleSize;

  // Text style
  final double fontSize;
  final FontWeight fontWeight;

  // Display mode
  final int initialDisplayMode; // 0: transparent overlay, 1: lens effect
  final double initialTransparency; // 0-100 for mode 0

  // Layout
  final EdgeInsets containerPadding;
  final double borderRadius;

  const DraggableRangeSelectorConfig({
    this.selectionColor = const Color(0xFF2196F3),
    this.handleColor = const Color(0xFF1976D2),
    this.handleBorderColor = Colors.white,
    this.cellBackgroundColor = const Color(0xFFE0E0E0),
    this.selectedCellBackgroundColor = Colors.transparent,
    this.textColor = Colors.black87,
    this.selectedTextColor = Colors.white,
    this.cellHeight = 50.0,
    this.minCellWidth = 60.0,
    this.maxCellWidth = 150.0,
    this.cellPadding = 16.0,
    this.rowSpacing = 8.0,
    this.handleSize = 28.0,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.initialDisplayMode = 0,
    this.initialTransparency = 50.0,
    this.containerPadding = const EdgeInsets.all(24.0),
    this.borderRadius = 8.0,
  });
}

/// Draggable range selector widget with editable items and draggable selection
class DraggableRangeSelector extends StatefulWidget {
  /// Initial list of words to display
  final List<String> initialWords;

  /// Initial selection range
  final int initialSelectedStart;
  final int initialSelectedEnd;

  /// Configuration for appearance and behavior
  final DraggableRangeSelectorConfig config;

  /// Called when selection changes
  final void Function(int start, int end)? onSelectionChanged;

  /// Called when words list changes
  final void Function(List<String> words)? onWordsChanged;

  /// Whether to show word management UI (add/edit/move buttons)
  final bool showManagementUI;

  /// App bar title
  final String? title;

  const DraggableRangeSelector({
    super.key,
    this.initialWords = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.initialSelectedStart = 0,
    this.initialSelectedEnd = 6,
    this.config = const DraggableRangeSelectorConfig(),
    this.onSelectionChanged,
    this.onWordsChanged,
    this.showManagementUI = true,
    this.title,
  });

  @override
  State<DraggableRangeSelector> createState() => _DraggableRangeSelectorState();
}

class _DraggableRangeSelectorState extends State<DraggableRangeSelector> {
  /// Dynamic word list - can be added, edited, removed, reordered
  late List<String> words;

  late int selectedStart;
  late int selectedEnd;

  @override
  void initState() {
    super.initState();
    words = List.from(widget.initialWords);
    selectedStart = widget.initialSelectedStart.clamp(0, words.length - 1);
    selectedEnd = widget.initialSelectedEnd.clamp(0, words.length - 1);
    _displayMode = widget.config.initialDisplayMode;
    _transparencyPercent = widget.config.initialTransparency;
  }

  /// GlobalKey to track the grid container for drag calculations
  final GlobalKey _containerKey = GlobalKey();

  /// GlobalKeys to track handle positions
  final GlobalKey _leftHandleKey = GlobalKey();
  final GlobalKey _rightHandleKey = GlobalKey();

  /// Drag state for smooth handle movement
  Offset? _leftHandleDragPosition;
  Offset? _rightHandleDragPosition;
  bool _isDraggingLeft = false;
  bool _isDraggingRight = false;

  /// Display mode for selection visualization
  /// 0: Semi-transparent overlay
  /// 1: Lens effect - reveals color underneath grey
  late int _displayMode;
  late double _transparencyPercent; // For mode 0

  /// Cached layout: how many words per row based on actual word widths
  List<int>? _cachedWordsPerRow;

  /// Last width used for layout calculation (to detect when recalculation needed)
  double? _lastLayoutWidth;

  /// Helper to get row height including spacing
  double get _rowHeightWithSpacing => widget.config.cellHeight + widget.config.rowSpacing;

  /// Calculates which day index corresponds to a global position
  /// Dynamically handles varying row lengths
  int? _getDayIndexFromPosition(double globalX, double globalY, {bool isStartHandle = true}) {
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localPos = renderBox.globalToLocal(Offset(globalX, globalY));
    return _getDayIndexFromLocalPosition(localPos.dx, localPos.dy, isStartHandle: isStartHandle);
  }

  /// Calculates which day index corresponds to a local position (relative to calendar container)
  /// Used during dragging to determine which row the cursor is over
  /// [isStartHandle] - true for left handle, false for right handle (affects snapping behavior)
  int? _getDayIndexFromLocalPosition(double localX, double localY, {bool isStartHandle = true}) {
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final totalWidth = renderBox.size.width;

    if (localX < 0 || localX > totalWidth) return null;

    // Calculate rows based on word count
    final wordsPerRow = _getWordsPerRow();
    if (wordsPerRow.isEmpty || words.isEmpty) return null;

    int currentY = 0;
    int currentIdx = 0;

    for (int rowIdx = 0; rowIdx < wordsPerRow.length; rowIdx++) {
      final rowHeight = 50;
      final rowSpacing = 8;
      final rowEnd = currentY + rowHeight;

      // Check if in this row or in the spacing after it (snap to this row)
      final nextRowStart = rowEnd + rowSpacing;
      final isInRowOrSpacing =
          localY >= currentY && (localY < nextRowStart || rowIdx == wordsPerRow.length - 1);

      if (isInRowOrSpacing) {
        // Found the row
        final wordsInRow = wordsPerRow[rowIdx];
        final dayWidth = totalWidth / wordsInRow;
        final positionInRow = localX / dayWidth;
        final cellIndex = positionInRow.floor().clamp(0, wordsInRow - 1);

        // Calculate position within the cell (0.0 to 1.0)
        final positionInCell = positionInRow - cellIndex;

        // Snapping logic depends on which handle is being dragged:
        // - Left handle (isStart: true) positions at LEFT edge of returned word
        // - Right handle (isStart: false) positions at RIGHT edge of returned word
        int wordIdx = cellIndex;

        if (isStartHandle) {
          // Left handle: if >= 50% into cell, snap to right edge by returning next word
          if (positionInCell >= 0.5 && currentIdx + cellIndex + 1 < words.length) {
            wordIdx = cellIndex + 1;
          }
        } else {
          // Right handle: if < 50% into cell, snap to left edge by returning previous word
          if (positionInCell < 0.5 && cellIndex > 0) {
            wordIdx = cellIndex - 1;
          }
        }

        final idx = currentIdx + wordIdx;
        return idx.clamp(0, words.length - 1);
      }

      currentIdx += wordsPerRow[rowIdx];
      currentY = nextRowStart;
    }

    // If below all rows, return last word
    return words.length - 1;
  }

  /// Calculates dynamic word layout based on actual word widths
  /// Returns list of word counts per row
  List<int> _calculateWordLayout(double availableWidth) {
    if (words.isEmpty) return [];

    final minCellWidth = widget.config.minCellWidth;
    final maxCellWidth = widget.config.maxCellWidth;
    final horizontalPadding = widget.config.rowSpacing;

    // Calculate width needed for each word
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    List<double> wordWidths = [];
    for (String word in words) {
      textPainter.text = TextSpan(
        text: word,
        style: TextStyle(fontSize: widget.config.fontSize, fontWeight: widget.config.fontWeight),
      );
      textPainter.layout();
      // Cell width = text width + padding, clamped to min/max
      final cellWidth = (textPainter.width + widget.config.cellPadding).clamp(
        minCellWidth,
        maxCellWidth,
      );
      wordWidths.add(cellWidth);
    }

    // Pack words into rows based on available width
    List<int> rowCounts = [];
    int currentRowWords = 0;
    double currentRowWidth = 0.0;

    for (int i = 0; i < words.length; i++) {
      final wordWidth = wordWidths[i];
      final neededWidth = currentRowWords == 0
          ? wordWidth
          : currentRowWidth + horizontalPadding + wordWidth;

      if (neededWidth <= availableWidth) {
        // Word fits in current row
        currentRowWords++;
        currentRowWidth = neededWidth;
      } else {
        // Start new row
        if (currentRowWords > 0) {
          rowCounts.add(currentRowWords);
        }
        currentRowWords = 1;
        currentRowWidth = wordWidth;
      }
    }

    // Add last row
    if (currentRowWords > 0) {
      rowCounts.add(currentRowWords);
    }

    return rowCounts.isEmpty ? [words.length] : rowCounts;
  }

  /// Gets cached or calculates words per row layout
  List<int> _getWordsPerRow({double? width}) {
    // If width provided and different from last, recalculate
    if (width != null && width != _lastLayoutWidth) {
      _cachedWordsPerRow = _calculateWordLayout(width);
      _lastLayoutWidth = width;
    }

    // Return cached layout or fallback to single row
    return _cachedWordsPerRow ?? [words.length];
  }

  /// Gets the row index and position within row for a given word index
  (int row, int posInRow, int wordsInRow) _getRowInfo(int wordIdx) {
    final wordsPerRow = _getWordsPerRow();
    if (wordsPerRow.isEmpty) {
      return (0, 0, 1);
    }

    // Clamp to valid range
    wordIdx = wordIdx.clamp(0, words.length - 1);

    int currentIdx = 0;

    for (int rowIdx = 0; rowIdx < wordsPerRow.length; rowIdx++) {
      if (wordIdx < currentIdx + wordsPerRow[rowIdx]) {
        return (rowIdx, wordIdx - currentIdx, wordsPerRow[rowIdx]);
      }
      currentIdx += wordsPerRow[rowIdx];
    }

    // Fallback: return last row's last position
    final lastRowIdx = wordsPerRow.length - 1;
    final lastRowWords = wordsPerRow[lastRowIdx];
    return (lastRowIdx, lastRowWords - 1, lastRowWords);
  }

  /// Builds a single day cell - layout depends on display mode
  Widget _buildDayCell(int idx, String word) {
    final isSelected = idx >= selectedStart && idx <= selectedEnd;

    if (_displayMode == 1) {
      // Mode 1: Lens effect - grey cells that become transparent when selected
      return Expanded(
        child: Container(
          height: widget.config.cellHeight,
          decoration: BoxDecoration(
            color: isSelected
                ? widget.config.selectedCellBackgroundColor
                : widget.config.cellBackgroundColor,
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
          ),
        ),
      );
    } else {
      // Mode 0: Grey cells with text inline
      return Expanded(
        child: Container(
          height: widget.config.cellHeight,
          decoration: BoxDecoration(
            color: widget.config.cellBackgroundColor,
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
          ),
          child: Center(
            child: Text(
              word,
              style: TextStyle(
                fontSize: widget.config.fontSize,
                fontWeight: widget.config.fontWeight,
                color: widget.config.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }
  }

  /// Builds draggable handles as overlay
  Widget _buildHandles() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        // Calculate handle positions based on selectedStart and selectedEnd
        final (leftY, leftX) = _getHandlePosition(selectedStart, totalWidth, isStart: true);
        final (rightY, rightX) = _getHandlePosition(selectedEnd, totalWidth, isStart: false);

        double leftHandleX = leftX;
        double leftHandleY = leftY;
        double rightHandleX = rightX;
        double rightHandleY = rightY;

        // Override with drag position if dragging
        if (_isDraggingLeft && _leftHandleDragPosition != null) {
          final RenderBox? renderBox =
              _containerKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPos = renderBox.globalToLocal(_leftHandleDragPosition!);
            leftHandleX = localPos.dx;
            // Snap Y to row (locked in box)
            final idx = _getDayIndexFromLocalPosition(
              localPos.dx,
              localPos.dy,
              isStartHandle: true,
            );
            if (idx != null) {
              final (row, _, _) = _getRowInfo(idx);
              leftHandleY = row * _rowHeightWithSpacing;
            }
          }
        }

        if (_isDraggingRight && _rightHandleDragPosition != null) {
          final RenderBox? renderBox =
              _containerKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPos = renderBox.globalToLocal(_rightHandleDragPosition!);
            rightHandleX = localPos.dx;
            // Snap Y to row (locked in box)
            final idx = _getDayIndexFromLocalPosition(
              localPos.dx,
              localPos.dy,
              isStartHandle: false,
            );
            if (idx != null) {
              final (row, _, _) = _getRowInfo(idx);
              rightHandleY = row * _rowHeightWithSpacing;
            }
          }
        }

        return Stack(
          children: [
            // Blue fill between handles (for all modes)
            ..._buildBlueFill(leftHandleX, leftHandleY, rightHandleX, rightHandleY, totalWidth),

            // Left handle
            Positioned(
              left: leftHandleX,
              top: leftHandleY,
              child: GestureDetector(
                key: _leftHandleKey,
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDraggingLeft = true;
                    _leftHandleDragPosition = details.globalPosition;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _leftHandleDragPosition = details.globalPosition;
                  });
                },
                onHorizontalDragEnd: (details) {
                  final newIdx = _getDayIndexFromPosition(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    isStartHandle: true,
                  );
                  setState(() {
                    _isDraggingLeft = false;
                    _leftHandleDragPosition = null;
                    if (newIdx != null && newIdx <= selectedEnd && newIdx < words.length) {
                      selectedStart = newIdx;
                      widget.onSelectionChanged?.call(selectedStart, selectedEnd);
                    }
                  });
                },
                child: Container(
                  width: widget.config.handleSize / 2,
                  height: widget.config.cellHeight,
                  decoration: BoxDecoration(
                    color: widget.config.handleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.config.borderRadius),
                      bottomLeft: Radius.circular(widget.config.borderRadius),
                    ),
                    border: Border.all(color: widget.config.handleBorderColor, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '⋮',
                      style: TextStyle(color: widget.config.handleBorderColor, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),

            // Right handle
            Positioned(
              left: rightHandleX - (widget.config.handleSize / 2),
              top: rightHandleY,
              child: GestureDetector(
                key: _rightHandleKey,
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDraggingRight = true;
                    _rightHandleDragPosition = details.globalPosition;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _rightHandleDragPosition = details.globalPosition;
                  });
                },
                onHorizontalDragEnd: (details) {
                  final newIdx = _getDayIndexFromPosition(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    isStartHandle: false,
                  );
                  setState(() {
                    _isDraggingRight = false;
                    _rightHandleDragPosition = null;
                    if (newIdx != null && newIdx >= selectedStart && newIdx < words.length) {
                      selectedEnd = newIdx;
                      widget.onSelectionChanged?.call(selectedStart, selectedEnd);
                    }
                  });
                },
                child: Container(
                  width: widget.config.handleSize / 2,
                  height: widget.config.cellHeight,
                  decoration: BoxDecoration(
                    color: widget.config.handleColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(widget.config.borderRadius),
                      bottomRight: Radius.circular(widget.config.borderRadius),
                    ),
                    border: Border.all(color: widget.config.handleBorderColor, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '⋮',
                      style: TextStyle(color: widget.config.handleBorderColor, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Gets the handle position (Y, X) for a given word index
  (double, double) _getHandlePosition(int wordIdx, double totalWidth, {required bool isStart}) {
    if (words.isEmpty) {
      return (0.0, 0.0);
    }

    // Clamp to valid range
    wordIdx = wordIdx.clamp(0, words.length - 1);

    final (row, posInRow, wordsInRow) = _getRowInfo(wordIdx);
    final dayWidth = totalWidth / wordsInRow;
    final y = row * _rowHeightWithSpacing;
    final x = isStart ? posInRow * dayWidth : (posInRow + 1) * dayWidth;

    return (y, x);
  }

  /// Builds mode 1 reveal layer - tube-shaped blue layer that shows through transparent grey cells
  List<Widget> _buildMode1RevealLayer(double totalWidth) {
    List<Widget> fills = [];

    // Calculate handle positions (same logic as _buildHandles)
    final (leftY, leftX) = _getHandlePosition(selectedStart, totalWidth, isStart: true);
    final (rightY, rightX) = _getHandlePosition(selectedEnd, totalWidth, isStart: false);

    double leftHandleX = leftX;
    double leftHandleY = leftY;
    double rightHandleX = rightX;
    double rightHandleY = rightY;

    // Override with drag position if dragging
    if (_isDraggingLeft && _leftHandleDragPosition != null) {
      final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPos = renderBox.globalToLocal(_leftHandleDragPosition!);
        leftHandleX = localPos.dx;
        final idx = _getDayIndexFromPosition(localPos.dx, localPos.dy);
        if (idx != null) {
          final (row, _, _) = _getRowInfo(idx);
          leftHandleY = row * _rowHeightWithSpacing;
        }
      }
    }

    if (_isDraggingRight && _rightHandleDragPosition != null) {
      final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPos = renderBox.globalToLocal(_rightHandleDragPosition!);
        rightHandleX = localPos.dx;
        final idx = _getDayIndexFromPosition(localPos.dx, localPos.dy);
        if (idx != null) {
          final (row, _, _) = _getRowInfo(idx);
          rightHandleY = row * _rowHeightWithSpacing;
        }
      }
    }

    final halfHandle = widget.config.handleSize / 2;

    // Build tube-shaped blue reveal layer
    if (leftHandleY == rightHandleY) {
      // Same row - simple rectangle
      fills.add(
        Positioned(
          left: leftHandleX + halfHandle,
          top: leftHandleY,
          width: (rightHandleX - halfHandle) - (leftHandleX + halfHandle),
          height: widget.config.cellHeight,
          child: Container(color: widget.config.selectionColor),
        ),
      );
    } else {
      // Different rows - continuous tube across rows
      fills.add(
        Positioned(
          left: leftHandleX + halfHandle,
          top: leftHandleY,
          width: totalWidth - (leftHandleX + halfHandle),
          height: widget.config.cellHeight,
          child: Container(color: widget.config.selectionColor),
        ),
      );

      // Fill middle rows completely (if any)
      double currentY = leftHandleY + _rowHeightWithSpacing;
      while (currentY < rightHandleY) {
        fills.add(
          Positioned(
            left: 0,
            top: currentY,
            width: totalWidth,
            height: widget.config.cellHeight,
            child: Container(color: widget.config.selectionColor),
          ),
        );
        currentY += _rowHeightWithSpacing;
      }

      fills.add(
        Positioned(
          left: 0,
          top: rightHandleY,
          width: rightHandleX - halfHandle,
          height: widget.config.cellHeight,
          child: Container(color: widget.config.selectionColor),
        ),
      );
    }

    return fills;
  }

  /// Builds text overlay for mode 1 (above blue fill)
  List<Widget> _buildTextOverlay(double totalWidth) {
    List<Widget> textWidgets = [];
    final wordsPerRow = _getWordsPerRow();
    int currentIdx = 0;

    for (int rowIdx = 0; rowIdx < wordsPerRow.length; rowIdx++) {
      final wordsInRow = wordsPerRow[rowIdx];
      final cellWidth = totalWidth / wordsInRow;
      final cellTop = rowIdx * _rowHeightWithSpacing;

      for (int posInRow = 0; posInRow < wordsInRow; posInRow++) {
        final idx = currentIdx + posInRow;
        if (idx >= words.length) break;

        final isSelected = idx >= selectedStart && idx <= selectedEnd;
        final cellLeft = posInRow * cellWidth;

        textWidgets.add(
          Positioned(
            left: cellLeft,
            top: cellTop,
            width: cellWidth,
            height: widget.config.cellHeight,
            child: IgnorePointer(
              child: Center(
                child: Text(
                  words[idx],
                  style: TextStyle(
                    fontSize: widget.config.fontSize,
                    fontWeight: widget.config.fontWeight,
                    color: isSelected ? widget.config.selectedTextColor : widget.config.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }

      currentIdx += wordsInRow;
    }

    return textWidgets;
  }

  /// Builds blue fill rectangles between handles
  List<Widget> _buildBlueFill(
    double leftX,
    double leftY,
    double rightX,
    double rightY,
    double totalWidth,
  ) {
    List<Widget> fills = [];
    final halfHandle = widget.config.handleSize / 2;

    if (_displayMode == 0) {
      // Mode 0: Transparent continuous overlay
      final opacity = _transparencyPercent / 100.0;

      if (leftY == rightY) {
        // Same row - simple rectangle
        fills.add(
          Positioned(
            left: leftX + halfHandle,
            top: leftY,
            width: (rightX - halfHandle) - (leftX + halfHandle),
            height: widget.config.cellHeight,
            child: Container(color: widget.config.selectionColor.withValues(alpha: opacity)),
          ),
        );
      } else {
        // Different rows
        fills.add(
          Positioned(
            left: leftX + halfHandle,
            top: leftY,
            width: totalWidth - (leftX + halfHandle),
            height: widget.config.cellHeight,
            child: Container(color: widget.config.selectionColor.withValues(alpha: opacity)),
          ),
        );

        // Fill middle rows completely (if any)
        double currentY = leftY + _rowHeightWithSpacing;
        while (currentY < rightY) {
          fills.add(
            Positioned(
              left: 0,
              top: currentY,
              width: totalWidth,
              height: widget.config.cellHeight,
              child: Container(color: widget.config.selectionColor.withValues(alpha: opacity)),
            ),
          );
          currentY += _rowHeightWithSpacing;
        }

        fills.add(
          Positioned(
            left: 0,
            top: rightY,
            width: rightX - halfHandle,
            height: widget.config.cellHeight,
            child: Container(color: widget.config.selectionColor.withValues(alpha: opacity)),
          ),
        );
      }
    }
    // Mode 1: No blue fill from handles - _buildMode1RevealLayer handles it

    return fills;
  }

  /// Shows dialog to add a new word
  void _showAddWordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Word'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Word', hintText: 'Enter a word'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  words.add(controller.text.trim());
                  // Clear layout cache
                  _cachedWordsPerRow = null;
                  _lastLayoutWidth = null;
                  // Adjust selection if needed
                  if (selectedStart >= words.length) selectedStart = words.length - 1;
                  if (selectedEnd >= words.length) selectedEnd = words.length - 1;
                });
                widget.onWordsChanged?.call(words);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog to edit a word at specific index
  void _showEditWordDialog(int index) {
    final controller = TextEditingController(text: words[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Word #${index + 1}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Word'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  words[index] = controller.text.trim();
                  // Clear layout cache since word width changed
                  _cachedWordsPerRow = null;
                  _lastLayoutWidth = null;
                });
                widget.onWordsChanged?.call(words);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog to move a word to a different position
  void _showMoveWordDialog(int fromIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move "${words[fromIndex]}" (Position ${fromIndex + 1})'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'New Position', hintText: '1 to ${words.length}'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPos = int.tryParse(controller.text.trim());
              if (newPos != null && newPos >= 1 && newPos <= words.length) {
                setState(() {
                  final word = words.removeAt(fromIndex);
                  words.insert(newPos - 1, word);
                  // Clear layout cache since word order changed
                  _cachedWordsPerRow = null;
                  _lastLayoutWidth = null;
                  // Adjust selection if needed
                  if (selectedStart >= words.length) selectedStart = words.length - 1;
                  if (selectedEnd >= words.length) selectedEnd = words.length - 1;
                });
                widget.onWordsChanged?.call(words);
                Navigator.pop(context);
              }
            },
            child: const Text('Move'),
          ),
        ],
      ),
    );
  }

  /// Builds the item grid dynamically
  Widget _buildItemGrid(double availableWidth) {
    final wordsPerRow = _getWordsPerRow(width: availableWidth);
    List<Widget> rows = [];
    int currentIdx = 0;

    for (int rowIdx = 0; rowIdx < wordsPerRow.length; rowIdx++) {
      final wordsInRow = wordsPerRow[rowIdx];
      List<Widget> rowWidgets = [];

      for (int posInRow = 0; posInRow < wordsInRow; posInRow++) {
        final idx = currentIdx + posInRow;
        if (idx >= words.length) break;
        rowWidgets.add(_buildDayCell(idx, words[idx]));
      }

      rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: rowWidgets));

      currentIdx += wordsInRow;

      // Add spacing between rows (except last row)
      if (rowIdx < wordsPerRow.length - 1) {
        rows.add(SizedBox(height: widget.config.rowSpacing));
      }
    }

    return Column(children: rows);
  }

  /// Calculates total height needed for grid
  double _calculateGridHeight() {
    final wordsPerRow = _getWordsPerRow();
    return (wordsPerRow.length * widget.config.cellHeight) +
        ((wordsPerRow.length - 1) * widget.config.rowSpacing);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: widget.config.containerPadding,
        child: Column(
          children: [
            // Optional header with title and add button
            if (widget.title != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.showManagementUI)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddWordDialog,
                      tooltip: 'Add Word',
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (widget.showManagementUI) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddWordDialog,
                  tooltip: 'Add Word',
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'Draggable Range Selector (Add/Edit/Move Items)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Item grid with dynamic layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: _calculateGridHeight(),
                child: Container(
                  key: _containerKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      return Stack(
                        children: [
                          // Base item cells
                          _buildItemGrid(totalWidth),
                          // Mode 1: Tube-shaped blue reveal layer
                          if (_displayMode == 1) ..._buildMode1RevealLayer(totalWidth),
                          // Text overlay for mode 1
                          if (_displayMode == 1) ..._buildTextOverlay(totalWidth),
                          // Handles and blue fill overlay
                          _buildHandles(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            if (widget.showManagementUI) ...[
              const SizedBox(height: 30),

              // Word management actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddWordDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Word'),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedStart < words.length
                        ? () => _showEditWordDialog(selectedStart)
                        : null,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Start Word'),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedEnd < words.length
                        ? () => _showEditWordDialog(selectedEnd)
                        : null,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit End Word'),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedStart < words.length
                        ? () => _showMoveWordDialog(selectedStart)
                        : null,
                    icon: const Icon(Icons.move_up, size: 18),
                    label: const Text('Move Start Word'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (words.isNotEmpty)
                Text(
                  'Selected: ${words[selectedStart]} - ${words[selectedEnd]} (${selectedEnd - selectedStart + 1} words)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              // Display mode controls
              const Text(
                'Display Mode:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _displayMode = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _displayMode == 0 ? widget.config.selectionColor : null,
                      foregroundColor: _displayMode == 0 ? Colors.white : null,
                    ),
                    child: const Text('Transparent'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _displayMode = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _displayMode == 1 ? widget.config.selectionColor : null,
                      foregroundColor: _displayMode == 1 ? Colors.white : null,
                    ),
                    child: const Text('Lens'),
                  ),
                ],
              ),

              // Transparency slider (only for mode 0)
              if (_displayMode == 0) ...[
                const SizedBox(height: 20),
                Text(
                  'Transparency: ${_transparencyPercent.toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _transparencyPercent,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_transparencyPercent.toInt()}%',
                  onChanged: (value) => setState(() => _transparencyPercent = value),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
