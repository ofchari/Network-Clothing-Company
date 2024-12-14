import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadingText extends StatefulWidget {
  const HeadingText({super.key , required this.text ,required this.weight,required this.color});
  final String text;
  final FontWeight weight;
  final Color color;

  @override
  State<HeadingText> createState() => _HeadingTextState();
}

class _HeadingTextState extends State<HeadingText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text,style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 23.sp,fontWeight: widget.weight,color: widget.color)),);
  }
}
