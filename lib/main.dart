import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled13/Constant/appFonts.dart';
import 'package:untitled13/Constant/myColor.dart';
import 'package:untitled13/View/BarcodeScanner.dart';
import 'package:untitled13/View/creditCard.dart';

SharedPreferences? sharedPreferences;
void main() async {
  String number = "1000 غم";
  var weight = int.parse(number.replaceAll('غم', ''));
  print(weight);
  print(weight.runtimeType);
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  bool showHome = sharedPreferences!.getBool('showHome') ?? false;
  bool showCard = (sharedPreferences!.getString("cardNumber") != null);
  runApp(MyApp(
    showHome: showHome,
    showCard: showCard,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showHome, required this.showCard});
  final bool showHome;
  final bool showCard;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MyColor.primary,
      ),
      home: showHome
          ? !showCard
              ? const CreditCard()
              : const BarcodeScanner()
          : const OnBoardingScreen(),
    );
  }
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.primary,
      body: Container(
        color: MyColor.primary,
        child: Container(
          padding: const EdgeInsets.only(bottom: 80),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              pageView(
                  imageURL: "assets/images/creditcard.png",
                  title: "أضف بطاقة",
                  description:
                      "قم بأدخال بطاقة الأتمان لدفع الأموال الكترونياً وبطريقة امنة"),
              pageView(
                  imageURL: "assets/images/1.png",
                  title: "مسح المنتجات",
                  description:
                      'قم بقراءة الباركود لاي منتج لاضافته الى سلة المشتريات'),
              pageView(
                  imageURL: "assets/images/marketproduct.png",
                  title: "شراء اي منتج",
                  description: "قم باختيار اي منتج لاضافته الى سلة المبيعات ")
            ],
          ),
        ),
      ),
      bottomSheet: isLastPage
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      backgroundColor: MyColor.getStarted,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(80)),
                  onPressed: () async {
                    final sharedPref = await SharedPreferences.getInstance();
                    sharedPref.setBool('showHome', true);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreditCard()));
                  },
                  child: const Text("Get Started",
                      style: TextStyle(fontSize: 24))),
            )
          : Container(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        controller.jumpToPage(2);
                      },
                      child: const Text("SKIP")),
                  Center(
                    child: SmoothPageIndicator(
                      onDotClicked: (index) {
                        controller.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      controller: controller,
                      count: 3,
                      effect: WormEffect(
                          spacing: 16,
                          dotColor: Colors.black26,
                          activeDotColor: Colors.teal.shade700),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: const Text("NEXT"))
                ],
              ),
            ),
    );
  }
}

Widget pageView({required imageURL, required title, required description}) {
  return Column(
    children: [
      const Spacer(
        flex: 1,
      ),
      Expanded(
        flex: 5,
        child: Image.asset(
          imageURL,
          fit: BoxFit.cover,
        ),
      ),
      const Spacer(
        flex: 1,
      ),
      Expanded(
        flex: 2,
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.titleFonts,
              color: Colors.teal.shade400),
        ),
      ),
      const Spacer(
        flex: 1,
      ),
      Expanded(
        flex: 2,
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: Text(
              description,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: FontSize.subtitleFonts,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      )
    ],
  );
}
