import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowFullImage extends StatelessWidget {
  final String photoUrl;

  const ShowFullImage({Key key, this.photoUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: photoUrl == null || photoUrl.isEmpty
            ? AssetImage('assets/placeholder.png')
            : NetworkImage(photoUrl),
        loadingBuilder: (ctx, loadingProgress) {
          if (loadingProgress == null) return Container();

          return FractionallySizedBox(
            widthFactor: loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes,
            child: Container(
              color: Colors.grey[400].withOpacity(0.3),
            ),
            alignment: Alignment.centerLeft,
          );
        },
      ),
    );
    // return Container(
    //     child: Image.network(
    //   photoUrl,
    // ));
  }
}