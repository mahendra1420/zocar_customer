import 'package:zocar/themes/constant_colors.dart';
import 'package:flutter/material.dart';

class CustomDialogBoxNew extends StatefulWidget {
  final String title, descriptions, text;
  String? subDescriptions;
  final Image img;
  final Function() onPress;

  CustomDialogBoxNew({super.key, required this.title, required this.descriptions, this.subDescriptions, required this.text, required this.img, required this.onPress});

  @override
  CustomDialogBoxNewState createState() => CustomDialogBoxNewState();
}

class CustomDialogBoxNewState extends State<CustomDialogBoxNew> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [
        BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(45)), child: widget.img),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.title.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 15,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                TextSpan(
                  text: widget.descriptions.toString(),
                ),
                TextSpan(
                  text: " " +(widget.subDescriptions?.toString() ?? ""),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: ConstantColors.blueColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: widget.onPress,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  widget.text.toString(),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
