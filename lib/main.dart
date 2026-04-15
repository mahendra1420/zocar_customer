// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/controller/settings_controller.dart';
import 'package:zocar/firebase_options.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/page/all_rides/payment_selection_screen.dart';
import 'package:zocar/page/global_functions.dart';
import 'package:zocar/service/api.dart';

import 'advance_payment_manager.dart';
import 'advance_paymentsheet.dart';
import 'constant/show_toast_dialog.dart';
import 'controller/all_rides_controller.dart';
import 'helpers/upgrader/app_upgrader.dart';
import 'page/auth_screens/login_screen.dart';
import 'page/chats_screen/conversation_screen.dart';
import 'page/main_page.dart';
import 'service/localization_service.dart';
import 'themes/constant_colors.dart';
import 'utils/preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    DartPluginRegistrant.ensureInitialized();
    await Preferences.initPref();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Background Init Error: $e");
  }

  debugPrint("messgae notification : ${message.notification} ${message.data}");
  if (message.notification == null) {
    display(message, isbg: true);
  } else {
    debugPrint("messgae notification else: ${message.notification}");
  }
}

PackageInfo? packageInfo;

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Preferences.initPref();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await _setupFirebaseCrashlytics();
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (!Platform.isIOS) {
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt > 28) {
          AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
        }
      } catch (e, s) {
        debugPrint('Startup error in device info or Google Maps init: $e');
        debugPrintStack(stackTrace: s);
      }
    }

    Get.put(HomeController(), permanent: true);
    packageInfo = await PackageInfo.fromPlatform();
    runApp(const MyApp());
  }, (error, stack) {
    // If something fails catastrophically, show a basic error screen.
    // runApp(MaterialApp(
    //   home: Scaffold(
    //     body: Center(
    //       child: Text(
    //         'Something went wrong.\n$error',
    //         style: const TextStyle(fontSize: 16, color: Colors.red),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   ),
    // ));
    debugPrint('Uncaught error: $error');
    debugPrintStack(stackTrace: stack);
  });
}


/// CODE FOR FIREBASE CRASHLYTICS
///
Future<void> _setupFirebaseCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// ////////////////////////////////////////
///
///
// BuildContext context = Get.context!;

Future<void> _refreshData(RemoteMessage message) async {
  devlog("MYNotification data ==> ${message.data}");
  devlog("MyNotificationStatus ==> ${message.data['status'].toString()}");
  devlog("MyNotificationStatus ==> ${message.data['driver_id'].toString()}");

  if (message.data['status'] == "done") {
    await Get.to(ConversationScreen(), arguments: {
      'receiverId': int.parse(json.safeDecode(message.data['message'])['senderId'].toString()),
      'orderId': int.parse(json.safeDecode(message.data['message'])['orderId'].toString()),
      'receiverName': json.safeDecode(message.data['message'])['senderName'].toString(),
      'receiverPhoto': json.safeDecode(message.data['message'])['senderPhoto'].toString(),
    });
  } else if (message.data['statut'] == "confirmed" || message.data['statut'] == "driver_rejected") {
    MainPageController dashBoardController = Get.put(MainPageController());
    dashBoardController.selectedDrawerIndex.value = drawerItems.indexWhere((element) => element.isAllRides);
    Get.to(() => MainPage());
  } else if (message.data['statut'] == "on ride") {
    // var argumentData = {'type': 'on_ride'.tr, 'data': RideData.fromJson(message.data)};
    // Get.to(const RouteViewScreen(), arguments: argumentData);
  }else if(message.data['status'] == "canceled_by_job"){
    Utils.closeBottomSheet();
  }else if (message.data['status'] == "completed") {
    // Get.to(const TripHistoryScreen(), arguments: {
    //   "rideData": RideData.fromJson(message.data),
    // });
    MainPageController dashBoardController;
    try {
      dashBoardController = Get.find<MainPageController>();
    } catch (e) {
      dashBoardController = Get.put(MainPageController());
    }
    if (dashBoardController.selectedDrawerIndex.value == drawerItems.indexWhere((element) => element.isAllRides)) {
      devlog("MYNotification index is 1");
      try {
        final ctrr = Get.find<AllRidesController>();
        ctrr.goToTab();
        Get.to(() => MainPage());
      } catch (e) {
        try {
          final ctrr = Get.put<AllRidesController>(AllRidesController());
          ctrr.goToTab();
          Get.to(() => MainPage());
        } catch (e) {
          devlogError("API call error: $e");
        }
      }
    } else {
      devlog("MYNotification index is ${dashBoardController.selectedDrawerIndex.value}");
    }
  }
  devlog("neon -> NOTIFICATION REFRESH DATA FUNCTION CALLED");
  try {
    final ctr = Get.find<AllRidesController>();
    await ctr.getAllRides();
  } catch (e) {
    try {
      final ctr = Get.put<AllRidesController>(AllRidesController());
      await ctr.getAllRides();
    } catch (e) {
      devlogError("API call error: $e");
    }
  }
}

