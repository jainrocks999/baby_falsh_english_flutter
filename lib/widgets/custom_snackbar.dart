import 'package:flutter/material.dart';

// void showCustomSnackBar({
//   required BuildContext context,
//   required String title,
//   String? subtitle,
//   required Color backgroundColor,
//   required IconData icon,
//   Color iconBgColor = Colors.white,
//   Color textColor = Colors.black,
// }) {
//   final snackBar = SnackBar(
//     behavior: SnackBarBehavior.floating,
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     duration: const Duration(seconds: 50),
//     content: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white, width: 2),
//       ),
//       child: Row(
//         children: [
//           /// Left Icon Circle
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: iconBgColor,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: backgroundColor, size: 24),
//           ),

//           const SizedBox(width: 12),

//           /// Text
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: textColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (subtitle != null)
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: textColor.withOpacity(0.8),
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           /// Right Star Icon
//           Icon(Icons.star, color: Colors.amber.shade700),
//         ],
//       ),
//     ),
//   );

//   ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(snackBar);
// }

void showCustomSnackBar({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Color backgroundColor,
  required IconData icon,
  Color iconBgColor = Colors.white,
  Color textColor = Colors.black,
}) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(seconds: 2),

    
    margin: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.75, 
    ),

    content: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(200), width: 1),
      ),
      child: Row(
        children: [
          /// Left Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: backgroundColor, size: 24),
          ),

          const SizedBox(width: 12),

          /// Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withValues(alpha:0.8),
                      // color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // Icon(Icons.star, color: Colors.amber),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
