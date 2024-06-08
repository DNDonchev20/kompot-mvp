import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DeletePopup extends StatelessWidget {
  DeletePopup({Key? key, required this.onClickDelete}) : super(key: key);

  final Function onClickDelete;

  final String title = translate('delete_popup_page.title');
  final String yesButton = translate('delete_popup_page.yes_button');
  final String noButton = translate('delete_popup_page.no_button');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 246, 244, 244),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  onClickDelete(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
                child: Text(yesButton),
              ),
              ElevatedButton(
                onPressed: () {
                  onClickDelete(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text(noButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