void display(RemoteMessage message, {bool isbg = false}) async {
  debugPrint("messgae notification display: ${message.notification} ${message.data}");
  try {
    try {
      final status = message.data['status'].toString();
      if (status == "accepted" || status == "acceptedadmin") {
        debugPrint("isVisible data status is $status");
        final rideId = message.data['ride_id']?.toString() ?? "";
        final driverId = message.data['driver_id']?.toString() ?? "";
        final advancePayment = (double.tryParse(message.data['advance_payment']?.toString() ?? "0") ?? 0).round();
        debugPrint("Advance Payment parsed: $advancePayment");
        final isAcceptedAdmin = status == "acceptedadmin";

        Map<String, String> bodyParams = {
          'driver_id': driverId,
          'ride_id': rideId,
        };
        final sp = await SharedPreferences.getInstance();
        await sp.reload();
        await sp.setBool("isAcceptedNew", true);
        final isAccepted = sp.getBool("isAcceptedNew");
        debugPrint("isAcceptedNew  : ${isAccepted}");

        MyApp.confirmedRide(bodyParams).then((value) async {
          debugPrint("isVisible after confirmed ride: ${value}");
          if (value != null) {
            Utils.autoCancelTimer?.cancel();

            if (!isbg) {
              AllRidesController? newRideCtr;
              try {
                newRideCtr = Get.find<AllRidesController>();
              } catch (e) {
                newRideCtr = Get.put<AllRidesController>(AllRidesController());
              }

              // ✅ SCENARIO: advancePayment == 0 → skip sheet entirely, no closeBottomSheet
              if (advancePayment <= 0) {
                MainPageController? mainCtr;
                try {
                  mainCtr = Get.find<MainPageController>();
                } catch (e) {
                  mainCtr = Get.put<MainPageController>(MainPageController());
                }
                mainCtr.selectedDrawerIndex.value =
                    drawerItems.indexWhere((element) => element.isAllRides);
                newRideCtr.goToTab(0);
                Get.to(() => MainPage());
                return;
              }

              // ✅ SCENARIO: advancePayment > 0 → close any open sheet ONCE, then show advance sheet

              // acceptedadmin: no driver_id requirement, no timer
              if (isAcceptedAdmin && rideId.isNotEmpty) {
                Utils.closeBottomSheet(); // close other sheets once
                await AdvancePaymentManager.save(
                  rideId: rideId,
                  driverId: driverId,
                  amount: advancePayment,
                  timerEnabled: false,
                );
                final ctx = Get.context;
                if (ctx != null) {
                  AdvancePaymentSheet.showIfNeeded(ctx);
                }
                return;
              }

              // accepted: requires driver_id, timer-based
              if (!isAcceptedAdmin && rideId.isNotEmpty && driverId.isNotEmpty) {
                Utils.closeBottomSheet(); // close other sheets once
                await AdvancePaymentManager.save(
                  rideId: rideId,
                  driverId: driverId,
                  amount: advancePayment,
                  timeoutSeconds: 120,
                  timerEnabled: true,
                );
                final ctx = Get.context;
                if (ctx != null) {
                  AdvancePaymentSheet.showIfNeeded(ctx);
                }
                return;
              }

              // accepted but driverId is empty → clear advance data, no sheet
              if (!isAcceptedAdmin && driverId.isEmpty) {
                await AdvancePaymentManager.clear();
              }

              MainPageController? mainCtr;
              try {
                mainCtr = Get.find<MainPageController>();
              } catch (e) {
                mainCtr = Get.put<MainPageController>(MainPageController());
              }
              mainCtr.selectedDrawerIndex.value =
                  drawerItems.indexWhere((element) => element.isAllRides);
              newRideCtr.goToTab(0);
              Get.to(() => MainPage());
            }
            debugPrint("isVisible value not null : ${value}");
          }
        }).catchError((e) {
          devlog("error onerror : $e");
        });
      }

      else if (message.data['title'].toString() == "Rejection of your ride"){
        Utils.closeBottomSheet();
      }
    } catch (e) {
      devlogError("FlutterLocalNotificationsPlugin Exception on cancel ${e.toString()}");
    }
    debugPrint("MyNotificationStatus message ==> ${message.notification.toString()}");
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
      "01",
      "cabme",
      importance: Importance.max,
      priority: Priority.high,
    ));
    if ((message.data['title'] ?? message.notification?.title) != null)
      await FlutterLocalNotificationsPlugin().show(
        id,
        message.data['title'] ?? message.notification?.title,
        message.data['body'] ?? message.notification?.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
  } catch (e) {
    debugPrint("FlutterLocalNotificationsPlugin Exception ${e.toString()}");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<dynamic> confirmedRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.driverDetailById), headers: API.header, body: jsonEncode(bodyParams));
      devlog("MyLogData confirmedRide ==> ${response.body.toString()}");
      devlog("MyLogData confirmedRide ==> ${bodyParams}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      devlog("responsdfl sdjf jsdlfkj slkdf0" + responseBody.toString());
      if (response.statusCode == 200 && responseBody['success'] == "success" || responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      try {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(e.message.toString());
      } catch (e) {}
    } on SocketException catch (e) {
      try {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(e.message.toString());
      } catch (e) {}
    } on Error catch (e) {
      try {
        ShowToastDialog.closeLoader();

        ShowToastDialog.showToast(e.toString());
      } catch (e) {}
    }
    try {
      ShowToastDialog.closeLoader();
    } catch (e) {}
    return null;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupInteractedMessage(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Utils.idz != null && Utils.contextz != null) {
        Utils.checkAndCancelIfAccepted(Utils.contextz!, Utils.idz!);
      }
      // NEW: check for pending advance payment
      final ctx = Get.context;
      if (ctx != null) {
        AdvancePaymentSheet.showIfNeeded(ctx);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _refreshData(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      logFullNotification(message);
      display(message);
      await _refreshData(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      logFullNotification(message);
      devlog("MYNotification notification ==> ${message.notification.toString()}");
      devlog("MYNotification data ==> ${message.data.toString()}");

      await _refreshData(message);
    });
    await FirebaseMessaging.instance.subscribeToTopic("cabme");
  }
  void logFullNotification(RemoteMessage message) {
    print("🔔🔔🔔 FULL NOTIFICATION START 🔔🔔🔔");

    // Convert everything into a Map
    final fullData = {
      "data": message.data,
      "notification": {
        "title": message.notification?.title,
        "body": message.notification?.body,
      },
      "android": {
        "channelId": message.notification?.android?.channelId,
        "clickAction": message.notification?.android?.clickAction,
        "imageUrl": message.notification?.android?.imageUrl,
        "smallIcon": message.notification?.android?.smallIcon,
      },
      "apple": {
        "subtitle": message.notification?.apple?.subtitle,
        "badge": message.notification?.apple?.badge,
        "sound": message.notification?.apple?.sound?.name,
      },
      "messageId": message.messageId,
      "sentTime": message.sentTime?.toString(),
      "from": message.from,
      "category": message.category,
      "collapseKey": message.collapseKey,
      "ttl": message.ttl,
    };

    print("📦 FULL MAP: $fullData");

    print("🔔🔔🔔 FULL NOTIFICATION END 🔔🔔🔔");
  }
  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {});

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void showDialogData(String ride_id, dynamic value) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(16.0),
          contentPadding: EdgeInsets.all(0), // Adjust padding if needed
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Meet at ${value['data']['pickup_address']?.toString()}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(Icons.location_pin, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 25.0, left: 25),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(value['data']['photo'].toString()), // Load image from network
                        onBackgroundImageError: (error, stackTrace) {
                          devlog('Image failed to load: $error');
                        },
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value['data']['numberplate'].toString(), style: TextStyle(fontSize: 16)),
                          Text(value['data']['typeVehicule'].toString(), style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 25, left: 25),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("${value['data']['prenom']?.toString()} ${value['data']['nom']?.toString()}", style: TextStyle(fontSize: 18)),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Booking Cancel Button
                Padding(
                  padding: const EdgeInsets.only(right: 25, left: 25, bottom: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel Booking",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Preferences.setString(Preferences.languageCodeKey, "en");
    Future.delayed(const Duration(seconds: 3), () {
      if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
        LocalizationService().changeLocale(Preferences.getString(Preferences.languageCodeKey).toString());
      }
    });
    precacheImage(AssetImage("assets/images/appIcon.png"), context);
    return GetMaterialApp(
      title: 'ZoCar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ConstantColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.locale,
      translations: LocalizationService(),
      builder: EasyLoading.init(),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await precacheImage(AssetImage(kImgWhiteBg), context);
      await precacheImage(AssetImage("assets/images/appIcon.png"), context);
      final isUpdateAvailable = await AppUpgrader.checkUpdate(context);
      if (isUpdateAvailable) return;
      try {
        Get.offAll(() => RedirectionScreen());
      } catch (e, s) {
        devlogError('Navigation failed: $e\n$s');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Center(child: CupertinoActivityIndicator()),
              Center(
                child: ClipOval(
                  child: Hero(
                    tag: "kImgZocar",
                    child: Image(
                        width: 50.w,
                        image: AssetImage("assets/images/appIcon.png")),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RedirectionScreen extends StatelessWidget {
  const RedirectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: SettingsController(),
        builder: (controller) {
          return Preferences.getBoolean(Preferences.isLogin) ? MainPage() : LoginScreen();
        });
  }
}
