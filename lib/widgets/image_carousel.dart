import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double width;

  const ImageCarousel({
    required this.imageUrls,
    required this.height,
    required this.width,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar at the top
        LinearProgressIndicator(
          value: (_currentPage + 1) / widget.imageUrls.length,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 8.0),
        // Image Swiping
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.fill,
              );
            },
          ),
        ),
        SizedBox(height: 8.0),
        // Current Image Indicator (e.g., 1/5)
        Text(
          '${_currentPage + 1}/${widget.imageUrls.length}',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
