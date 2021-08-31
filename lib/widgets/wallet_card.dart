import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTapped;

  WalletCard({
     this.title,
     this.subtitle,
     this.onTapped,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xFFfff9f9),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTapped,
        child: Container(
          padding: EdgeInsets.all(18),
          width: double.infinity,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: textColor),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
