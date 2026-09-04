import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const StudioApp());

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI YouTube Studio',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final topic = TextEditingController();
  // For a real Android phone, replace this with your reachable backend URL.
  // 10.0.2.2 works for the Android emulator when the backend runs on the PC.
  final base = 'http://10.0.2.2:8000';
  String mode = 'short', style = 'realistic_3d', aspect = '9:16', privacy = 'private', msg = 'Ready';
  Map<String, dynamic>? project;
  double progress = 0;
  bool busy = false;

  Future<http.Response?> _post(String url, {Map<String, dynamic>? body, Duration timeout = const Duration(seconds: 15)}) async {
    try {
      return await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: body == null ? null : jsonEncode(body)).timeout(timeout);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _quickLocalStory(String t) {
    final count = mode == 'short' ? 5 : 10;
    return {
      'project_id': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'title': t.length > 80 ? t.substring(0, 80) : t,
      'description': '$t — AI YouTube Studio',
      'tags': t.split(RegExp(r'\s+')).where((x) => x.isNotEmpty).take(8).toList(),
      'language': 'hi', 'mode': mode, 'style': style,
      'scenes': List.generate(count, (i) => {
        'scene': i + 1,
        'duration': mode == 'short' ? 5 : 7,
        'narration': '$t — दृश्य ${i + 1}: कहानी आगे बढ़ती है और एक नया मोड़ सामने आता है।',
        'visual_prompt': 'cinematic realistic 3D animation, $t, scene ${i + 1}, consistent characters, natural lighting',
        'camera': i.isEven ? 'slow push-in' : 'tracking shot',
        'sfx': 'cinematic whoosh'
      })
    };
  }

  Future<void> createPlan() async {
    final t = topic.text.trim();
    if (t.isEmpty || busy) return;
    setState(() { busy = true; msg = 'Creating story...'; progress = 0.15; });

    final r = await _post('$base/api/project/plan', body: {
      'topic': t, 'mode': mode, 'language': 'hi', 'style': style
    });

    if (!mounted) return;
    if (r?.statusCode == 200) {
      setState(() { project = jsonDecode(r!.body); msg = 'Story ready'; progress = 1; busy = false; });
    } else {
      // Never leave the user stuck on “Creating story...”.
      setState(() { project = _quickLocalStory(t); msg = 'Quick story ready (backend not connected)'; progress = 1; busy = false; });
    }
  }

  Future<void> assets() async {
    if (project == null || busy) return;
    final id = project!['project_id'];
    if (id.toString().startsWith('local-')) {
      setState(() => msg = 'Connect backend first to generate real images + Hindi voice.');
      return;
    }
    setState(() { busy = true; msg = 'Generating images and Hindi voice...'; });
    final r = await _post('$base/api/project/$id/assets', body: {'style': style, 'aspect_ratio': aspect}, timeout: const Duration(seconds: 60));
    if (!mounted) return;
    setState(() { busy = false; msg = r?.statusCode == 200 ? 'Assets ready' : 'Assets error: backend unavailable'; if (r?.statusCode == 200) project = jsonDecode(r!.body); });
  }

  Future<void> thumbnail() async {
    if (project == null || busy) return;
    final id = project!['project_id'];
    setState(() { busy = true; msg = 'Creating thumbnail...'; });
    final r = await _post('$base/api/project/$id/thumbnail', body: {'project_id': id}, timeout: const Duration(seconds: 60));
    if (mounted) setState(() { busy = false; msg = r?.statusCode == 200 ? 'Thumbnail ready' : 'Thumbnail error'; });
  }

  Future<void> render() async {
    if (project == null || busy) return;
    setState(() { busy = true; msg = 'Rendering...'; progress = 0; });
    final r = await _post('$base/api/render', body: {'project_id': project!['project_id'], 'aspect_ratio': aspect}, timeout: const Duration(seconds: 30));
    if (!mounted) return;
    if (r?.statusCode != 200) { setState(() { busy = false; msg = 'Render error: backend unavailable'; }); return; }
    final jid = jsonDecode(r!.body)['job_id'];
    final timer = Timer.periodic(const Duration(seconds: 2), (t) async {
      try {
        final x = await http.get(Uri.parse('$base/api/jobs/$jid')).timeout(const Duration(seconds: 10));
        if (x.statusCode != 200) return;
        final j = jsonDecode(x.body);
        if (mounted) setState(() => progress = ((j['progress'] ?? 0) as num) / 100);
        if (j['status'] == 'done' || j['status'] == 'error') {
          t.cancel();
          if (mounted) setState(() { busy = false; msg = j['status'] == 'done' ? 'Video ready' : 'Render failed: ${j['message']}'; });
        }
      } catch (_) {}
    });
  }

  Future<void> pipeline() async {
    if (project == null || busy) return;
    setState(() { busy = true; msg = 'Running full AI production...'; progress = 0; });
    final id = project!['project_id'];
    final r = await _post('$base/api/pipeline', body: {'project_id': id, 'aspect_ratio': aspect, 'make_thumbnail': true}, timeout: const Duration(seconds: 30));
    if (!mounted) return;
    if (r?.statusCode != 200) { setState(() { busy = false; msg = 'Pipeline error: backend unavailable'; }); return; }
    final jid = jsonDecode(r!.body)['job_id'];
    final timer = Timer.periodic(const Duration(seconds: 2), (t) async {
      try {
        final x = await http.get(Uri.parse('$base/api/jobs/$jid')).timeout(const Duration(seconds: 10));
        if (x.statusCode != 200) return;
        final j = jsonDecode(x.body);
        if (mounted) setState(() => progress = ((j['progress'] ?? 0) as num) / 100);
        if (j['status'] == 'done' || j['status'] == 'error') {
          t.cancel();
          if (j['status'] == 'done') {
            final pr = await http.get(Uri.parse('$base/api/project/$id')).timeout(const Duration(seconds: 10));
            if (pr.statusCode == 200 && mounted) project = jsonDecode(pr.body);
          }
          if (mounted) setState(() { busy = false; msg = j['status'] == 'done' ? 'Full video package ready' : 'Pipeline failed: ${j['message']}'; });
        }
      } catch (_) {}
    });
  }

  Future<void> saveMetadata() async {
    if (project == null || busy) return;
    final id = project!['project_id'];
    final r = await _post('$base/api/project/$id/metadata', body: {'title': project!['title'], 'description': project!['description'], 'tags': project!['tags']});
    if (mounted) setState(() => msg = r?.statusCode == 200 ? 'Metadata saved' : 'Metadata save error');
  }

  Future<void> upload() async {
    if (project == null || busy) return;
    setState(() { busy = true; msg = 'Uploading to YouTube...'; });
    final r = await _post('$base/api/youtube/upload', body: {'project_id': project!['project_id'], 'privacy': privacy, 'category_id': '22', 'upload_captions': true}, timeout: const Duration(seconds: 120));
    if (mounted) setState(() { busy = false; msg = r?.statusCode == 200 ? 'YouTube upload complete' : 'YouTube upload error'; });
  }

  @override
  Widget build(BuildContext c) {
    final scenes = (project?['scenes'] ?? []) as List;
    return Scaffold(
      appBar: AppBar(title: const Text('AI YouTube Studio — Phase 9')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: topic, decoration: const InputDecoration(labelText: 'Story / Topic', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: mode, decoration: const InputDecoration(labelText: 'Video type'), items: const [DropdownMenuItem(value: 'short', child: Text('YouTube Short')), DropdownMenuItem(value: 'long', child: Text('Long Video'))], onChanged: busy ? null : (String? v) { if (v != null) setState(() => mode = v); }),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: aspect, decoration: const InputDecoration(labelText: 'Aspect ratio'), items: const [DropdownMenuItem(value: '9:16', child: Text('9:16 — Shorts')), DropdownMenuItem(value: '16:9', child: Text('16:9 — YouTube'))], onChanged: busy ? null : (String? v) { if (v != null) setState(() => aspect = v); }),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: privacy, decoration: const InputDecoration(labelText: 'YouTube privacy'), items: const [DropdownMenuItem(value: 'private', child: Text('Private')), DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')), DropdownMenuItem(value: 'public', child: Text('Public'))], onChanged: busy ? null : (String? v) { if (v != null) setState(() => privacy = v); }),
        const SizedBox(height: 8),
        FilledButton(onPressed: busy ? null : createPlan, child: const Text('1. Create AI Story')),
        FilledButton(onPressed: busy ? null : assets, child: const Text('2. Generate Images + Hindi Voice')),
        FilledButton(onPressed: busy ? null : thumbnail, child: const Text('3. Create AI Thumbnail')),
        FilledButton(onPressed: busy ? null : render, child: const Text('4. Render Final Video')),
        FilledButton(onPressed: busy ? null : pipeline, child: const Text('⚡ One-Click: Create Complete Video')),
        FilledButton(onPressed: busy ? null : saveMetadata, child: const Text('Save YouTube Metadata')),
        FilledButton(onPressed: busy ? null : upload, child: const Text('6. Upload to YouTube')),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(msg)),
        if (project != null) ...[
          Text(project!['title'] ?? '', style: Theme.of(c).textTheme.titleLarge),
          ...scenes.map((s) => Card(child: ListTile(leading: CircleAvatar(child: Text('${s['scene']}')), title: Text('Scene ${s['scene']}'), subtitle: Text(s['narration'] ?? '', maxLines: 3, overflow: TextOverflow.ellipsis))))
        ]
      ]),
    );
  }
}
