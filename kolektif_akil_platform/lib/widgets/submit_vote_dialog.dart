import 'package:flutter/material.dart';

class SubmitVoteDialog extends StatelessWidget {
  final String option;
  final VoidCallback onConfirm;

  const SubmitVoteDialog({
    super.key,
    required this.option,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Oy Gönder'),
      content: Text('Seçenek $option için oyunuzu göndermek istediğinizden emin misiniz?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Gönder'),
        ),
      ],
    );
  }
}

