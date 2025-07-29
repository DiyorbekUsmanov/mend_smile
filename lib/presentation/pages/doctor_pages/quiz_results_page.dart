import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
    final quizId = extra['quizId'] as String;
    final data = extra['quizData'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Natijalar - $quizId'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _resultTile("1. Og‘riq darajasi", data['painLevel']?.toString()),
          _resultTile("2. Og‘riq qachon ko‘proq seziladi?", data['painTime']),
          _resultTile("3. Yuzdagi shish kamayishi", data['swellingReduction']?.toString()),
          _resultTile("4. Ovqatlanishdagi muammolar", _listToText(data['eatingIssues'])),
          _resultTile("5. Tana vazni o‘zgarishi", data['weightChange']),
          _resultTile("6. Yo‘qotilgan massa (kg)", data['weightLossAmount']),
          _resultTile("7. Og‘iz gigiyenasi muammosi", data['hygieneIssue'] == true ? 'Ha' : 'Yo‘q'),
          _resultTile("8. Tafsilotlari", data['hygieneDetails']),
          _resultTile("9. Gapirishdagi noqulayliklar", _listToText(data['speakingIssues'])),
          _resultTile("10. Yuz harakatlari cheklovi", data['faceMovementLimit']),
          _resultTile("11. Pastki lab alomatlari", data['lipSymptoms']?.toString()),
          _resultTile("12. Uyqu sifati o‘zgarishi", data['sleepChange']),
          _resultTile("13. Umumiy holat", data['overallHealth']?.toString()),
          _resultTile("14. Tibbiy murojaatlar", data['medicalVisits']),
          _resultTile("15. Tavsiyalarga amal qilish", data['doctorInstructionsFollow']),
          _resultTile("16. Psixologik holat", data['psychologicalState']),
          _resultTile("17. Ish/o‘qishga qaytish imkoniyati", data['returnToWork']),
          _resultTile("Yuborilgan vaqti", (data['submittedAt'] as Timestamp?)?.toDate().toLocal().toString()),
        ],
      ),
    );
  }

  Widget _resultTile(String question, String? answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(answer == null || answer.isEmpty ? '-' : answer),
        ),
      ),
    );
  }

  String _listToText(dynamic list) {
    if (list is List && list.isNotEmpty) {
      return list.join(', ');
    }
    return '-';
  }
}
