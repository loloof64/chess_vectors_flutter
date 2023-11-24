import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

/// Returns an equivalent VectorImagePainter but also setting size of its image.
VectorImagePainter painterWithDrawingZoneAndBaseImageSizeSet(
    VectorImagePainter originPainter, double baseImageSize) {
  return VectorImagePainter(
    vectorDefinition: originPainter.vectorDefinition,
    baseImageSize: baseImageSize,
  );
}

/// The base definition of a Vector Widget.
abstract class VectorBase extends CustomPaint {
  /// Both painter and baseImagesSize are required
  /// painter (VectorImagePainter) : the Painter that helps use draw the Vector
  /// baseImageSize (double) : the size of the original image
  /// requestSize (double) : the wanted size
  VectorBase({
    required VectorImagePainter painter,
    required double baseImageSize,
    required double requestSize,
  }) : super(
            painter: painterWithDrawingZoneAndBaseImageSizeSet(
                painter, baseImageSize),
            size: Size.square(requestSize));
}

/// CustomPaint used for drawing Vector elements into a canvas.
class VectorImagePainter extends CustomPainter {
  /// Elements that compose the Vector to be drawn
  List<VectorDrawableElement> vectorDefinition;

  /// Size of the original image
  double? baseImageSize;

  /// Only vectorDefinition is required
  /// vectorDefinition (List of VectorDrawableElement) : Elements that compose the Vector to be drawn
  /// baseImageSize (double) : Size of the original image
  VectorImagePainter({
    required this.vectorDefinition,
    this.baseImageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(size.width / baseImageSize!, size.height / baseImageSize!);

    vectorDefinition.forEach((VectorDrawableElement vectorElement) {
      vectorElement.paintIntoCanvas(canvas, vectorElement.drawingParameters);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// Use each property of childDrawingParameters in priority, and properties of
/// parentDrawingParameters if not defined in child parameters.
/// Note that it is allowed for a property that both definitions are null.
DrawingParameters mergeDrawingParameters(
    DrawingParameters childDrawingParameters,
    DrawingParameters? parentDrawingParameters) {
  DrawingParameters usedDrawingParameters = DrawingParameters(
      fillColor: childDrawingParameters.fillColor ??
          parentDrawingParameters!.fillColor,
      strokeColor: childDrawingParameters.strokeColor ??
          parentDrawingParameters!.strokeColor,
      strokeWidth: childDrawingParameters.strokeWidth ??
          parentDrawingParameters!.strokeWidth,
      strokeLineCap: childDrawingParameters.strokeLineCap ??
          parentDrawingParameters!.strokeLineCap,
      strokeLineJoin: childDrawingParameters.strokeLineJoin ??
          parentDrawingParameters!.strokeLineJoin,
      strokeLineMiterLimit: childDrawingParameters.strokeLineMiterLimit ??
          parentDrawingParameters!.strokeLineMiterLimit,
      translate: childDrawingParameters.translate ??
          parentDrawingParameters!.translate,
      transformMatrixValues: childDrawingParameters.transformMatrix ??
          parentDrawingParameters!.transformMatrix);
  return usedDrawingParameters;
}

/// Just a translation from List of double to a Float64List.
Float64List? convertListIntoMatrix4(List<double>? matrixValues) {
  if (matrixValues == null) return null;
  return Float64List.fromList(<double>[
    matrixValues[0],
    matrixValues[1],
    0.0,
    0.0,
    matrixValues[2],
    matrixValues[3],
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    matrixValues[4],
    matrixValues[5],
    0.0,
    1.0
  ]);
}

/// Drawing parameters for each element of the Vector
class DrawingParameters {
  /// Fill color : null for the absence of fill color.
  Color? fillColor;

  /// Stroke color: null for the absence of stroke color.
  Color? strokeColor;

  /// Stroke width
  double? strokeWidth;

  /// Stroke line cap : null for the absence of stroke line cap.
  StrokeCap? strokeLineCap;

  /// Stroke line join : null for the absence of stroke line join.
  StrokeJoin? strokeLineJoin;

  /// Stroke line miter limit
  double? strokeLineMiterLimit;

  /// Translation of the element : null for the absence of translation.
  Offset? translate;

  /// Transform matrix of the element :  null for the absence of transform matrix.
  Float64List? transformMatrix;

  /// Constructor : all values are optional.
  /// fillColor (Color) : Fill color : null for the absence of fill color.
  /// strokeColor (Color) : Stroke color: null for the absence of stroke color.
  /// strokeWidth (double)
  /// strokeLineCap (StrokeCap) : Stroke line cap : null for the absence of stroke line cap.
  /// strokeLineJoin (StrokeJoin) : Stroke line join : null for the absence of stroke line join.
  /// strokeLineMiterLimit (double) : Stroke line miter limit
  /// translate (Offset) : Translation of the element : null for the absence of translation.
  /// transformMatrix (Float64List) : Transform matrix of the element :  null for the absence of transform matrix.
  DrawingParameters(
      {this.fillColor,
      this.strokeColor,
      this.strokeWidth,
      this.strokeLineCap,
      this.strokeLineJoin,
      this.translate,
      this.strokeLineMiterLimit,
      List<double>? transformMatrixValues})
      : transformMatrix = convertListIntoMatrix4(transformMatrixValues);

  @override
  String toString() {
    return "DrawingParameters("
        "fillColor = $fillColor,"
        "strokeColor = $strokeColor,"
        "strokeWidth = $strokeWidth,"
        "strokeLineCap = $strokeLineCap,"
        "strokeLineJoin = $strokeLineJoin,"
        "strokeLineMiterLimit = $strokeLineMiterLimit,"
        "translate = $translate,"
        "transfromMatrix = $transformMatrix"
        ")";
  }
}

/// A drawable element of the Vector.
abstract class VectorDrawableElement {
  /// Drawing parameters for this element
  DrawingParameters? drawingParameters;

  /// drawingParameters (DrawingParameters) : Drawing parameters for this element
  VectorDrawableElement(this.drawingParameters);

  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters);
}

/// A Vector group element (<g>).
class VectorImageGroup extends VectorDrawableElement {
  /// Children elements of this Group
  List<VectorDrawableElement>? children;

  /// children (List of VectorDrawableElement) : Children elements of this Group
  /// drawingParameters (DrawingParameters) : drawing parameters for this Group
  VectorImageGroup({
    this.children,
    DrawingParameters? drawingParameters,
  }) : super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    children!.forEach((VectorDrawableElement currentChild) {
      currentChild.paintIntoCanvas(targetCanvas, usedDrawingParameters);
    });
  }
}

/// A Vector circle element.
class VectorCircle extends VectorDrawableElement {
  /// Position of the Circle
  Offset position;

  /// Radius of the Circle
  double radius;

  /// position (Offset) REQUIRED : Position of the Circle
  /// radius (double) REQUIRED : Radius of the Circle
  /// drawingParameters (DrawingParameters) : drawing parameters for this Circle
  VectorCircle(
      {required this.position,
      required this.radius,
      DrawingParameters? drawingParameters})
      : super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    var commonPath = new Path()
      ..addOval(Rect.fromPoints(position.translate(-radius, -radius),
          position.translate(radius, radius)));

    if (usedDrawingParameters.fillColor != null) {
      var fillPathPaint = new Paint()
        ..style = PaintingStyle.fill
        ..color = usedDrawingParameters.fillColor!;
      targetCanvas.drawPath(commonPath, fillPathPaint);
    }

    var strokePathPaint = new Paint()
      ..style = PaintingStyle.stroke
      ..color = usedDrawingParameters.strokeColor!
      ..strokeWidth = usedDrawingParameters.strokeWidth!;
    targetCanvas.drawPath(commonPath, strokePathPaint);
  }
}

/// A Vector path element (<path>).
class VectorImagePathDefinition extends VectorDrawableElement {
  /// Elements of this path
  List<PathElement> pathElements;

  /// path (string) REQUIRED : path definition ('d' attribute)
  /// drawingParameters (DrawingParameters) : drawing parameters for this Circle
  VectorImagePathDefinition({
    required String path,
    DrawingParameters? drawingParameters,
  })  : pathElements = parsePath(path),
        super(drawingParameters);

  @override
  void paintIntoCanvas(
      Canvas targetCanvas, DrawingParameters? parentDrawingParameters) {
    DrawingParameters usedDrawingParameters =
        mergeDrawingParameters(drawingParameters!, parentDrawingParameters);

    targetCanvas.save();
    if (drawingParameters!.transformMatrix != null) {
      targetCanvas.transform(drawingParameters!.transformMatrix!);
    }
    if (drawingParameters!.translate != null) {
      targetCanvas.translate(
          drawingParameters!.translate!.dx, drawingParameters!.translate!.dy);
    }

    var commonPath = new Path();
    pathElements.forEach((PathElement element) {
      element.addToPath(commonPath);
    });

    if (usedDrawingParameters.fillColor != null) {
      var fillPathPaint = new Paint()
        ..style = PaintingStyle.fill
        ..color = usedDrawingParameters.fillColor!;
      targetCanvas.drawPath(commonPath, fillPathPaint);
    }

    var strokePathPaint = new Paint()
      ..style = PaintingStyle.stroke
      ..color = usedDrawingParameters.strokeColor!
      ..strokeWidth = usedDrawingParameters.strokeWidth!;
    if (usedDrawingParameters.strokeLineCap != null) {
      strokePathPaint.strokeCap = usedDrawingParameters.strokeLineCap!;
    }
    if (usedDrawingParameters.strokeLineJoin != null) {
      strokePathPaint.strokeJoin = usedDrawingParameters.strokeLineJoin!;
    }
    if (usedDrawingParameters.strokeLineMiterLimit != null) {
      strokePathPaint.strokeMiterLimit =
          usedDrawingParameters.strokeLineMiterLimit!;
    }
    targetCanvas.drawPath(commonPath, strokePathPaint);

    targetCanvas.restore();
  }
}

/// Element of a Path integrated into a Vector
abstract class PathElement {
  /// add the given path to the PathElement
  void addToPath(Path path);

  /// gets the end point of the path element
  Offset get end;
}

/// Path element of type MoveTo
class MoveElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// Move x and y if not relative, otherwise move dx and dy.
  Offset moveParams;

  /// startPoint (Offset) REQUIRED
  /// moveParams (Offset) REQUIRED : Move x and y if not relative, otherwise move dx and dy.
  /// relative (bool) REQUIRED : Is it a relative move ?
  MoveElement({
    required this.startPoint,
    required this.moveParams,
    required this.relative,
  });

  @override // ignore: missing_function_body
  void addToPath(Path path) {
    if (relative) {
      path.relativeMoveTo(moveParams.dx, moveParams.dy);
      return;
    } else {
      path.moveTo(moveParams.dx, moveParams.dy);
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx + moveParams.dx, startPoint.dy + moveParams.dy)
      : Offset(moveParams.dx, moveParams.dy);

  @override
  String toString() {
    return "MoveElement("
        "startPoint = $startPoint, "
        "relative = $relative, "
        "moveParams = $moveParams"
        ")";
  }
}

/// Path element of type Close
class CloseElement extends PathElement {
  @override
  void addToPath(Path path) {
    path.close();
  }

  @override
  Offset get end => Offset.infinite;

  @override
  String toString() {
    return "CloseElement()";
  }
}

/// Path element of type Line
class LineElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// Line x and y if not relative, otherwise move dx and dy.
  Offset lineParams;

  /// startPoint (Offset) REQUIRED
  /// lineParams (Offset) REQUIRED : Line x and y if not relative, otherwise line dx and dy.
  /// relative (bool) REQUIRED :Is it a relative line ?
  LineElement({
    required this.startPoint,
    required this.lineParams,
    required this.relative,
  });

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeLineTo(lineParams.dx, lineParams.dy);
    } else {
      path.lineTo(lineParams.dx, lineParams.dy);
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx + lineParams.dx, startPoint.dy + lineParams.dy)
      : Offset(lineParams.dx, lineParams.dy);

