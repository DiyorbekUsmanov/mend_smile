import 'package:flutter/material.dart';
import '../../../data/patient_firebase.dart';
import '../../../utils/AppColors.dart';

class QaPage extends StatefulWidget {
  const QaPage({super.key});

  @override
  State<QaPage> createState() => _QaPageState();
}

class _QaPageState extends State<QaPage> {
  bool _loading = true;
  bool _alreadySubmitted = false;

  double painLevel = 0;
  String? painTime;
  double swellingReduction = 1;
  List<String> eatingIssues = [];
  String? weightChange;
  String? weightLossAmount;
  bool? hygieneIssue;
  String hygieneDetails = '';
  List<String> speakingIssues = [];
  String faceMovementLimit = '';
  double lipSymptoms = 1;
  String? sleepChange;
  double overallHealth = 5;
  String medicalVisits = '';
  String? doctorInstructionsFollow;
  String psychologicalState = '';
  String? returnToWork;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkIfSubmitted();
  }

  Future<void> _checkIfSubmitted() async {
    final canSubmit = await PatientFirebaseService.instance.canSubmitQA();
    setState(() {
      _alreadySubmitted = !canSubmit;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      await PatientFirebaseService.instance.submitQA(
        painLevel: painLevel,
        painTime: painTime!,
        swellingReduction: swellingReduction,
        eatingIssues: eatingIssues,
        weightChange: weightChange!,
        weightLossAmount: weightLossAmount ?? '',
        hygieneIssue: hygieneIssue!,
        hygieneDetails: hygieneDetails,
        speakingIssues: speakingIssues,
        faceMovementLimit: faceMovementLimit,
        lipSymptoms: lipSymptoms,
        sleepChange: sleepChange!,
        overallHealth: overallHealth,
        medicalVisits: medicalVisits,
        doctorInstructionsFollow: doctorInstructionsFollow!,
        psychologicalState: psychologicalState,
        returnToWork: returnToWork!,
      );

      setState(() {
        _alreadySubmitted = true;
        _loading = false;
      });

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Submitted'),
          content: Text('Your answers have been sent to the doctor.'),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_alreadySubmitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily QA'), backgroundColor: AppColors().primary),
        body: const Center(child: Text('✅ Already submitted for today.\nCome back tomorrow.', textAlign: TextAlign.center)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily QA'), backgroundColor: AppColors().primary),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sliderQuestion('1. Og‘riq darajasi (0–10)', painLevel, (v) => setState(() => painLevel = v), max: 10),
            _dropdownQuestion('2. Og‘riq qachon ko‘proq seziladi?', ['tongda', 'ovqatlanayotganda', 'gaplashayotganda', 'dam olayotganda', 'boshqalar'], (val) => setState(() => painTime = val), painTime),
            _sliderQuestion('3. Yuzda shish kamayishi (1–10)', swellingReduction, (v) => setState(() => swellingReduction = v), min: 1, max: 10),
            _multiSelectQuestion('4. Ovqatlanishdagi muammolar', ['suyuqlik to‘kilib ketishi', 'og‘izda og‘riq', 'boshqalar'], eatingIssues),
            _dropdownQuestion('5. Tana vazni o‘zgarishi', ['o‘zgarmadi', 'kamaydi', 'keskin kamaydi'], (val) => setState(() => weightChange = val), weightChange),
            _textQuestion('6. Kamaysa, qancha massani yo‘qotdingiz?', (val) => weightLossAmount = val),
            _yesNoQuestion('7. Og‘iz gigiyenasi muammosi bormi?', (val) => setState(() => hygieneIssue = val), hygieneIssue),
            if (hygieneIssue == true) _textQuestion('8. Agar ha bo‘lsa, qanday?', (val) => hygieneDetails = val),
            _multiSelectQuestion('9. Gapirishdagi noqulayliklar', ['talaffuz buzilishi', 'og‘riq', 'toliqish', 'yo‘q'], speakingIssues),
            _textQuestion('10. Yuz harakatlaridagi cheklovlar', (val) => faceMovementLimit = val),
            _sliderQuestion('11. Pastki lab belgilari (1–10)', lipSymptoms, (v) => setState(() => lipSymptoms = v), min: 1, max: 10),
            _dropdownQuestion('12. Uyqu sifati qanday o‘zgardi?', ['yaxshilandi', 'yomonlashdi', 'o‘zgarmadi'], (val) => setState(() => sleepChange = val), sleepChange),
            _sliderQuestion('13. Umumiy holatingiz (1–10)', overallHealth, (v) => setState(() => overallHealth = v), min: 1, max: 10),
            _textQuestion('14. Qaysi shifokorga murojaat qildingiz?', (val) => medicalVisits = val),
            _dropdownQuestion('15. Tavsiyalarga amal qilish darajasi', ['100%', 'qisman', 'qilmayapman'], (val) => setState(() => doctorInstructionsFollow = val), doctorInstructionsFollow),
            _textQuestion('16. Psixologik holatingiz qanday?', (val) => psychologicalState = val),
            _dropdownQuestion('17. Ishga/o‘qishga qaytish imkoniyati', ['ha', 'yo‘q', 'qisman'], (val) => setState(() => returnToWork = val), returnToWork),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  Widget _sliderQuestion(String title, double value, void Function(double) onChanged, {double min = 0, double max = 10}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), label: value.toStringAsFixed(0), onChanged: onChanged),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dropdownQuestion(String title, List<String> items, void Function(String?) onChanged, String? currentVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        DropdownButtonFormField<String>(
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          value: currentVal,
          onChanged: onChanged,
          hint: const Text('Tanlang'), // 👈 Hint added here
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _multiSelectQuestion(String title, List<String> options, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...options.map((e) => CheckboxListTile(
          value: selected.contains(e),
          title: Text(e),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selected.add(e);
              } else {
                selected.remove(e);
              }
            });
          },
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _yesNoQuestion(String title, void Function(bool) onChanged, bool? currentVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: RadioListTile(value: true, groupValue: currentVal, title: const Text('Ha'), onChanged: (val) => onChanged(true))),
            Expanded(child: RadioListTile(value: false, groupValue: currentVal, title: const Text('Yo‘q'), onChanged: (val) => onChanged(false))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _textQuestion(String title, void Function(String) onSaved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(onSaved: (val) => onSaved(val ?? ''), decoration: const InputDecoration(hintText: 'Yozing...')),
        const SizedBox(height: 16),
      ],
    );
  }
}
