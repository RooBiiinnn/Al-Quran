import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/quran.png'),
          const Text('Englisgting You...'),
          const SizedBox(
            height: 10,
          ),
          const CircularProgressIndicator()
        ],
      ),
    );
  }
}
