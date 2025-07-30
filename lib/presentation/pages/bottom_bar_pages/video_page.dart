import 'package:flutter/material.dart';
import 'package:mend_smile/utils/AppColors.dart';
import '../../../data/patient_firebase.dart';
import '../video_player_page.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final List<Map<String, String>> videos = const [
    {
      'title': 'Jaw Relaxation',
      'videoPath': 'assets/videos/ex1.mp4',
      'description':
          'Gentle movements to help relax jaw muscles and reduce tension.',
    },
    {
      'title': 'Neck Stretching',
      'videoPath': 'assets/videos/ex2.mp4',
      'description': 'Loosens the neck muscles that often affect jaw comfort.',
    },
    {
      'title': 'Jaw Opening Exercise',
      'videoPath': 'assets/videos/ex3.mp4',
      'description': 'Trains proper jaw opening without overexertion.',
    },
    {
      'title': 'Tongue Push-Ups',
      'videoPath': 'assets/videos/ex4.mp4',
      'description':
          'Strengthens the tongue and jaw coordination post-surgery.',
    },
    {
      'title': 'Side-to-Side Jaw Movement',
      'videoPath': 'assets/videos/ex5.mp4',
      'description':
          'Improves lateral movement of the jaw to restore flexibility.',
    },
    {
      'title': 'Cheek Massage',
      'videoPath': 'assets/videos/ex6.mp4',
      'description':
          'Stimulates circulation and reduces stiffness in jaw muscles.',
    },
    {
      'title': 'Controlled Jaw Clenching',
      'videoPath': 'assets/videos/ex7.mp4',
      'description': 'Improves bite control and muscle awareness.',
    },
    {
      'title': 'Breathing and Relaxation',
      'videoPath': 'assets/videos/ex8.mp4',
      'description': 'Helps calm the nervous system and relax facial tension.',
    },
    {
      'title': 'Circular Jaw Motion',
      'videoPath': 'assets/videos/ex9.mp4',
      'description': 'Boosts jaw mobility and loosens tight muscles.',
    },
    {
      'title': 'Lip Closure Practice',
      'videoPath': 'assets/videos/ex10.mp4',
      'description': 'Reinforces proper lip positioning after surgery.',
    },
    {
      'title': 'Soft Food Chewing Exercise',
      'videoPath': 'assets/videos/ex11.mp4',
      'description': 'Practices chewing with minimal stress using soft foods.',
    },
    {
      'title': 'Posture Alignment',
      'videoPath': 'assets/videos/ex12.mp4',
      'description': 'Corrects head and neck posture to reduce jaw strain.',
    },
  ];

  final Map<String, bool> completedVideos = {};
  DateTime? _lastCompletedDay;

  @override
  void initState() {
    super.initState();
    _loadStatusFromFirebase();
  }

  void _loadStatusFromFirebase() async {
    final statusMap = await PatientFirebaseService.instance.loadVideoStatusForToday();
    setState(() {
      completedVideos.clear();
      for (var video in videos) {
        completedVideos[video['title']!] = statusMap[video['title']!] ?? false;
      }
      _lastCompletedDay = DateTime.now();
    });
  }


  void _resetIfNeeded() {
    final today = DateTime.now();
    if (_lastCompletedDay == null || !_isSameDay(today, _lastCompletedDay!)) {
      completedVideos.clear();
      for (var video in videos) {
        completedVideos[video['title']!] = false;
      }
      _lastCompletedDay = today;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _allCompleted => completedVideos.values.every((e) => e == true);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayIndex = today.weekday % 7; // Sunday=0, Monday=1...

    return Scaffold(
      appBar: AppBar(title: const Text('Video Therapy'), backgroundColor: AppColors().primary,),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWeekCalendar(todayIndex),
          const SizedBox(height: 16),
          const Text(
            "Today's Plan",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...videos.map((video) {
            final isDone = completedVideos[video['title']] == true;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.ondemand_video,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  video['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow, size: 32),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>VideoPlayerPage(
                              title: video['title']!,
                              videoPath: video['videoPath']!,
                              description: video['description']!,
                              isAlreadyDone: completedVideos[video['title']] == true,
                            )

                          ),
                        );

                        if (result == true) {
                          setState(() {
                            completedVideos[video['title']!] = true;
                          });
                          await PatientFirebaseService.instance.saveVideoStatusForToday(completedVideos);
                        }
                      },
                    ),
                    Icon(
                      Icons.check_circle,
                      color: isDone ? Colors.green : Colors.grey.shade300,
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(int todayIndex) {
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isToday = i == todayIndex;

        return Column(
          children: [
            Text(
              weekDays[i],
              style: TextStyle(color: isToday ? Colors.blue : Colors.black54),
            ),
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 14,
              backgroundColor: isToday && _allCompleted
                  ? Colors.green
                  : Colors.grey.shade300,
              child: isToday && _allCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${DateTime.now().subtract(Duration(days: todayIndex - i)).day}',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
