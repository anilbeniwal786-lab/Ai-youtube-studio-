import 'package:flutter/material.dart';

void main() => runApp(const StudioApp());

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI YouTube Studio — Phase 9.3',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final topic = TextEditingController();
  String videoType = 'short';
  String aspect = '9:16';
  String style = 'Cinematic 3D';
  String status = 'Ready';
  bool busy = false;
  Map<String, dynamic>? project;

  @override
  void dispose() { topic.dispose(); super.dispose(); }

  Map<String, dynamic> makeStory(String raw) {
    final t = raw.trim().isEmpty ? 'एक प्रेरणादायक कहानी' : raw.trim();
    final long = videoType == 'long';
    final scenes = <Map<String, String>>[
      {'n':'1','title':'शुरुआत','narration':'$t की कहानी एक छोटे से गाँव से शुरू होती है। वहाँ एक साधारण इंसान अपने बड़े सपने को पूरा करने के लिए हर दिन मेहनत करता था।','dialogue':'नायक: “मैं हार नहीं मानूँगा। चाहे रास्ता कितना भी मुश्किल क्यों न हो।”','characters':'नायक, गाँव के लोग','visual':'cinematic realistic 3D animation, Indian village, main character, sunrise, expressive face, consistent character design','camera':'slow cinematic push-in','sfx':'soft morning ambience, birds'},
      {'n':'2','title':'समस्या','narration':'अचानक उसके सामने एक बड़ी परेशानी आ गई। लोग उसे समझाने लगे कि यह काम उसके बस की बात नहीं है, लेकिन उसने उम्मीद नहीं छोड़ी।','dialogue':'मित्र: “तुम अकेले यह कैसे करोगे?”\nनायक: “कोशिश करने वाला कभी सच में अकेला नहीं होता।”','characters':'नायक, मित्र','visual':'cinematic 3D scene, worried friend talking to hero, emotional expressions, Indian environment, dramatic lighting','camera':'medium shot with slow side tracking','sfx':'subtle tension music'},
      {'n':'3','title':'बड़ा मोड़','narration':'जब सब कुछ खत्म होता दिखाई दे रहा था, तभी एक अनपेक्षित मौका उसके सामने आया। अब फैसला उसे खुद करना था।','dialogue':'नायक: “शायद यही वह मौका है जिसका मैं इंतज़ार कर रहा था।”\nबुज़ुर्ग: “डर को अपने फैसले पर हावी मत होने देना।”','characters':'नायक, बुज़ुर्ग','visual':'dramatic cinematic 3D animation, hero meeting wise elder, warm lantern light, emotional close-up','camera':'slow zoom toward faces','sfx':'deep cinematic hit, light wind'},
      {'n':'4','title':'संघर्ष','narration':'नायक ने पूरी ताकत से कोशिश की। रास्ते में कई मुश्किलें आईं, लेकिन हर मुश्किल ने उसे और मजबूत बना दिया।','dialogue':'नायक: “गिरना मेरी हार नहीं है। उठकर फिर चलना ही मेरी असली जीत है।”\nमित्र: “अब मुझे तुम पर पूरा भरोसा है।”','characters':'नायक, मित्र','visual':'epic cinematic 3D animation, hero overcoming obstacles, dust, dramatic sky, strong emotions, consistent characters','camera':'tracking shot followed by slow push-in','sfx':'rising cinematic music, footsteps'},
      {'n':'5','title':'जीत और संदेश','narration':'आखिरकार उसकी मेहनत रंग लाई। उसने अपनी मंज़िल हासिल की और पूरे गाँव को एक सीख दी—सच्ची लगन और हिम्मत के सामने मुश्किलें छोटी पड़ जाती हैं।','dialogue':'नायक: “अगर दिल में विश्वास हो, तो कोई भी सपना असंभव नहीं।”\nमित्र: “आज तुमने हम सबको उम्मीद करना सिखा दिया।”','characters':'नायक, मित्र, गाँव के लोग','visual':'beautiful cinematic 3D village celebration, happy characters, golden sunset, emotional ending, consistent character design','camera':'slow wide pull-back','sfx':'uplifting music, crowd ambience'},
    ];
    if (long) {
      scenes.addAll([
        {'n':'6','title':'नई चुनौती','narration':'सफलता के बाद एक नई चुनौती सामने आई। इस बार उसे अपने साथ दूसरों को भी आगे बढ़ाना था।','dialogue':'मित्र: “अब आगे क्या?”\nनायक: “अब मेरी जीत सिर्फ मेरी नहीं होगी।”','characters':'नायक, मित्र','visual':'cinematic 3D village, heroes planning together, detailed expressions','camera':'slow orbit shot','sfx':'hopeful music'},
        {'n':'7','title':'साथ','narration':'उसने लोगों को साथ लिया और सभी ने मिलकर मुश्किल रास्ते को आसान बनाना शुरू किया।','dialogue':'गाँववाला: “हम भी तुम्हारे साथ हैं।”\nनायक: “तो फिर यह काम जरूर पूरा होगा।”','characters':'नायक, गाँववाले','visual':'group of Indian villagers working together, cinematic 3D, warm light','camera':'wide tracking shot','sfx':'work ambience'},
        {'n':'8','title':'सबसे कठिन पल','narration':'सबसे कठिन समय में एक गलती से पूरी मेहनत खतरे में पड़ गई।','dialogue':'नायक: “गलती हुई है, लेकिन अभी सब खत्म नहीं हुआ।”','characters':'नायक','visual':'dramatic close-up, worried hero, stormy cinematic background','camera':'subtle handheld shake','sfx':'thunder, dramatic impact'},
        {'n':'9','title':'समाधान','narration':'नायक ने घबराने के बजाय शांत दिमाग से समाधान खोजा और सबने मिलकर समस्या को ठीक कर दिया।','dialogue':'मित्र: “हमने कर दिखाया!”\nनायक: “क्योंकि हमने साथ मिलकर कोशिश की।”','characters':'नायक, मित्र, गाँववाले','visual':'victory moment, cinematic 3D, joyful faces, golden light','camera':'slow crane-up','sfx':'victory music'},
        {'n':'10','title':'अंतिम संदेश','narration':'उस दिन सबने समझा कि असली सफलता अकेले आगे बढ़ने में नहीं, बल्कि दूसरों को साथ लेकर आगे बढ़ने में है।','dialogue':'नायक: “याद रखो—हिम्मत, मेहनत और साथ हो तो कोई रास्ता बंद नहीं होता।”','characters':'नायक, सभी पात्र','visual':'epic sunset ending, Indian village, all characters together, cinematic 3D','camera':'slow cinematic pull-back','sfx':'emotional ending music'},
      ]);
    }
    return {'title':t,'description':'$t पर तैयार हिंदी कहानी, narration और पात्रों के dialogues.','scenes':scenes};
  }

  void createStory() {
    if (busy) return;
    if (topic.text.trim().isEmpty) { setState(() => status='पहले Story / Topic लिखें'); return; }
    setState(() { busy=true; status='कहानी और dialogues तैयार हो रहे हैं...'; });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() { project=makeStory(topic.text); busy=false; status='Story + Dialogues ready'; });
    });
  }

  void feature(String text) {
    setState(() => status = project == null ? 'पहले कहानी बनाइए' : text);
  }

  @override
  Widget build(BuildContext context) {
    final scenes = (project?['scenes'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('AI YouTube Studio — Phase 9.3')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: topic, decoration: const InputDecoration(
          labelText:'Story / Topic', hintText:'जैसे: Jai Ganesha, धोखेबाज़ भाई, बंदर और मगरमच्छ',
          border:OutlineInputBorder())),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(
          value:videoType, decoration:const InputDecoration(labelText:'Video type',border:OutlineInputBorder()),
          items:const [
            DropdownMenuItem(value:'short',child:Text('YouTube Short — 5 Scenes')),
            DropdownMenuItem(value:'long',child:Text('Long Video — 10 Scenes'))],
          onChanged:busy?null:(String? v){if(v!=null)setState(()=>videoType=v);}),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(
          value:aspect, decoration:const InputDecoration(labelText:'Aspect ratio',border:OutlineInputBorder()),
          items:const [DropdownMenuItem(value:'9:16',child:Text('9:16 — Shorts')),DropdownMenuItem(value:'16:9',child:Text('16:9 — YouTube'))],
          onChanged:busy?null:(String? v){if(v!=null)setState(()=>aspect=v);}),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(
          value:style, decoration:const InputDecoration(labelText:'Visual style',border:OutlineInputBorder()),
          items:const [DropdownMenuItem(value:'Cinematic 3D',child:Text('Cinematic 3D')),DropdownMenuItem(value:'Realistic',child:Text('Realistic')),DropdownMenuItem(value:'Anime',child:Text('Anime'))],
          onChanged:busy?null:(String? v){if(v!=null)setState(()=>style=v);}),
        const SizedBox(height:10),
        FilledButton.icon(onPressed:busy?null:createStory,icon:const Icon(Icons.auto_awesome),label:const Text('1. Create AI Story + Dialogues')),
        FilledButton(onPressed:busy?null:()=>feature('Images + Hindi Voice के लिए backend/API जोड़ना होगा.'),child:const Text('2. Generate Images + Hindi Voice')),
        FilledButton(onPressed:busy?null:()=>feature('AI Thumbnail के लिए image generation backend जोड़ना होगा.'),child:const Text('3. Create AI Thumbnail')),
        FilledButton(onPressed:busy?null:()=>feature('Final video render के लिए rendering backend जोड़ना होगा.'),child:const Text('4. Render Final Video')),
        FilledButton(onPressed:busy?null:()=>feature('One-Click production के लिए images, voice और render backend चाहिए.'),child:const Text('⚡ One-Click: Create Complete Video')),
        FilledButton(onPressed:busy?null:()=>feature('YouTube metadata तैयार है.'),child:const Text('Save YouTube Metadata')),
        FilledButton(onPressed:busy?null:()=>feature('YouTube upload के लिए Google/YouTube authorization जोड़ना होगा.'),child:const Text('6. Upload to YouTube')),
        const SizedBox(height:10),
        LinearProgressIndicator(value:project==null?0:1),
        const SizedBox(height:8),
        Text(status,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w600)),
        if(project!=null) ...[
          const SizedBox(height:12),
          Text(project!['title'] as String,style:Theme.of(context).textTheme.headlineSmall),
          Text(project!['description'] as String),
          const SizedBox(height:10),
          ...scenes.map((x) {
            final s=x as Map<String,String>;
            return Card(margin:const EdgeInsets.only(bottom:12),child:Padding(
              padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Row(children:[CircleAvatar(child:Text(s['n']??'')),const SizedBox(width:10),
                  Expanded(child:Text('Scene ${s['n']}: ${s['title']}',style:Theme.of(context).textTheme.titleLarge))]),
                const SizedBox(height:10),
                const Text('🎙️ Narration',style:TextStyle(fontWeight:FontWeight.bold)),Text(s['narration']??''),
                const SizedBox(height:8),
                const Text('💬 Dialogues',style:TextStyle(fontWeight:FontWeight.bold)),Text(s['dialogue']??''),
                const SizedBox(height:8),
                const Text('👤 Characters',style:TextStyle(fontWeight:FontWeight.bold)),Text(s['characters']??''),
                const SizedBox(height:8),
                const Text('🎨 Visual Prompt',style:TextStyle(fontWeight:FontWeight.bold)),Text(s['visual']??''),
                const SizedBox(height:8),
                Text('🎥 Camera: ${s['camera']??''}'),Text('🔊 SFX: ${s['sfx']??''}')
              ])));
          })
        ]
      ]),
    );
  }
}
