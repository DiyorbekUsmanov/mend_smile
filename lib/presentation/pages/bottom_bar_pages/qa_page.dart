import 'package:flutter/material.dart';

import '../../../utils/AppColors.dart';


class QaPage extends StatefulWidget {
  const QaPage({super.key});

  @override
  State<QaPage> createState() => _QaPageState();
}

class _QaPageState extends State<QaPage> {
  int? painLevel;
  bool? hasHeadache;
  int? mealsPerDay;
  final TextEditingController _noteCtrl = TextEditingController();

  bool get isComplete =>
      painLevel != null &&
          hasHeadache != null &&
          mealsPerDay != null &&
          _noteCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!isComplete) return;
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Submitted'),
        content: Text('Your answers have been sent to the doctor.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Questionnaire'),
        backgroundColor: AppColors().primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _questionCard(
              icon: Icons.favorite,
              title: '1. Rate your pain at the bottom part of the jaw:',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => painLevel = level),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                      painLevel == level ? AppColors().primary : Colors.grey.shade300,
                      child: Text('$level', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            _questionCard(
              icon: Icons.psychology_alt,
              title: '2. Do you have a headache?',
              child: Row(
                children: [
                  _yesNoButton('Yes', true),
                  const SizedBox(width: 12),
                  _yesNoButton('No', false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _questionCard(
              icon: Icons.restaurant,
              title: '3. How many times a day are you eating food?',
              child: DropdownButtonFormField<int>(
                value: mealsPerDay,
                items: List.generate(6, (index) {
                  final count = index + 1;
                  return DropdownMenuItem(
                      value: count, child: Text('$count times'));
                }),
                onChanged: (val) => setState(() => mealsPerDay = val),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _questionCard(
              icon: Icons.chat,
              title: '4. Is there anything you want to tell the doctor?',
              child: TextField(
                controller: _noteCtrl,
                onChanged: (_) => setState(() {}),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isComplete ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? AppColors().primary : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors().primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _yesNoButton(String label, bool value) {
    final selected = hasHeadache == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => hasHeadache = value),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? AppColors().primary : Colors.grey.shade200,
          foregroundColor: selected ? Colors.white : Colors.black87,
          elevation: selected ? 3 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}
