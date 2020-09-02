import 'package:flutter/material.dart';

import '../errors/wrapper_exception.dart';

enum FawkesWrapperType { FILL, FIT, CONTAIN }

/// This class provides an easy to define how the video player ui is laid out
/// on the screen
class FawkesWrapperProperties {
  /// If you select `FILL` the video player will occupy all space that is available to it,
  /// If you select `CONTAIN` you can specify the different attributes of the container in which we will
  /// wrap the video player,
  /// If you select `FIT`, then the video player will auto-fit as per the aspect ratio of the video
  final FawkesWrapperType wrapperType;

  /// Height of the container which will enclose the player
  /// This value cannot be null if the value of fillParent is `false`
  final double height;

  /// Width of the container which will enclose the player
  /// This value cannot be null if the value of fillParent is `false`
  final double width;

  /// Margin to apply to the container which will enclose the player
  /// The default value is `EdgeInsets.zero`
  final EdgeInsetsGeometry margin;

  /// Padding to apply to the container which will enclose the player
  /// The default value is `EdgeInsets.zero`
  final EdgeInsetsGeometry padding;

  /// BoxDecoration for the container which will enclose the player
  final BoxDecoration boxDecoration;

  FawkesWrapperProperties({
    this.wrapperType = FawkesWrapperType.FIT,
    this.height,
    this.width,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.boxDecoration,
  }) {
    if (wrapperType == null) {
      throw FawkesWrapperException(
          message: 'The value of wrapper type cannot be null');
    }
    if (wrapperType == FawkesWrapperType.CONTAIN &&
        (height == null || width == null || height < 0.0 || width < 0.0)) {
      throw FawkesWrapperException(
          message:
              'If the value of wrapperType is CONTAIN, positive double values for height and width must be provided.');
    }
  }
}
