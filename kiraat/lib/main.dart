import 'dart:html';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as Firebase;
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'dart:math';

final fs.Firestore firestore = fb.firestore();

Future<void> main() async {
  if (Firebase.apps.isEmpty)
    Firebase.initializeApp(
      apiKey: "AIzaSyAUMq_r7RkNvrPYV_kZ_SK1-adVMpPy4e0",
      authDomain: "kiraat-855f2.firebaseapp.com",
      databaseURL: "https://kiraat-855f2.firebaseio.com",
      projectId: "kiraat-855f2",
      storageBucket: "kiraat-855f2.appspot.com",
      messagingSenderId: "848372776788",
      appId: "1:848372776788:web:bfd600e961caa74e80d2c1",
    );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "قرائت امتحانى",
      theme: ThemeData(fontFamily: 'Amiri'),
      home: Build(),
    );
  }
}

List<Map<String, dynamic>> list = [];

List<dynamic> sureler;
List<dynamic> seciliSureler;
List<dynamic> sualler;
List<dynamic> ezber;

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class Build extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.collection("kiraat").onSnapshot.map((d) => d.docs.map((doc) => doc.data()).toList()),
      builder: (context, snapshot){
        if(!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          sureler = snapshot.data[0]["sureler"];
          sualler = snapshot.data[0]["sualler"];
          ezber = snapshot.data[0]["ezber"];
          seciliSureler = [];
          sureler.forEach((sure) {
            if (sure["seçili"]) seciliSureler.add(sure);
          });
          return Home();
        }
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String ust, orta, alt;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBar,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(ust ?? "", textAlign: TextAlign.center, style: TextStyle(fontSize: 28)),
                  ),
                  ListTile(
                    title: Text(orta ?? "", textAlign: TextAlign.center, style: TextStyle(fontSize: 28)),
                  ),
                  ListTile(
                    title: Text(alt ?? "", textAlign: TextAlign.center, style: TextStyle(fontSize: 28)),
                  ),
                ],
              ),
            ),

            CupertinoButton(
              onPressed: (){
                if(seciliSureler.isEmpty) {
                  ust = "";
                  orta = "يرجى تحديد السورة أولا";
                  alt = "";
                } else {
                  var secili = seciliSureler[Random().nextInt(seciliSureler.length)];
                  ust = "سورة" + " " + secili["sure"];
                  orta = "الآية" + " - " + arabic(Random().nextInt(secili["ayet"]) + 1);
                  alt = "الصفحة" + " - " + arabic(secili["sayfa"]);
                }
                setState(() {});
              },
              padding: EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("صحيفه", style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: "Amiri"), textAlign: TextAlign.center),
              ),
            ),
            CupertinoButton(
              onPressed: (){
                var rand = Random().nextInt(sualler.length);
                ust = "(" + "سؤال" + " " + arabic(rand + 1) + ")";
                orta = sualler[rand];
                alt = "";
                setState((){});
              },
              padding: EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("تجويد سؤال", style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: "Amiri"), textAlign: TextAlign.center),
              ),
            ),
            CupertinoButton(
              onPressed: (){
                int i = Random().nextInt(ezber.length);
                ust = ezber[i]["konu"];
                orta = ezber[i]["üst"];
                alt = ezber[i]["alt"];
                setState(() {});
              },
              padding: EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("ازبر", style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: "Amiri"), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CupertinoButton(
                    child: Text("أزل الكل", style: TextStyle(fontSize: 24)),
                    onPressed: (){
                      sureler.forEach((sure) {
                        sure["seçili"] = false;
                      });
                      firestore.collection("kiraat").doc("belge").update(data: {"sureler" : sureler});
                    },
                  ),
                  CupertinoButton(
                    child: Text("حدد الكل", style: TextStyle(fontSize: 24)),
                    onPressed: (){
                      sureler.forEach((sure) {
                        sure["seçili"] = true;
                      });
                      firestore.collection("kiraat").doc("belge").update(data: {"sureler" : sureler});
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sureler.length,
                itemBuilder: (c, i){
                  return ListTile(
                    onTap: (){
                      _select(i);
                    },
                    title: Text(arabic(i + 1) + " - " + sureler[i]["sure"], style: TextStyle(fontSize: 20), textDirection: TextDirection.rtl),
                    trailing: Checkbox(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      value: sureler[i]["seçili"],
                      onChanged: (b){
                        _select(i);
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _select(int i){
    sureler[i]["seçili"] = !sureler[i]["seçili"];
    firestore.collection("kiraat").doc("belge").update(data: {"sureler" : sureler});
    setState((){});
  }
}

AppBar _appBar = AppBar(
  title: Text("قرائت امتحانى", style: TextStyle(fontSize: 28)),
  centerTitle: true,
  backgroundColor: Colors.green[900],
  leading: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(Icons.info, color: Colors.white),
    onPressed: (){

    },
  ),
  actions: <Widget>[
    CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Icon(Icons.filter_list, color: Colors.white),
      onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
    ),
  ],
);

String arabic(int num) {
  String str = "";
  for(var i = 0; i < num.toString().length; i++) {
    str += String.fromCharCode(48 + int.parse(num.toString()[i]) + 1584);
  }
  return str;
}

var yasin = [
  "يس",
  "وَالْقُرْآنِ الْحَكِيمِ",
  "إِنَّكَ لَمِنَ الْمُرْسَلِينَ",
  "عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ",
  "تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ",
  "لِتُنْذِرَ قَوْمًا مَا أُنْذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ",
  "لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ",
  "إِنَّا جَعَلْنَا فِي أَعْنَاقِهِمْ أَغْلَالًا فَهِيَ إِلَى الْأَذْقَانِ فَهُمْ مُقْمَحُونَ",
  "وَجَعَلْنَا مِنْ بَيْنِ أَيْدِيهِمْ سَدًّا وَمِنْ خَلْفِهِمْ سَدًّا فَأَغْشَيْنَاهُمْ فَهُمْ لَا يُبْصِرُونَ",
  "وَسَوَاءٌ عَلَيْهِمْ أَأَنْذَرْتَهُمْ أَمْ لَمْ تُنْذِرْهُمْ لَا يُؤْمِنُونَ",
  "إِنَّمَا تُنْذِرُ مَنِ اتَّبَعَ الذِّكْرَ وَخَشِيَ الرَّحْمَٰنَ بِالْغَيْبِ ۖ فَبَشِّرْهُ بِمَغْفِرَةٍ وَأَجْرٍ كَرِيمٍ",
  "إِنَّا نَحْنُ نُحْيِي الْمَوْتَىٰ وَنَكْتُبُ مَا قَدَّمُوا وَآثَارَهُمْ ۚ وَكُلَّ شَيْءٍ أَحْصَيْنَاهُ فِي إِمَامٍ مُبِينٍ",
  "وَاضْرِبْ لَهُمْ مَثَلًا أَصْحَابَ الْقَرْيَةِ إِذْ جَاءَهَا الْمُرْسَلُونَ",
  "إِذْ أَرْسَلْنَا إِلَيْهِمُ اثْنَيْنِ فَكَذَّبُوهُمَا فَعَزَّزْنَا بِثَالِثٍ فَقَالُوا إِنَّا إِلَيْكُمْ مُرْسَلُونَ",
  "قَالُوا مَا أَنْتُمْ إِلَّا بَشَرٌ مِثْلُنَا وَمَا أَنْزَلَ الرَّحْمَٰنُ مِنْ شَيْءٍ إِنْ أَنْتُمْ إِلَّا تَكْذِبُونَ",
  "قَالُوا رَبُّنَا يَعْلَمُ إِنَّا إِلَيْكُمْ لَمُرْسَلُونَ",
  "وَمَا عَلَيْنَا إِلَّا الْبَلَاغُ الْمُبِينُ",
  "قَالُوا إِنَّا تَطَيَّرْنَا بِكُمْ ۖ لَئِنْ لَمْ تَنْتَهُوا لَنَرْجُمَنَّكُمْ وَلَيَمَسَّنَّكُمْ مِنَّا عَذَابٌ أَلِيمٌ",
  "قَالُوا طَائِرُكُمْ مَعَكُمْ ۚ أَئِنْ ذُكِّرْتُمْ ۚ بَلْ أَنْتُمْ قَوْمٌ مُسْرِفُونَ",
  "وَجَاءَ مِنْ أَقْصَى الْمَدِينَةِ رَجُلٌ يَسْعَىٰ قَالَ يَا قَوْمِ اتَّبِعُوا الْمُرْسَلِينَ",
  "اتَّبِعُوا مَنْ لَا يَسْأَلُكُمْ أَجْرًا وَهُمْ مُهْتَدُونَ",
  "وَمَا لِيَ لَا أَعْبُدُ الَّذِي فَطَرَنِي وَإِلَيْهِ تُرْجَعُونَ",
  "أَأَتَّخِذُ مِنْ دُونِهِ آلِهَةً إِنْ يُرِدْنِ الرَّحْمَٰنُ بِضُرٍّ لَا تُغْنِ عَنِّي شَفَاعَتُهُمْ شَيْئًا وَلَا يُنْقِذُونِ",
  "إِنِّي إِذًا لَفِي ضَلَالٍ مُبِينٍ",
  "إِنِّي آمَنْتُ بِرَبِّكُمْ فَاسْمَعُونِ",
  "قِيلَ ادْخُلِ الْجَنَّةَ ۖ قَالَ يَا لَيْتَ قَوْمِي يَعْلَمُونَ",
  "بِمَا غَفَرَ لِي رَبِّي وَجَعَلَنِي مِنَ الْمُكْرَمِينَ",
  "۞ وَمَا أَنْزَلْنَا عَلَىٰ قَوْمِهِ مِنْ بَعْدِهِ مِنْ جُنْدٍ مِنَ السَّمَاءِ وَمَا كُنَّا مُنْزِلِينَ",
  "إِنْ كَانَتْ إِلَّا صَيْحَةً وَاحِدَةً فَإِذَا هُمْ خَامِدُونَ",
  "يَا حَسْرَةً عَلَى الْعِبَادِ ۚ مَا يَأْتِيهِمْ مِنْ رَسُولٍ إِلَّا كَانُوا بِهِ يَسْتَهْزِئُونَ",
  "أَلَمْ يَرَوْا كَمْ أَهْلَكْنَا قَبْلَهُمْ مِنَ الْقُرُونِ أَنَّهُمْ إِلَيْهِمْ لَا يَرْجِعُونَ",
  "وَإِنْ كُلٌّ لَمَّا جَمِيعٌ لَدَيْنَا مُحْضَرُونَ",
  "وَآيَةٌ لَهُمُ الْأَرْضُ الْمَيْتَةُ أَحْيَيْنَاهَا وَأَخْرَجْنَا مِنْهَا حَبًّا فَمِنْهُ يَأْكُلُونَ",
  "وَجَعَلْنَا فِيهَا جَنَّاتٍ مِنْ نَخِيلٍ وَأَعْنَابٍ وَفَجَّرْنَا فِيهَا مِنَ الْعُيُونِ",
  "لِيَأْكُلُوا مِنْ ثَمَرِهِ وَمَا عَمِلَتْهُ أَيْدِيهِمْ ۖ أَفَلَا يَشْكُرُونَ",
  "سُبْحَانَ الَّذِي خَلَقَ الْأَزْوَاجَ كُلَّهَا مِمَّا تُنْبِتُ الْأَرْضُ وَمِنْ أَنْفُسِهِمْ وَمِمَّا لَا يَعْلَمُونَ",
  "وَآيَةٌ لَهُمُ اللَّيْلُ نَسْلَخُ مِنْهُ النَّهَارَ فَإِذَا هُمْ مُظْلِمُونَ",
  "وَالشَّمْسُ تَجْرِي لِمُسْتَقَرٍّ لَهَا ۚ ذَٰلِكَ تَقْدِيرُ الْعَزِيزِ الْعَلِيمِ",
  "وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ حَتَّىٰ عَادَ كَالْعُرْجُونِ الْقَدِيمِ",
  "لَا الشَّمْسُ يَنْبَغِي لَهَا أَنْ تُدْرِكَ الْقَمَرَ وَلَا اللَّيْلُ سَابِقُ النَّهَارِ ۚ وَكُلٌّ فِي فَلَكٍ يَسْبَحُونَ",
  "وَآيَةٌ لَهُمْ أَنَّا حَمَلْنَا ذُرِّيَّتَهُمْ فِي الْفُلْكِ الْمَشْحُونِ",
  "وَخَلَقْنَا لَهُمْ مِنْ مِثْلِهِ مَا يَرْكَبُونَ",
  "وَإِنْ نَشَأْ نُغْرِقْهُمْ فَلَا صَرِيخَ لَهُمْ وَلَا هُمْ يُنْقَذُونَ",
  "إِلَّا رَحْمَةً مِنَّا وَمَتَاعًا إِلَىٰ حِينٍ",
  "وَإِذَا قِيلَ لَهُمُ اتَّقُوا مَا بَيْنَ أَيْدِيكُمْ وَمَا خَلْفَكُمْ لَعَلَّكُمْ تُرْحَمُونَ",
  "وَمَا تَأْتِيهِمْ مِنْ آيَةٍ مِنْ آيَاتِ رَبِّهِمْ إِلَّا كَانُوا عَنْهَا مُعْرِضِينَ",
  "وَإِذَا قِيلَ لَهُمْ أَنْفِقُوا مِمَّا رَزَقَكُمُ اللَّهُ قَالَ الَّذِينَ كَفَرُوا لِلَّذِينَ آمَنُوا أَنُطْعِمُ مَنْ لَوْ يَشَاءُ اللَّهُ أَطْعَمَهُ إِنْ أَنْتُمْ إِلَّا فِي ضَلَالٍ مُبِينٍ",
  "وَيَقُولُونَ مَتَىٰ هَٰذَا الْوَعْدُ إِنْ كُنْتُمْ صَادِقِينَ",
  "مَا يَنْظُرُونَ إِلَّا صَيْحَةً وَاحِدَةً تَأْخُذُهُمْ وَهُمْ يَخِصِّمُونَ",
  "فَلَا يَسْتَطِيعُونَ تَوْصِيَةً وَلَا إِلَىٰ أَهْلِهِمْ يَرْجِعُونَ",
  "وَنُفِخَ فِي الصُّورِ فَإِذَا هُمْ مِنَ الْأَجْدَاثِ إِلَىٰ رَبِّهِمْ يَنْسِلُونَ",
  "قَالُوا يَا وَيْلَنَا مَنْ بَعَثَنَا مِنْ مَرْقَدِنَا ۜ ۗ هَٰذَا مَا وَعَدَ الرَّحْمَٰنُ وَصَدَقَ الْمُرْسَلُونَ",
  "إِنْ كَانَتْ إِلَّا صَيْحَةً وَاحِدَةً فَإِذَا هُمْ جَمِيعٌ لَدَيْنَا مُحْضَرُونَ",
  "فَالْيَوْمَ لَا تُظْلَمُ نَفْسٌ شَيْئًا وَلَا تُجْزَوْنَ إِلَّا مَا كُنْتُمْ تَعْمَلُونَ",
  "إِنَّ أَصْحَابَ الْجَنَّةِ الْيَوْمَ فِي شُغُلٍ فَاكِهُونَ",
  "هُمْ وَأَزْوَاجُهُمْ فِي ظِلَالٍ عَلَى الْأَرَائِكِ مُتَّكِئُونَ",
  "لَهُمْ فِيهَا فَاكِهَةٌ وَلَهُمْ مَا يَدَّعُونَ",
  "سَلَامٌ قَوْلًا مِنْ رَبٍّ رَحِيمٍ",
  "وَامْتَازُوا الْيَوْمَ أَيُّهَا الْمُجْرِمُونَ",
  "۞ أَلَمْ أَعْهَدْ إِلَيْكُمْ يَا بَنِي آدَمَ أَنْ لَا تَعْبُدُوا الشَّيْطَانَ ۖ إِنَّهُ لَكُمْ عَدُوٌّ مُبِينٌ",
  "وَأَنِ اعْبُدُونِي ۚ هَٰذَا صِرَاطٌ مُسْتَقِيمٌ",
  "وَلَقَدْ أَضَلَّ مِنْكُمْ جِبِلًّا كَثِيرًا ۖ أَفَلَمْ تَكُونُوا تَعْقِلُونَ",
  "هَٰذِهِ جَهَنَّمُ الَّتِي كُنْتُمْ تُوعَدُونَ",
  "اصْلَوْهَا الْيَوْمَ بِمَا كُنْتُمْ تَكْفُرُونَ",
  "الْيَوْمَ نَخْتِمُ عَلَىٰ أَفْوَاهِهِمْ وَتُكَلِّمُنَا أَيْدِيهِمْ وَتَشْهَدُ أَرْجُلُهُمْ بِمَا كَانُوا يَكْسِبُونَ",
  "وَلَوْ نَشَاءُ لَطَمَسْنَا عَلَىٰ أَعْيُنِهِمْ فَاسْتَبَقُوا الصِّرَاطَ فَأَنَّىٰ يُبْصِرُونَ",
  "وَلَوْ نَشَاءُ لَمَسَخْنَاهُمْ عَلَىٰ مَكَانَتِهِمْ فَمَا اسْتَطَاعُوا مُضِيًّا وَلَا يَرْجِعُونَ",
  "وَمَنْ نُعَمِّرْهُ نُنَكِّسْهُ فِي الْخَلْقِ ۖ أَفَلَا يَعْقِلُونَ",
  "وَمَا عَلَّمْنَاهُ الشِّعْرَ وَمَا يَنْبَغِي لَهُ ۚ إِنْ هُوَ إِلَّا ذِكْرٌ وَقُرْآنٌ مُبِينٌ",
  "لِيُنْذِرَ مَنْ كَانَ حَيًّا وَيَحِقَّ الْقَوْلُ عَلَى الْكَافِرِينَ",
  "أَوَلَمْ يَرَوْا أَنَّا خَلَقْنَا لَهُمْ مِمَّا عَمِلَتْ أَيْدِينَا أَنْعَامًا فَهُمْ لَهَا مَالِكُونَ",
  "وَذَلَّلْنَاهَا لَهُمْ فَمِنْهَا رَكُوبُهُمْ وَمِنْهَا يَأْكُلُونَ",
  "وَلَهُمْ فِيهَا مَنَافِعُ وَمَشَارِبُ ۖ أَفَلَا يَشْكُرُونَ",
  "وَاتَّخَذُوا مِنْ دُونِ اللَّهِ آلِهَةً لَعَلَّهُمْ يُنْصَرُونَ",
  "لَا يَسْتَطِيعُونَ نَصْرَهُمْ وَهُمْ لَهُمْ جُنْدٌ مُحْضَرُونَ",
  "فَلَا يَحْزُنْكَ قَوْلُهُمْ ۘ إِنَّا نَعْلَمُ مَا يُسِرُّونَ وَمَا يُعْلِنُونَ",
  "أَوَلَمْ يَرَ الْإِنْسَانُ أَنَّا خَلَقْنَاهُ مِنْ نُطْفَةٍ فَإِذَا هُوَ خَصِيمٌ مُبِينٌ",
  "وَضَرَبَ لَنَا مَثَلًا وَنَسِيَ خَلْقَهُ ۖ قَالَ مَنْ يُحْيِي الْعِظَامَ وَهِيَ رَمِيمٌ",
  "قُلْ يُحْيِيهَا الَّذِي أَنْشَأَهَا أَوَّلَ مَرَّةٍ ۖ وَهُوَ بِكُلِّ خَلْقٍ عَلِيمٌ",
  "الَّذِي جَعَلَ لَكُمْ مِنَ الشَّجَرِ الْأَخْضَرِ نَارًا فَإِذَا أَنْتُمْ مِنْهُ تُوقِدُونَ",
  "أَوَلَيْسَ الَّذِي خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ بِقَادِرٍ عَلَىٰ أَنْ يَخْلُقَ مِثْلَهُمْ ۚ بَلَىٰ وَهُوَ الْخَلَّاقُ الْعَلِيمُ",
  "إِنَّمَا أَمْرُهُ إِذَا أَرَادَ شَيْئًا أَنْ يَقُولَ لَهُ كُنْ فَيَكُونُ",
  "فَسُبْحَانَ الَّذِي بِيَدِهِ مَلَكُوتُ كُلِّ شَيْءٍ وَإِلَيْهِ تُرْجَعُونَ"
];