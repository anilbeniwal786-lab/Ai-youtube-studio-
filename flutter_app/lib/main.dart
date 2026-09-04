import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StudioApp());
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI YouTube Studio',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String backendUrl =
      'https://ai-youtube-studio.onrender.com';

  final topic = TextEditingController();

  String videoType = 'short';
  String aspect = '9:16';
  String style = 'Cinematic 3D';
  String status = 'Ready';
  bool busy = false;

  Map<String, dynamic>? project;

  List<Map<String, dynamic>> makeStory(String raw) {
    final t = raw.trim().isEmpty ? 'एक प्रेरणादायक कहानी' : raw.trim();

    return [
      {
        'scene': 1,
        'title': 'शुरुआत',
        'narration': '$t की कहानी शुरू होती है।',
        'dialogue': 'आज कुछ बड़ा करने का समय है।',
        'image_prompt':
            'Cinematic 3D scene about $t, dramatic lighting, detailed environment',
      },
      {
        'scene': 2,
        'title': 'मुश्किल',
        'narration':
            'रास्ते में उसे कई मुश्किलों और चुनौतियों का सामना करना पड़ा।',
        'dialogue': 'मुश्किल है, लेकिन मैं हार नहीं मानूंगा।',
        'image_prompt':
            'Cinematic 3D dramatic challenge scene about $t, emotional atmosphere',
      },
      {
        'scene': 3,
        'title': 'फैसला',
        'narration':
            'उसने हिम्मत जुटाई और अपनी पूरी ताकत से आगे बढ़ने का फैसला किया।',
        'dialogue': 'मैं कोशिश जारी रखूंगा।',
        'image_prompt':
            'Cinematic 3D heroic decision scene, inspiring mood, $t',
      },
      {
        'scene': 4,
        'title': 'सफलता',
        'narration':
            'लगातार मेहनत के बाद आखिरकार उसकी मेहनत रंग लाई।',
        'dialogue': 'मेहनत कभी बेकार नहीं जाती।',
        'image_prompt':
            'Cinematic 3D success scene, beautiful lighting, emotional ending, $t',
      },
    ];
  }

  Future<void> createStory() async {
    if (busy) return;

    if (topic.text.trim().isEmpty) {
      setState(() => status = 'पहले Topic लिखें');
      return;
    }

    setState(() {
      busy = true;
      status = 'कहानी बनाई जा रही है...';
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      project = {
        'title': topic.text.trim(),
        'video_type': videoType,
        'aspect_ratio': aspect,
        'style': style,
        'scenes': makeStory(topic.text),
      };
      busy = false;
      status = 'Story Ready';
    });
  }

  Future<void> generateMedia() async {
    if (busy) return;

    if (project == null) {
      setState(() => status = 'पहले Story बनाएं');
      return;
    }

    setState(() {
      busy = true;
      status = 'AI Images + Hindi Voice बनाई जा रही है...';
    });

    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/generate-media'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(project),
          )
          .timeout(const Duration(minutes: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          project = Map<String, dynamic>.from(data);
          status = 'Images + Voice Ready';
          busy = false;
        });
      } else {
        throw Exception(
          'Server Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        busy = false;
        status = 'Error: $e';
      });
    }
  }

  Widget sceneCard(Map<String, dynamic> scene) {
    final imageUrl = scene['image_url']?.toString();
    final audioUrl = scene['audio_url']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scene ${scene['scene'] ?? ''}: ${scene['title'] ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(scene['narration']?.toString() ?? ''),
            if ((scene['dialogue'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Dialogue: ${scene['dialogue']}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 80,
                    child: Center(child: Text('Image loading failed')),
                  ),
                ),
              ),
            ],
            if (audioUrl != null && audioUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Hindi Voice: तैयार',
                style: TextStyle(
                  color: Colors.green.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenes = (project?['scenes'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI YouTube Studio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: topic,
              decoration: const InputDecoration(
                labelText: 'Video Topic',
                hintText: 'जैसे: धोखेबाज़ भाई का सर्वनाश',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: videoType,
              decoration: const InputDecoration(
                labelText: 'Video Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'short', child: Text('YouTube Short')),
                DropdownMenuItem(value: 'long', child: Text('Long Video')),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => videoType = v ?? 'short'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: aspect,
              decoration: const InputDecoration(
                labelText: 'Aspect Ratio',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '9:16', child: Text('9:16 Vertical')),
                DropdownMenuItem(value: '16:9', child: Text('16:9 YouTube')),
                DropdownMenuItem(value: '1:1', child: Text('1:1 Square')),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => aspect = v ?? '9:16'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: style,
              decoration: const InputDecoration(
                labelText: 'Visual Style',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Cinematic 3D',
                  child: Text('Cinematic 3D'),
                ),
                DropdownMenuItem(
                  value: 'Realistic',
                  child: Text('Realistic'),
                ),
                DropdownMenuItem(
                  value: 'Anime',
                  child: Text('Anime'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => style = v ?? 'Cinematic 3D'),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: busy ? null : createStory,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create AI Story + Dialogues'),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: busy ? null : generateMedia,
              icon: const Icon(Icons.movie_creation),
              label: const Text('Generate AI Images + Hindi Voice'),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(Icons.check_circle),
                    const SizedBox(width: 10),
                    Expanded(child: Text(status)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            if (project != null)
              Text(
                project?['title']?.toString() ?? 'Your Project',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 10),

            ...scenes.map(
              (scene) => sceneCard(
                Map<String, dynamic>.from(scene as Map),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    topic.dispose();
    super.dispose();
  }
}
