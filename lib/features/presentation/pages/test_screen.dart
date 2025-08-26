import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () => _showBottomSheet(context),
            child: Text('Show bottom sheet'),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: false, // <-- убираем, т.к. сами обернем
      isScrollControlled:
          true, // <-- чтобы занял всю высоту экрана при необходимости
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('123'),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
