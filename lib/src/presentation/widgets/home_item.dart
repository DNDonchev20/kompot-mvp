import 'package:flutter/material.dart';

import 'package:kompot/utils.dart';

class HomeItem extends StatelessWidget {
  const HomeItem({
    Key? key,
    required this.cardData,
    required this.rotations,
    required this.offsets,
    required this.ratio,
  }) : super(key: key);

  final Map<String, dynamic> cardData;
  final List<double> rotations;
  final List<Offset> offsets;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    int circleCount = int.tryParse(cardData['circleNumber'] ?? '') ?? 0;

    double radius = 60 + (10 * (1 / ratio.clamp(1, 25)));
    double stampRadius = 50 + (5 * (1 / ratio.clamp(1, 25)));

    String descriptionFormatted = cardData['text'].replaceAll('\\n', '\n');
    double descriptionFontSize = 12 + (2 * (1 / ratio.clamp(1, 25)));

    const double circleSpacing = 6.0;

    final int stampsOnLine = [1, 2, 3, 2, 3][(circleCount - 1).clamp(0, 4)];

    final double padding =
        [0, 50, 15, 40, 15][(circleCount - 1).clamp(0, 4)].toDouble();

    final double marginTop =
        [0, 100, 100, 50, 50, 30][(circleCount - 1).clamp(0, 5)].toDouble();

    final double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: parseColor(cardData['backgroundColor']),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: height * 0.045),
              SizedBox(
                width: radius,
                height: radius,
                child: cardData['logo'].isNotEmpty
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
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(cardData['logo']),
                                fit: BoxFit.fitHeight),
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ))
                    : Container(),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  descriptionFormatted,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: marginTop),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.0, crossAxisCount: stampsOnLine),
                    itemCount: circleCount,
                    itemBuilder: (content, index) {
                      if (index < cardData['stampCount']) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: stampRadius,
                              height: stampRadius,
                              margin: const EdgeInsets.all(circleSpacing),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            Transform.rotate(
                                angle: rotations[index],
                                child: Transform.translate(
                                    offset: offsets[index],
                                    child: Image.network(
                                      cardData['stamp'],
                                      width: stampRadius,
                                      height: stampRadius,
                                    ))),
                          ],
                        );
                      } else {
                        return Stack(alignment: Alignment.center, children: [
                          Container(
                            margin: const EdgeInsets.all(circleSpacing),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                              color: Colors.transparent,
                            ),
                          ),
                        ]);
                      }
                    },
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
