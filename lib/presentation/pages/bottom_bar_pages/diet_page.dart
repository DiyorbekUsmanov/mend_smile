import 'package:flutter/material.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Surgery Diet Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Diet Stages After Jaw Surgery',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 16),

          _stageCard(
            title: '🍼 Liquid Diet (Days 1–7)',
            details: [
              'Water, broths, clear soups',
              'Protein shakes, smoothies',
              'No chewing allowed',
            ],
          ),

          _stageCard(
            title: '🥣 Soft Diet (Days 8–14)',
            details: [
              'Mashed potatoes, scrambled eggs',
              'Oatmeal, pureed vegetables',
              'Soft fruits like bananas',
            ],
          ),

          _stageCard(
            title: '🍝 Transition Diet (Days 15–30)',
            details: [
              'Soft pasta, ground meat',
              'Cooked vegetables',
              'Slowly reintroduce more textures',
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            '⚠️ Foods to Avoid',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          _bulletList([
            'Crunchy snacks (chips, nuts)',
            'Sticky foods (caramel, chewing gum)',
            'Spicy or acidic foods (can irritate)',
            'Using a straw (can cause complications)',
          ]),

          const SizedBox(height: 24),
          const Text(
            '✅ General Tips',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          _bulletList([
            'Eat small, frequent meals.',
            'Stay hydrated.',
            'Follow your doctor’s advice.',
            'Chew gently when allowed.',
            'Clean your mouth after meals.',
          ]),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal),
            ),
            child: const Text(
              '"Recovery is a journey. Nourish your body with care, and every day will bring more strength."',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stageCard({required String title, required List<String> details}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...details.map((item) => Row(
              children: [
                const Icon(Icons.check, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      children: items
          .map(
            (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(child: Text(e)),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}
