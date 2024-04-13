import 'dart:ui';

var pixelRatio = window.devicePixelRatio;
var logicalScreenSize = window.physicalSize / pixelRatio;
var screenWidth = logicalScreenSize.width;
var screenHeight = logicalScreenSize.height;
