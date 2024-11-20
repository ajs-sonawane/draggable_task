import 'dart:developer';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomDraggableIcons(),
    );
  }
}

class CustomDraggableIcons extends StatefulWidget {
  const CustomDraggableIcons({super.key});

  @override
  CustomDraggableIconsState createState() => CustomDraggableIconsState();
}

class CustomDraggableIconsState extends State<CustomDraggableIcons> {
  List<IconData> icons = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  int? draggingIndex;
  Offset? dragOffset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          // fit: StackFit.expand,
          children: [
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Container(
            //         margin: const EdgeInsets.symmetric(
            //             vertical: 12, horizontal: 22),
            //         height: 90,
            //         decoration: BoxDecoration(
            //             color: Colors.black12,
            //             borderRadius: BorderRadius.circular(22)),
            //       ),
            //     ],
            //   ),
            // ),
            ...List.generate(icons.length, (index) {
              final isDragging = draggingIndex == index;
              return AnimatedPositioned(
                duration: isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                left: isDragging && dragOffset != null
                    ? dragOffset!.dx
                    : MediaQuery.of(context).size.width / 2 +
                        (index - icons.length ~/ 2) *
                            80.0, // Space between icons
                top: isDragging && dragOffset != null
                    ? dragOffset!.dy
                    : MediaQuery.of(context).size.height -
                        80, // Default vertical position,
                child: GestureDetector(
                  onPanStart: (details) {
                    log("OFFSET L::: ${details.localPosition}");
                    log("OFFSET G::: ${details.globalPosition}");
                    setState(() {
                      draggingIndex = index;
                      dragOffset = Offset(details.globalPosition.dx - 30,
                          details.globalPosition.dy - 30); // Initial position
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      dragOffset = dragOffset! + details.delta;
                      _updateReordering(details.globalPosition);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      draggingIndex = null;
                      dragOffset = null;
                    });
                  },
                  child: Opacity(
                    opacity: isDragging ? 0.5 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.primaries[
                            index.hashCode % Colors.primaries.length],
                      ),
                      child: Icon(
                        icons[index],
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _updateReordering(Offset globalPosition) {
    final newIndex =
        (globalPosition.dx / 80.0).clamp(0, icons.length).toInt() - 1;
    log("newIndex ::::  $newIndex");
    if (newIndex != draggingIndex) {
      setState(() {
        final draggingIcon = icons[draggingIndex!];
        icons.removeAt(draggingIndex!);
        icons.insert(newIndex, draggingIcon);
        draggingIndex = newIndex;
      });
    }
  }
}
