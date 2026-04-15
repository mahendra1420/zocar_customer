import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scratcher/scratcher.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/size_ext.dart';

import '../../constant/constant.dart';
import '../../model/coupan_code_model.dart';
import '../home_screens/search_page.dart';

class RewardDialog extends StatefulWidget {
  final BuildContext parentContext;
  final int rewardCount;
  final List<CoupanCodeData> couponList;

  const RewardDialog({
    Key? key,
    required this.parentContext,
    required this.rewardCount,
    required this.couponList,
  }) : super(key: key);

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  bool _isScratched = false;

  void _onScratchComplete() {
    setState(() {
      _isScratched = true;
    });
  }

  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isScratched ? _buildRewardScreen(context, widget.couponList) : _buildScratchScreen(),
    );
  }

  Widget _buildScratchScreen() {
    final promo = widget.couponList.isNotEmpty
        ? widget.couponList.first
        : CoupanCodeData(
            discount: "100",
            type: "Flat",
            discription: "Default Reward Coupon",
            code: "DEFAULT100",
          );
    return PopScope(
      canPop: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Scratcher(
                        brushSize: 50,
                        threshold: 30,
                        color: Colors.white,
                        onScratchEnd: () {
                          if (value >= 30) _onScratchComplete();
                        },
                        onChange: (v) {
                          value = v;
                        },
                        image: Image.asset(
                          'assets/images/reward_overlay.png',
                          fit: BoxFit.cover,
                        ),
                        child: Container(
                          height: 70.w,
                          width: 70.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4285F4),
                                Color(0xFF34A853),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // Scratched content (reward)
                              Hero(
                                 tag: 'reward_coupon_hero',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/reward_content.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20),
                                        const Text(
                                          'You Won',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Reward coupon',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          (promo.type == "Percentage" ? "${promo.discount}%" : Constant().amountShow(amount: promo.discount.toString())) + " OFF",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'You have earned a reward! \nScratch to reveal your prize.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardScreen(BuildContext context, List<CoupanCodeData> couponList) {
    final promo = couponList.isNotEmpty
        ? couponList.first
        : CoupanCodeData(
            discount: "100",
            type: "Flat",
            discription: "Default Reward Coupon",
            code: "DEFAULT100",
            title: "Welcome Offer",
            expireAt: "December 28, 2025",
          );

    return Material(
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(tag: "kImgZocar", child: Image.asset(kImgZocar, width: 100)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Hero(
              tag: 'reward_coupon_hero',
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/reward_content.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reward coupon',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        promo.type == "Percentage" ? "${promo.discount}%" : Constant().amountShow(amount: promo.discount.toString()) + " OFF",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Status badges
                          Builder(
                            builder: (context) {
                              final daysLeft = getDaysLeft(promo.expireAt);
                              devlog("Days left for promo ${promo.code}: $daysLeft");
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // _buildBadge("3d left", Colors.brown.shade700),
                                  _buildBadge(
                                    daysLeft == 0
                                        ? "Last day"
                                        : daysLeft > 0
                                            ? "${daysLeft}d left"
                                            : "Expired",
                                    daysLeft >= 0 ? Colors.brown.shade700 : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildBadge("Activating", Colors.deepOrange.shade700),
                                  // const SizedBox(width: 8),
                                  // _buildBadge("5k liked", Colors.grey.shade700),
                                ],
                              );
                            }
                          ),
                          const SizedBox(height: 10),

                          // Details section
                          _buildExpandableSection(
                            "Details",
                            [
                              "Expires on ${promo.expireAt ?? 'December 28, 2025'}",
                              "Minimum ₹${promo.minimum_amount ?? '150'} spend.",
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Terms & conditions
                          _buildExpandableSection(
                            "Terms & conditions",
                            [
                              promo.type == "Percentage"
                                  ? "Get ${promo.discount}% discount when you make a payment using this coupon."
                                  : "Get ₹${promo.discount} discount when you make a payment using this coupon.",
                              "Use code ${promo.code ?? 'ZoCar100'} to use this coupon.",
                              "You can use this coupon on payment type of next rides.",
                              "Use before expiry date ${promo.expireAt ?? 'December 28, 2026'}.",
                              "Minimum amount should be ₹${promo.minimum_amount ?? '150'}.",
                              "Only one redemption per user.",
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Redeem button
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final ctr = Get.find<MainPageController>();
                    ctr.selectedDrawerIndex.value = 0;
                    Get.to(SearchPage(), transition: Transition.fade, duration: Duration.zero);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.launch, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Book New Ride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  int getDaysLeft(String? expireAt) {
    if (expireAt == null || expireAt.isEmpty) return -1;

    try {
      // Parse expiry date (date only)
      final expiryDate = DateFormat('dd MMMM yyyy hh:mm a').parse(expireAt);

      // Set expiry to end of day (11:59:59 PM)
      final expiryEndOfDay = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
        23,
        59,
        59,
      );

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final difference = expiryEndOfDay.difference(todayStart).inDays;

      return difference == 0 ? 0 :  difference < 0 ? -1 : difference;
    } catch (e) {
      devlog("Error parsing expiry date: $e");
      return -1;
    }
  }


  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "• ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class RewardDialog2 extends StatefulWidget {
//   final BuildContext parentContext;
//   final int rewardCount;
//   final List<CoupanCodeData> couponList;
//
//   const RewardDialog2({Key? key, required this.parentContext, required this.rewardCount, required this.couponList}) : super(key: key);
//
//   @override
//   State<RewardDialog2> createState() => _RewardDialog2State();
// }
//
// class _RewardDialog2State extends State<RewardDialog2> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _slideController;
//   late AnimationController _rotateController;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _rotateAnimation;
//   late ConfettiController _confettiController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 2),
//     );
//
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _rotateController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _scaleAnimation = CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.elasticOut,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     _rotateAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1,
//     ).animate(CurvedAnimation(
//       parent: _rotateController,
//       curve: Curves.easeInOut,
//     ));
//
//     _scaleController.forward();
//     _slideController.forward();
//     _rotateController.repeat(reverse: true);
//
//     // Play confetti
//     _confettiController.play();
//
//     // Play success sound
//     _playSuccessSound();
//   }
//
//   Future<void> _playSuccessSound() async {
//     try {
//       // Play a success sound - you can replace with your own sound file
//       // await _audioPlayer.play(AssetSource('sounds/success.mp3'));
//
//       // Alternative: Use a package like 'just_audio' or 'soundpool' for better sound effects
//       // For now, this is a placeholder for when you add your sound file
//     } catch (e) {
//       // Handle error silently
//     }
//   }
//
//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _slideController.dispose();
//     _rotateController.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Dialog
//         Dialog(
//           insetPadding: EdgeInsets.symmetric(horizontal: 7.w),
//           backgroundColor: Colors.transparent,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF0A3D62),
//                     Color(0xFF1B4F72),
//                     Color(0xFF2980B9),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0xFF0A3D62).withOpacity(0.3),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Animated Icon
//                   ScaleTransition(
//                     scale: _rotateAnimation,
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.card_giftcard,
//                         size: 60,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Title
//                   Center(
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: const Text(
//                         'Congratulations! 🎉',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // "You've Won" text
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: const Text(
//                       "You've Earned",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // Reward Count
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                           width: 2,
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             '${widget.rewardCount}',
//                             style: const TextStyle(
//                               fontSize: 48,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             widget.rewardCount > 1 ? 'Reward Coupons' : 'Reward Coupon',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white.withOpacity(0.9),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                             widget.parentContext,
//                             MaterialPageRoute(
//                                 builder: (context) => ViewCouponsScreen(
//                                       coupanCodeList: widget.couponList,
//                                     )));
//                       },
//                       child: Text("View Coupons")),
//                   const SizedBox(height: 10),
//
//                   // Message
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: Text(
//                       'Use them on your next rides!',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Button
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: const Color(0xFF8B5CF6),
//                         padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: const Text(
//                         'Awesome!',
//                         style: TextStyle(
//                           color: Color(0xFF0A3D62),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // TOP CONFETTI (Blast UP then fall DOWN)
//         Align(
//           alignment: Alignment.topCenter,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirection: -pi / 2,
//             // UP
//             emissionFrequency: 0,
//             numberOfParticles: 10,
//             maxBlastForce: 10,
//             // upward strength
//             minBlastForce: 5,
//             gravity: 0.8,
//             // makes confetti fall down naturally
//             colors: const [
//               Colors.green,
//               Colors.blue,
//               Colors.pink,
//               Colors.orange,
//               Colors.purple,
//               Colors.yellow,
//               Colors.red,
//             ],
//           ),
//         ),
//
//         Align(
//           alignment: Alignment.centerLeft,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirection: -pi / 2,
//             // Always UP
//             emissionFrequency: 0,
//             numberOfParticles: 10,
//             maxBlastForce: 18,
//             minBlastForce: 8,
//             gravity: 0.6,
//             colors: const [
//               Colors.green,
//               Colors.blue,
//               Colors.pink,
//               Colors.orange,
//               Colors.purple,
//             ],
//           ),
//         ),
//
//         Align(
//           alignment: Alignment.centerRight,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirection: -pi / 2,
//             // Always UP
//             emissionFrequency: 0,
//             numberOfParticles: 10,
//             maxBlastForce: 18,
//             minBlastForce: 8,
//             gravity: 0.6,
//             colors: const [
//               Colors.green,
//               Colors.blue,
//               Colors.pink,
//               Colors.orange,
//               Colors.purple,
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class ViewCouponsScreen extends StatelessWidget {
//   final List<CoupanCodeData> coupanCodeList;
//
//   const ViewCouponsScreen({super.key, required this.coupanCodeList});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ConstantColors.background,
//       appBar: AppBar(
//         title: Text("Coupons"),
//       ),
//       body: coupanCodeList.isEmpty
//           ? Center(
//               child: Constant.emptyView(context, "No coupons available".tr, false),
//             )
//           : ListView.builder(
//               itemCount: coupanCodeList.length,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return buildPromoCodeItem(context, coupanCodeList[index]);
//               }),
//     );
//   }
//
//   Widget buildPromoCodeItem(BuildContext context, CoupanCodeData data) {
//     return Container(
//       height: 150,
//       padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/images/promo_bg.png'),
//           fit: BoxFit.fill,
//         ),
//       ),
//       child: Center(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 30),
//               child: Container(
//                 decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(30))),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Image.asset(
//                     'assets/icons/promocode.png',
//                     width: 40,
//                     height: 40,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 35),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data.discription.toString(),
//                       style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
//                     ),
//                     const SizedBox(
//                       height: 3,
//                     ),
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             FlutterClipboard.copy(data.code.toString());
//                             //     .then((value) {
//                             //   final SnackBar snackBar = SnackBar(
//                             //     content: Text(
//                             //       "Coupon Code Copied".tr,
//                             //       textAlign: TextAlign.center,
//                             //       style: TextStyle(color: Colors.white),
//                             //     ),
//                             //     backgroundColor: Colors.black38,
//                             //   );
//                             //   ScaffoldMessenger.of(context)
//                             //       .showSnackBar(snackBar);
//                             //   // return Navigator.pop(context);
//                             // });
//                           },
//                           child: Container(
//                             color: Colors.black.withOpacity(0.05),
//                             child: DottedBorder(
//                               color: Colors.grey,
//                               strokeWidth: 1,
//                               dashPattern: const [3, 3],
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                                 child: Text(
//                                   data.code.toString(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 8,
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Valid till ".tr + data.expireAt.toString(),
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                               Builder(builder: (context) {
//                                 final minAmount = int.tryParse(data.minimum_amount?.toString().trim() ?? '');
//                                 if (minAmount != null && minAmount != 0)
//                                   return Text(
//                                     "${"Min Spend: ".tr} ${data.minimum_amount}",
//                                     style: const TextStyle(fontSize: 12),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   );
//                                 return SizedBox();
//                               }),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 8,
//                         ),
//                       ],
//                     ),
//                     Builder(builder: (context) {
//                       if (data.remainingCount != null && data.remainingCount != 0)
//                         return Text(
//                           "${"Remaining Usages: ".tr} ${data.remainingCount}",
//                           style: const TextStyle(fontSize: 12),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         );
//                       return SizedBox();
//                     }),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