  @override
  String toString() {
    return "LineElement("
        "startPoint = $startPoint, "
        "relative = $relative, "
        "lineParams = $lineParams"
        ")";
  }
}

/// Path element of type CubicCurve
class CubicCurveElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// First control point
  Offset firstControlPoint;

  /// Second control point
  Offset secondControlPoint;

  /// End point
  Offset endPoint;

  /// startPoint (Offset) REQUIRED
  /// relative (bool) REQUIRED : Is it a relative move ?
  /// firstControlPoint (Offset) REQUIRED : First control point
  /// secondControlPoint (Offset) REQUIRED : Second control point
  /// endPoint (Offset) REQUIRED : end point
  CubicCurveElement({
    required this.startPoint,
    required this.relative,
    required this.firstControlPoint,
    required this.secondControlPoint,
    required this.endPoint,
  });

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeCubicTo(
          firstControlPoint.dx,
          firstControlPoint.dy,
          secondControlPoint.dx,
          secondControlPoint.dy,
          endPoint.dx,
          endPoint.dy);
    } else {
      path.cubicTo(
          firstControlPoint.dx,
          firstControlPoint.dy,
          secondControlPoint.dx,
          secondControlPoint.dy,
          endPoint.dx,
          endPoint.dy);
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx + endPoint.dx, startPoint.dy + endPoint.dy)
      : Offset(endPoint.dx, endPoint.dy);

  @override
  String toString() {
    return "CubicCurveElement("
        "startPoint = $startPoint, "
        "relative = $relative, "
        "firstControlPoint = $firstControlPoint,"
        "secondControlPoint = $secondControlPoint,"
        "endPoint = $endPoint"
        ")";
  }
}

