// ignore_for_file: must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/controller/settings_controller.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/main.dart';
import 'package:zocar/page/all_rides/all_rides_screen.dart';
import 'package:zocar/page/contact_us/contact_us_screen.dart';
import 'package:zocar/page/favotite_ride_screens/favorite_ride_screen.dart';
import 'package:zocar/page/my_profile/my_profile_screen.dart';
import 'package:zocar/page/privacy_policy/privacy_policy_screen.dart';
import 'package:zocar/page/referral_screen/referral_screen.dart';
import 'package:zocar/page/rewards/rewards_screen.dart';
import 'package:zocar/page/terms_service/terms_of_service_screen.dart';
import 'package:zocar/page/wallet/wallet_screen.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../constant/constant.dart';
import '../helpers/devlog.dart';
import '../helpers/pending_payment_dialog.dart';
import '../page/home_screens/dashboard_page.dart';
import '../service/active_user_checker.dart';
import '../themes/responsive.dart';
import '../utils/global_functions.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class DrawerItem {
  final String title;
  final String icon;
  final Widget? screen;
  final String? section;
  final bool isWallet;
  final bool isSpecialColor;
  final bool isAllRides;

  DrawerItem(
    this.title,
    this.icon, {
    this.screen,
    this.section,
    this.isWallet = false,
    this.isSpecialColor = false,
    this.isAllRides = false,
  });
}

List<DrawerItem> drawerItems = [
  DrawerItem('home'.tr, 'assets/icons/ic_home.svg', screen: const DashboardPage()),
  DrawerItem("Rewards", 'assets/icons/ic_star_line.svg', screen: const RewardsScreen()),
  DrawerItem('All Rides'.tr, 'assets/icons/ic_parcel.svg', section: 'Ride'.tr, screen: const AllRidesScreen(), isAllRides: true),
  DrawerItem('favorite_ride'.tr, 'assets/icons/ic_fav.svg', screen: const FavoriteRideScreen()),
  DrawerItem('my_wallet'.tr, 'assets/icons/ic_wallet.svg', section: 'Account & Payments'.tr, screen: WalletScreen(), isWallet: true),
  DrawerItem('my_profile'.tr, 'assets/icons/ic_profile.svg', screen: MyProfileScreen(), isSpecialColor: true),
  DrawerItem('refer_a_friend'.tr, 'assets/icons/ic_refer.svg', screen: const ReferralScreen()),
  DrawerItem('term_service'.tr, 'assets/icons/ic_terms.svg', section: 'App Settings'.tr, screen: const TermsOfServiceScreen()),
  DrawerItem('privacy_policy'.tr, 'assets/icons/ic_privacy.svg', screen: const PrivacyPolicyScreen()),
  DrawerItem('contact_us'.tr, 'assets/icons/ic_profile.svg', section: 'Feedback & Support'.tr, screen: const ContactUsScreen()),
  DrawerItem('rate_business'.tr, 'assets/icons/ic_star_line.svg'),
  DrawerItem('sign_out'.tr, 'assets/icons/ic_logout.svg'),
];

class _MainPageState extends State<MainPage> {
  DateTime backPress = DateTime.now();
  HomeController? controller;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    final settingsController = Get.put(SettingsController());

      devlog("calll ------- setting controller");
    settingsController.getSettingsData();

