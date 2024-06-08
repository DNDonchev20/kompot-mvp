import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.titleInfo,
    required this.descriptionInfo,
    required this.imageUrl,
    required this.textColor,
    required this.backgroundColor,
    required this.ratio,
  }) : super(key: key);

  final String titleInfo;
  final String descriptionInfo;
  final String imageUrl;
  final Color textColor;
  final Color backgroundColor;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    double radius = 65 + (5 * (1 / ratio.clamp(1, 25)));
    double titleFontSize = 20 + (4 * (1 / ratio.clamp(1, 25)));
    double descriptionFontSize = 14 + (2 * (1 / ratio.clamp(1, 25)));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: radius,
            height: radius,
            child: imageUrl.isNotEmpty
                ? Container(
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(width: 0.50),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: imageUrl,
                        fit: BoxFit.contain,
                        fadeInDuration: const Duration(milliseconds: 300),
                        fadeOutDuration: const Duration(milliseconds: 300),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Container();
                        },
                      ),
                    ),
                  )
                : Container(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    titleInfo,
                    style: TextStyle(
                      color: textColor,
                      fontSize: titleFontSize,
                      fontFamily: 'VarelaRound',
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    descriptionInfo,
                    style: TextStyle(
                      color: textColor,
                      fontSize: descriptionFontSize,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
