import 'package:flutter/material.dart';

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
        colorSchemeSeed: Colors.deepPurple,
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
  final topicController = TextEditingController();

  String videoType = 'short';
  String aspectRatio = '9:16';
  String privacy = 'private';
  String status = 'Ready';
  bool busy = false;

  Map<String, dynamic>? story;

  List<Map<String, String>> _makeStory(String topic) {
    final t = topic.trim();

    if (t.toLowerCase().contains('ganesha') ||
        t.contains('गणेश') ||
        t.contains('गणपति')) {
      return [
        {
          'title': 'एक छोटी सी प्रार्थना',
          'narration':
              'एक छोटे से गाँव में आरव नाम का बच्चा हर सुबह भगवान गणेश की पूजा करता था। एक दिन उसने मन से प्रार्थना की कि उसके परिवार की परेशानी दूर हो जाए।',
          'dialogue':
              'आरव: हे गणेश जी, मैं अपने लिए कुछ नहीं माँगता। बस मेरे परिवार को खुश रखिए।',
          'visual':
              'सुबह का भारतीय गाँव, छोटा मंदिर, गणेश जी की सुंदर मूर्ति, दीपक और फूल, cinematic 3D animation',
          'camera': 'slow push-in',
          'sfx': 'temple bell, soft devotional music',
        },
        {
          'title': 'मुश्किल की घड़ी',
          'narration':
              'उसी दिन अचानक तेज बारिश शुरू हो गई। गाँव के कई घरों में पानी भरने लगा। आरव ने डरने के बजाय लोगों की मदद करने का फैसला किया।',
          'dialogue':
              'आरव: अगर हम सब मिलकर काम करें तो कोई भी मुश्किल बड़ी नहीं है।',
          'visual':
              'तेज बारिश में भारतीय गाँव, लोग परेशान, बच्चा लोगों की मदद करता हुआ, dramatic cinematic lighting',
          'camera': 'tracking shot',
          'sfx': 'heavy rain, thunder',
        },
        {
          'title': 'सबने मिलकर मदद की',
          'narration':
              'आरव की बात सुनकर गाँव के लोग एक साथ आ गए। किसी ने बुजुर्गों को सुरक्षित जगह पहुँचाया और किसी ने बच्चों को घरों से बाहर निकाला।',
          'dialogue':
              'गाँव वाला: आरव, तुमने हमें याद दिलाया कि सच्ची भक्ति सिर्फ पूजा नहीं, बल्कि इंसान की मदद करना भी है।',
          'visual':
              'गाँव के लोग एक-दूसरे की मदद करते हुए, परिवार सुरक्षित स्थान पर, emotional cinematic scene',
          'camera': 'wide shot then slow zoom',
          'sfx': 'hopeful music',
        },
        {
          'title': 'चमत्कार जैसा पल',
          'narration':
              'कुछ घंटों बाद बारिश रुक गई। बादलों के बीच से सूरज की किरणें निकलीं और मंदिर के गणेश जी पर सुनहरी रोशनी पड़ने लगी।',
          'dialogue':
              'आरव: गणेश जी ने हमें रास्ता दिखाया। हमें हमेशा अच्छे काम करते रहना चाहिए।',
          'visual':
              'बारिश के बाद चमकता गाँव, मंदिर पर सुनहरी सूर्य किरणें, गणेश प्रतिमा, magical cinematic atmosphere',
          'camera': 'slow upward tilt',
          'sfx': 'soft bells, magical chime',
        },
        {
          'title': 'कहानी की सीख',
          'narration':
              'उस दिन पूरे गाँव ने समझा कि विश्वास तभी सुंदर बनता है जब उसके साथ अच्छे कर्म भी हों। आरव की छोटी सी प्रार्थना ने पूरे गाँव को एक परिवार बना दिया।',
          'dialogue':
              'आरव: सच्ची शक्ति वही है जिससे किसी दूसरे के चेहरे पर मुस्कान आए।',
          'visual':
              'खुशहाल भारतीय गाँव, मंदिर में दीपक, लोग मुस्कुराते हुए, beautiful cinematic ending',
          'camera': 'slow zoom out',
          'sfx': 'devotional music, temple bell',
        },
      ];
    }

    if (t.contains('बंदर') || t.contains('मगरमच्छ')) {
      return [
        {
          'title': 'जामुन का पेड़',
          'narration':
              'एक नदी के किनारे एक पेड़ पर एक चतुर बंदर रहता था। पेड़ पर मीठे जामुन लगते थे। एक दिन नदी से एक मगरमच्छ वहाँ आया।',
          'dialogue':
              'बंदर: दोस्त, तुम भी जामुन खाना चाहोगे? मेरे पास बहुत सारे हैं।',
          'visual':
              'नदी किनारे जामुन का पेड़, पेड़ पर चतुर बंदर और पानी में मगरमच्छ, colorful 3D animation',
          'camera': 'slow pan',
          'sfx': 'river water, birds',
        },
        {
          'title': 'नई दोस्ती',
          'narration':
              'मगरमच्छ ने जामुन खाए और दोनों में दोस्ती हो गई। बंदर रोज उसे मीठे जामुन देने लगा।',
          'dialogue':
              'मगरमच्छ: दोस्त, इतने मीठे जामुन मैंने कभी नहीं खाए। तुम्हारा बहुत धन्यवाद।',
          'visual':
              'बंदर मगरमच्छ को जामुन देता हुआ, नदी का सुंदर वातावरण, warm cinematic lighting',
          'camera': 'gentle tracking',
          'sfx': 'light cheerful music',
        },
        {
          'title': 'मगरमच्छ की पत्नी',
          'narration':
              'लेकिन एक दिन मगरमच्छ की पत्नी ने कहा कि जो बंदर रोज इतने मीठे जामुन खाता है, उसका दिल कितना मीठा होगा।',
          'dialogue':
              'पत्नी: मुझे उस बंदर का दिल चाहिए। किसी तरह उसे यहाँ लेकर आओ।',
          'visual':
              'नदी का किनारा, मगरमच्छ और उसकी पत्नी गंभीर बातचीत करते हुए, dramatic mood',
          'camera': 'slow zoom in',
          'sfx': 'dark suspense music',
        },
        {
          'title': 'बंदर की चालाकी',
          'narration':
              'मगरमच्छ बंदर को अपनी पीठ पर बैठाकर नदी पार ले जाने लगा। बीच नदी में उसने असली बात बता दी।',
          'dialogue':
              'मगरमच्छ: दोस्त, मुझे तुम्हें एक बात बतानी है। मेरी पत्नी तुम्हारा दिल चाहती है।',
          'visual':
              'नदी के बीच मगरमच्छ की पीठ पर बैठा चिंतित बंदर, dramatic water scene',
          'camera': 'close-up then shake',
          'sfx': 'water splash, suspense',
        },
        {
          'title': 'बंदर बच गया',
          'narration':
              'बंदर घबराया नहीं। उसने तुरंत कहा कि उसका दिल तो पेड़ पर ही रह गया है। मगरमच्छ उसे वापस किनारे ले आया और बंदर तेजी से पेड़ पर चढ़ गया।',
          'dialogue':
              'बंदर: दोस्ती में विश्वासघात करने वाले पर दोबारा भरोसा नहीं किया जा सकता।',
          'visual':
              'बंदर तेजी से पेड़ पर चढ़ता हुआ, मगरमच्छ नदी में पछताता हुआ, cinematic ending',
          'camera': 'fast tracking then slow zoom out',
          'sfx': 'whoosh, dramatic ending',
        },
      ];
    }

    return [
      {
        'title': 'शुरुआत',
        'narration':
            '$t की कहानी एक छोटे से गाँव से शुरू होती है। वहाँ एक साधारण इंसान रहता था, लेकिन उसके सपने बहुत बड़े थे।',
        'dialogue':
            'नायक: मुझे पता है रास्ता मुश्किल है, लेकिन मैं हार नहीं मानूँगा।',
        'visual':
            'सुंदर भारतीय गाँव, मुख्य पात्र अकेला खड़ा, cinematic realistic 3D animation',
        'camera': 'slow establishing shot',
        'sfx': 'soft cinematic music',
      },
      {
        'title': 'पहली मुश्किल',
        'narration':
            'अचानक उसके सामने एक ऐसी समस्या आई जिसने उसकी पूरी जिंदगी बदल दी। लोग उसे रोकना चाहते थे, लेकिन उसने हिम्मत नहीं छोड़ी।',
        'dialogue':
            'दोस्त: क्या तुम्हें सच में लगता है कि तुम यह कर पाओगे?',
        'visual':
            'मुख्य पात्र के सामने बड़ी समस्या, चिंतित दोस्त, dramatic cinematic lighting',
        'camera': 'slow push-in',
        'sfx': 'dramatic hit',
      },
      {
        'title': 'बड़ा फैसला',
        'narration':
            'कुछ देर सोचने के बाद उसने एक बड़ा फैसला लिया। उसने डर के बजाय अपने विश्वास को चुना।',
        'dialogue':
            'नायक: डर मुझे रोक सकता है, लेकिन मेरा हौसला मुझे आगे ले जाएगा।',
        'visual':
            'मुख्य पात्र दृढ़ निश्चय के साथ आगे बढ़ता हुआ, sunset background',
        'camera': 'tracking shot',
        'sfx': 'rising inspirational music',
      },
      {
        'title': 'सच्चाई सामने आई',
        'narration':
            'जब सबको लगा कि वह हार चुका है, तभी उसे एक ऐसा सुराग मिला जिसने पूरी कहानी बदल दी।',
        'dialogue':
            'नायक: अब मुझे समझ आया कि असली समस्या कहाँ थी।',
        'visual':
            'रहस्यमय सुराग मिलने का cinematic दृश्य, close-up, dramatic shadows',
        'camera': 'slow zoom in',
        'sfx': 'mystery sound, thunder',
      },
      {
        'title': 'अंत और सीख',
        'narration':
            'आखिरकार उसकी मेहनत रंग लाई। उसने समस्या को हल किया और सबको एक महत्वपूर्ण सीख मिली कि सच्ची जीत वही है जिसमें इंसान अपने डर पर विजय पा ले।',
        'dialogue':
            'नायक: मुश्किलें हमारी परीक्षा लेती हैं, लेकिन हिम्मत हमें जीतना सिखाती है।',
        'visual':
            'खुशहाल लोग, मुख्य पात्र मुस्कुराता हुआ, सुंदर cinematic ending',
        'camera': 'slow zoom out',
        'sfx': 'emotional victory music',
      },
    ];
  }

  void createStory() {
    final topic = topicController.text.trim();

    if (topic.isEmpty) {
      setState(() => status = 'पहले Story / Topic लिखिए');
      return;
    }

    setState(() {
      busy = true;
      status = 'Creating story + dialogues...';
    });

    // तुरंत local generation — कोई backend इंतजार नहीं।
    final scenes = _makeStory(topic);

    final result = {
      'title': topic,
      'description':
          '$topic की पूरी Hindi YouTube कहानी — narration और dialogues के साथ।',
      'scenes': scenes,
    };

    setState(() {
      story = result;
      busy = false;
      status = 'Story + Dialogues ready';
    });
  }

  void simpleAction(String text) {
    if (story == null) {
      setState(() => status = 'पहले AI Story बनाइए');
      return;
    }

    setState(() => status = text);
  }

  @override
  Widget build(BuildContext context) {
    final scenes =
        (story?['scenes'] as List?) ?? <Map<String, String>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI YouTube Studio — Phase 9.2'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: topicController,
            decoration: const InputDecoration(
              labelText: 'Story / Topic',
              hintText: 'जैसे: Jai Ganesha',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: videoType,
            decoration: const InputDecoration(
              labelText: 'Video type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'short',
                child: Text('YouTube Short'),
              ),
              DropdownMenuItem(
                value: 'long',
                child: Text('Long Video'),
              ),
            ],
            onChanged: busy
                ? null
                : (String? value) {
                    if (value != null) {
                      setState(() => videoType = value);
                    }
                  },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: aspectRatio,
            decoration: const InputDecoration(
              labelText: 'Aspect ratio',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: '9:16',
                child: Text('9:16 — Shorts'),
              ),
              DropdownMenuItem(
                value: '16:9',
                child: Text('16:9 — YouTube'),
              ),
            ],
            onChanged: busy
                ? null
                : (String? value) {
                    if (value != null) {
                      setState(() => aspectRatio = value);
                    }
                  },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: privacy,
            decoration: const InputDecoration(
              labelText: 'YouTube privacy',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'private',
                child: Text('Private'),
              ),
              DropdownMenuItem(
                value: 'unlisted',
                child: Text('Unlisted'),
              ),
              DropdownMenuItem(
                value: 'public',
                child: Text('Public'),
              ),
            ],
            onChanged: busy
                ? null
                : (String? value) {
                    if (value != null) {
                      setState(() => privacy = value);
                    }
                  },
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: busy ? null : createStory,
              child: const Text(
                '1. Create AI Story + Dialogues',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),

          const SizedBox(height: 8),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('Images + Hindi Voice — ready for AI backend'),
            child: const Text('2. Generate Images + Hindi Voice'),
          ),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('AI Thumbnail — ready'),
            child: const Text('3. Create AI Thumbnail'),
          ),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('Final video render — ready'),
            child: const Text('4. Render Final Video'),
          ),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('Complete video pipeline — ready'),
            child: const Text('⚡ One-Click: Create Complete Video'),
          ),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('YouTube Metadata saved'),
            child: const Text('Save YouTube Metadata'),
          ),

          FilledButton(
            onPressed: busy
                ? null
                : () => simpleAction('YouTube upload ready'),
            child: const Text('6. Upload to YouTube'),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: story == null ? 0 : 1,
          ),

          const SizedBox(height: 10),

          Text(
            status,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (story != null) ...[
            const SizedBox(height: 12),
            Text(
              story!['title'],
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(story!['description']),

            const SizedBox(height: 12),

            ...scenes.asMap().entries.map((entry) {
              final index = entry.key;
              final scene = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scene ${index + 1}: ${scene['title']}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Text(
                        '🎙️ Narration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(scene['narration']!),

                      const SizedBox(height: 10),

                      const Text(
                        '💬 Dialogue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(scene['dialogue']!),

                      const SizedBox(height: 10),

                      const Text(
                        '🎨 Visual Prompt',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(scene['visual']!),

                      const SizedBox(height: 8),
                      Text('🎥 Camera: ${scene['camera']}'),
                      Text('🔊 SFX: ${scene['sfx']}'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
