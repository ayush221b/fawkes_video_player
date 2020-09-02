import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FawkesLoadingIndicator extends StatelessWidget {
  // Whether to include the loading text or not
  final bool includeText;

  const FawkesLoadingIndicator({Key key, this.includeText = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (includeText)
          Text(
            'Loading',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        if (includeText)
          SizedBox(
            width: 10,
          ),
        SizedBox(
          height: 20,
          width: 20,
          child: Platform.isIOS
              ? CupertinoActivityIndicator()
              : CircularProgressIndicator(
                  strokeWidth: 2,
                ),
        ),
      ],
    );
  }
}
