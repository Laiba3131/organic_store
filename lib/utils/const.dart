import 'package:flutter/material.dart';

const double SizeboxHeight = 10.0;
const double containerSize = 230.0;
 List<BoxShadow> boxShadowCustom=[
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                blurRadius: 6, // Softness of the shadow
                spreadRadius: 2, // How much the shadow expands
                offset: Offset(0, 4), // Position of the shadow (x, y)
              ),
            ];