/// Path element of type Arc
class ArcElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// Radius
  Offset radius;

  /// Rotation along X axis
  double xAxisRotation;

  /// Arc end
  Offset arcEnd;

  /// startPoint (Offset) REQUIRED
  /// relative (bool) REQUIRED : Is it a relative move ?
  /// radius (Offset) REQUIRED : Radius
  /// xAxisRotation (double) REQUIRED : Rotation along x axis
  /// arcEnd (Offset) REQUIRED : Arc end point
  ArcElement(
      {required this.startPoint,
      required this.relative,
      required this.radius,
      required this.xAxisRotation,
      required this.arcEnd});

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeArcToPoint(
        arcEnd,
        rotation: xAxisRotation,
        radius: Radius.elliptical(radius.dx, radius.dy),
      );
    } else {
      path.arcToPoint(
        arcEnd,
        rotation: xAxisRotation,
        radius: Radius.elliptical(radius.dx, radius.dy),
      );
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx + arcEnd.dx, startPoint.dy + arcEnd.dy)
      : Offset(arcEnd.dx, arcEnd.dy);

  @override
  String toString() {
    return "ArcElement("
        "startPoint = $startPoint, "
        "relative = $relative, "
        "radius = $radius,"
        "xAxisRotation = $xAxisRotation,"
        "arcEnd = $arcEnd"
        ")";
  }
}

