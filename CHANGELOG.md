## 1.1.0

- Added `fixedItemsPerRow` to `DraggableRangeSelectorConfig` to support fixed-column layouts (for example, 7-day calendar rows).
- Fixed lens mode reveal behavior while dragging so the lens layer tracks handle movement consistently.
- Fixed first-render layout overflow by calculating grid height from the actual available width.
- Updated drag row snap calculations to use configured `cellHeight` and `rowSpacing` instead of hardcoded values.

## 1.0.0+3

- Fix typo in example.

## 1.0.0+2

- Added one GIF as example usage.

## 1.0.0+1

- Fixed pubspec.yaml description length for pub.dev compliance

## 1.0.0

- Initial release of DraggableRangeSelector widget
- Feature: Dynamic grid layout based on actual item widths
- Feature: Draggable handles for intuitive range selection
- Feature: Two display modes - transparent overlay and lens effect
- Feature: Full customization of colors, sizes, and behavior
- Feature: Built-in item management UI (add, edit, move items)
- Feature: Embeddable in any parent container (dialogs, bottom sheets, columns, tabs, etc.)
- Feature: Smooth drag interactions with visual feedback
- Support for Flutter 3.13.0 and higher
- Apache 2.0 License