    try {
      controller = Get.find<HomeController>();
    } catch (e) {
      controller = Get.put<HomeController>(HomeController());
    }
    widgetBinding((_) async {
      final ok = await ActiveChecker.check();
      if (!ok) return;

      if (controller != null && !controller!.onceShownOnMainPage) {
        try {
          final pendingPayment = await controller?.getUserPendingPayment();
          if (pendingPayment == null) return;
          if (pendingPayment['success'] == "success") {
            if (pendingPayment['data']['amount'] != 0) {
              pendingPaymentDialog(context);
              controller?.onceShownOnMainPage = true;
            }
          }
        } catch (e) {
          devlogError("Error checking pending payment: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (p, r) async {
        final ctr = Get.find<MainPageController>();
        if (ctr.selectedDrawerIndex != 0) {
          ctr.selectedDrawerIndex.value = 0;
          return;
        }
        final timeGap = DateTime.now().difference(backPress);
        final cantExit = timeGap >= const Duration(seconds: 2);
        backPress = DateTime.now();
        if (cantExit) {
          const snack = SnackBar(
            content: Text(
              'Press Back button again to Exit',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);

          return;
        } else {
          SystemNavigator.pop();
        }
      },
      child: GetX<MainPageController>(
          init: MainPageController(),
          builder: (controller) {
            final int walletScreenIndex = drawerItems.indexWhere((e) => (e.isWallet));
            final int specialColorIndex = drawerItems.indexWhere((e) => (e.isSpecialColor)); // wallet

            final int selected = controller.selectedDrawerIndex.value;

            final bool isDarkScreen = selected == 0 || selected == specialColorIndex || selected == walletScreenIndex;

            final bool isWalletScreen = selected == walletScreenIndex;

            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: isDarkScreen ? (isWalletScreen ? ConstantColors.blueColor : ConstantColors.primary) : ConstantColors.background,
                statusBarIconBrightness: isDarkScreen ? Brightness.light : Brightness.dark,
                statusBarBrightness: isDarkScreen ? Brightness.light : Brightness.dark,
              ),
            );

            final bool shouldShowAppBar = selected != 0 && selected != walletScreenIndex;

            return Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomInset: selected != specialColorIndex && selected != 0,
              appBar: !shouldShowAppBar
                  ? null
                  : AppBar(
                      backgroundColor: selected == specialColorIndex ? ConstantColors.primary : ConstantColors.background,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(
                        drawerItems[selected].title == "Rewards" ? "Reward Coupons" : drawerItems[selected].title,
                        style: TextStyle(
                          color: selected == specialColorIndex ? Colors.white : Colors.black,
                        ),
                      ),
                      leading: Builder(
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ConstantColors.primary.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/icons/ic_side_menu.png",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              drawerEnableOpenDragGesture: false,
              drawer: buildAppDrawer(context, controller),
              body: SafeArea(child: getDrawerItemWidget(selected)),
            );
          }),
    );
  }

  Widget getDrawerItemWidget(int index) {
    try {
      final item = drawerItems[index];
      return item.screen ?? const SizedBox();
    } catch (e) {
      return const SizedBox();
    }
  }

  buildAppDrawer(BuildContext context, MainPageController controller) {
    return SafeArea(
      child: Drawer(
        width: Responsive.width(85, context),
        backgroundColor: AppThemeData.surface50,
        child: Column(
          children: [
            // Scrollable content with profile header and drawer items
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Animated Profile Header
                  SliverAppBar(
                    expandedHeight: 210.0,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppThemeData.surface50,
                    automaticallyImplyLeading: false,
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        // Calculate collapse progress (0.0 = fully expanded, 1.0 = fully collapsed)
                        final double top = constraints.biggest.height;
                        final double collapseProgress = ((210.0 - top) / (210.0 - kToolbarHeight)).clamp(0.0, 1.0);

                        return FlexibleSpaceBar(
                          centerTitle: false,
                          titlePadding: EdgeInsets.only(
                            top: 5,
                            left: 16,
                            bottom: 5 + (collapseProgress * 4),
                          ),
                          title: AnimatedOpacity(
                            duration: Duration(milliseconds: 200),
                            opacity: collapseProgress,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppThemeData.primary200.withOpacity(0.3), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.0),
                                    child: controller.userModel.data?.photoPath?.isEmpty == true
                                        ? Image.asset("assets/images/appIcon.png", fit: BoxFit.cover)
                                        : CachedNetworkImage(
                                            imageUrl: controller.userModel.data?.photoPath ?? '',
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => Image.asset("assets/images/appIcon.png"),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${controller.userModel.data!.prenom}",
                                        style: TextStyle(
                                          color: AppThemeData.grey900,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: AppThemeData.medium,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppThemeData.primary200.withOpacity(0.08),
                                  AppThemeData.surface50,
                                ],
                              ),
                            ),
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: 1.0 - collapseProgress,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5),
                                  Hero(
                                    tag: 'profile_image',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppThemeData.primary200.withOpacity(0.25),
                                            blurRadius: 20,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppThemeData.primary200.withOpacity(0.2),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(80.0),
                                          child: controller.userModel.data?.photoPath?.isEmpty == true
                                              ? Image.asset(
                                                  "assets/images/appIcon.png",
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: controller.userModel.data?.photoPath ?? '',
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                    child: CupertinoActivityIndicator(),
                                                  ),
                                                  errorWidget: (context, url, error) => Image.asset(
                                                    "assets/images/appIcon.png",
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${controller.userModel.data!.prenom} ${controller.userModel.data!.nom}",
                                    style: TextStyle(
                                      color: AppThemeData.grey900,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppThemeData.regular,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.primary200.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppThemeData.primary200.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${controller.userModel.data!.email}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                        fontFamily: AppThemeData.regular,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Drawer Items
                  SliverPadding(
                    padding: EdgeInsets.only(top: 8, bottom: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          var d = drawerItems[i];
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Visibility(
                              visible: d.section != null,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30, bottom: 10, left: 16),
                                child: Text(
                                  d.section ?? '',
                                  style: TextStyle(
                                    color: AppThemeData.grey500Dark,
                                    fontSize: 14,
                                    fontFamily: AppThemeData.regular,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _scaffoldKey.currentState?.closeDrawer();
                                final item = drawerItems[i];

                                if (item.title == 'rate_business'.tr) {
                                  openAppStore();
                                } else if (item.title == 'sign_out'.tr) {
                                  return showLogoutDialog();
                                } else {
                                  controller.selectedDrawerIndex.value = i;
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                      SvgPicture.asset(
                                        d.icon,
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          drawerItems[i].title == drawerItems[drawerItems.length - 1].title
                                              ? AppThemeData.error200
                                              : controller.selectedDrawerIndex.value == i
                                                  ? AppThemeData.primary200
                                                  : AppThemeData.grey900,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        d.title,
                                        style: TextStyle(
                                          color: drawerItems[i].title == drawerItems[drawerItems.length - 1].title
                                              ? AppThemeData.error200
                                              : controller.selectedDrawerIndex.value == i
                                                  ? AppThemeData.primary200
                                                  : AppThemeData.grey900,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.medium,
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            if ((drawerItems.length - 2) > i)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                height: 0.5,
                                color: AppThemeData.grey200,
                              ),
                          ]);
                        },
                        childCount: drawerItems.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Footer with Logo and Version
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: AppThemeData.grey200.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary200.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppThemeData.primary200.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        kImgZocar,
                        height: 15,
                        width: 20.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  if (packageInfo?.version != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppThemeData.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Version ${packageInfo?.version ?? ""}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