/// An horizontal line element
class HorizontalLineElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// target x
  double targetX;

  /// startPoint (Offset) REQUIRED
  /// relative (bool) REQUIRED : Is it a relative move ?
  /// targetX (double) REQUIRED
  HorizontalLineElement({
    required this.startPoint,
    required this.relative,
    required this.targetX,
  });

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeLineTo(targetX, 0);
    } else {
      path.lineTo(targetX, startPoint.dy);
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx + targetX, startPoint.dy)
      : Offset(targetX, startPoint.dy);

  @override
  String toString() {
    return "HorizontalLineElement("
        "startPoint = $startPoint, "
        "targetX = $targetX)";
  }
}

/// A vertical line element
class VerticalLineElement extends PathElement {
  /// Current path starting point
  Offset startPoint;

  /// Is it a relative move ?
  bool relative;

  /// target y
  double targetY;

  /// startPoint (Offset) REQUIRED
  /// relative (bool) REQUIRED : Is it a relative move ?
  /// targetY (double) REQUIRED
  VerticalLineElement({
    required this.startPoint,
    required this.relative,
    required this.targetY,
  });

  @override
  void addToPath(Path path) {
    if (relative) {
      path.relativeLineTo(0, targetY);
    } else {
      path.lineTo(startPoint.dx, targetY);
    }
  }

  @override
  Offset get end => relative
      ? Offset(startPoint.dx, startPoint.dy + targetY)
      : Offset(startPoint.dx, targetY);

  @override
  String toString() {
    return "VerticalLineElement("
        "startPoint = $startPoint, "
        "targetY = $targetY)";
  }
}

/// Transform a path definition (value of 'd' attribute in SVG <path> tag) into
/// a List of PathElement.
List<PathElement> parsePath(String pathStr) {
  var startPoint = Offset.zero;
  Tuple3<PathElement, String, Offset>? interpretCommand(
      RegExp commandRegex, String input, Offset startPoint) {
    var commandInterpretation = commandRegex.firstMatch(input);
    if (commandInterpretation == null) return null;

    var commandType = commandInterpretation.group(1)!;
    var relativeCommand = commandType.toLowerCase() == commandType;
    switch (commandType) {
      case 'M':
      case 'm':
        var element = MoveElement(
            startPoint: startPoint,
            relative: relativeCommand,
            moveParams: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'L':
      case 'l':
        var element = LineElement(
            startPoint: startPoint,
            relative: relativeCommand,
            lineParams: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'c':
      case 'C':
        var element = CubicCurveElement(
            startPoint: startPoint,
            relative: relativeCommand,
            firstControlPoint: Offset(
                double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)),
            secondControlPoint: Offset(
                double.parse(commandInterpretation.group(4)!),
                double.parse(commandInterpretation.group(5)!)),
            endPoint: Offset(double.parse(commandInterpretation.group(6)!),
                double.parse(commandInterpretation.group(7)!)));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'a':
      case 'A':
        var element = ArcElement(
            startPoint: startPoint,
            relative: relativeCommand,
            radius: Offset(double.parse(commandInterpretation.group(2)!),
                double.parse(commandInterpretation.group(3)!)),
            arcEnd: Offset(double.parse(commandInterpretation.group(7)!),
                double.parse(commandInterpretation.group(8)!)),
            xAxisRotation: double.parse(commandInterpretation.group(4)!));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'z':
      case 'Z':
        var element = CloseElement();
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'h':
      case 'H':
        var element = HorizontalLineElement(
            startPoint: startPoint,
            relative: relativeCommand,
            targetX: double.parse(commandInterpretation.group(2)!));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
      case 'v':
      case 'V':
        var element = VerticalLineElement(
            startPoint: startPoint,
            relative: relativeCommand,
            targetY: double.parse(commandInterpretation.group(2)!));
        startPoint = element.end;
        var remainingPathStr = input.substring(commandInterpretation.end);
        return Tuple3<PathElement, String, Offset>(
            element, remainingPathStr, element.end);
    }
    return null;
  }

  String valueFormat = r"(\d+(?:\.\d+)?)";
  String separatorFormat = r"(?:\s+|,)";

  var moveRegex =
      RegExp("^(M|m)$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var lineRegex =
      RegExp("^(L|l)$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var cubicCurveRegex = RegExp(
      "^(C|c)$separatorFormat$valueFormat$separatorFormat" +
          "$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat" +
          "$valueFormat$separatorFormat$valueFormat");
  var arcRegex = RegExp(
      "^(A|a)$separatorFormat$valueFormat$separatorFormat$valueFormat" +
          "$separatorFormat$valueFormat$separatorFormat$valueFormat$separatorFormat$valueFormat" +
          "$separatorFormat$valueFormat$separatorFormat$valueFormat");
  var horizontalLineRegex = RegExp("^(H|h)$separatorFormat$valueFormat");
  var verticalLineRegex = RegExp("^(V|v)$separatorFormat$valueFormat");
  var closeRegex = RegExp("^(z)");

  var elementsToReturn = <PathElement>[];
  var remainingPath = pathStr.trim();

  while (remainingPath.isNotEmpty) {
    var moveElementTuple =
        interpretCommand(moveRegex, remainingPath, startPoint);
    var lineElementTuple =
        interpretCommand(lineRegex, remainingPath, startPoint);
    var cubicCurveElementTuple =
        interpretCommand(cubicCurveRegex, remainingPath, startPoint);
    var arcElementTuple = interpretCommand(arcRegex, remainingPath, startPoint);
    var horizontalLineElementTuple =
        interpretCommand(horizontalLineRegex, remainingPath, startPoint);
    var verticalLineElementTuple =
        interpretCommand(verticalLineRegex, remainingPath, startPoint);
    var closeElementTuple =
        interpretCommand(closeRegex, remainingPath, startPoint);

    if (moveElementTuple != null) {
      elementsToReturn.add(moveElementTuple.item1);
      remainingPath = moveElementTuple.item2.trim();
      startPoint = moveElementTuple.item1.end;
    } else if (lineElementTuple != null) {
      elementsToReturn.add(lineElementTuple.item1);
      remainingPath = lineElementTuple.item2.trim();
      startPoint = lineElementTuple.item1.end;
    } else if (cubicCurveElementTuple != null) {
      elementsToReturn.add(cubicCurveElementTuple.item1);
      remainingPath = cubicCurveElementTuple.item2.trim();
      startPoint = cubicCurveElementTuple.item1.end;
    } else if (arcElementTuple != null) {
      elementsToReturn.add(arcElementTuple.item1);
      remainingPath = arcElementTuple.item2.trim();
      startPoint = arcElementTuple.item1.end;
    } else if (horizontalLineElementTuple != null) {
      elementsToReturn.add(horizontalLineElementTuple.item1);
      remainingPath = horizontalLineElementTuple.item2.trim();
      startPoint = horizontalLineElementTuple.item1.end;
    } else if (verticalLineElementTuple != null) {
      elementsToReturn.add(verticalLineElementTuple.item1);
      remainingPath = verticalLineElementTuple.item2.trim();
      startPoint = verticalLineElementTuple.item1.end;
    } else if (closeElementTuple != null) {
      elementsToReturn.add(closeElementTuple.item1);
      remainingPath = closeElementTuple.item2.trim();
    } else
      throw "Unrecognized path in $remainingPath !";
  }

  return elementsToReturn;
}
