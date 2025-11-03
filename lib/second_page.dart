import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'xgboost_predictor.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
 State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with TickerProviderStateMixin {
  // Animations
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late AnimationController _floatController;
  late Animation<Offset> _offsetAnimation;

  double _screenWidth = 400.0;

  // State
  bool _isLoading = false;
  String? _selectedCategory;
  int? _selectedBoxIndex;

  // Prediction result
  File? _uploadedImage;
  String? _predictionResult;
  bool _showResult = false;

  final XGBoostPredictor _predictor = XGBoostPredictor();

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _tapController, curve: Curves.easeInOut);
    _tapController.forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.1),
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _screenWidth = MediaQuery.of(context).size.width);
      }
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> _pickImage(BuildContext context) async {
    if (_selectedCategory == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _processImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _processImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      final XFile? xFile = await ImagePicker().pickImage(source: source);
      if (xFile == null || !mounted) return;

      final File imageFile = File(xFile.path);
      final prediction = await _predictor.predictFromImage(imageFile, _selectedCategory!);

      if (!mounted) return;

      setState(() {
        _uploadedImage = imageFile;
        _predictionResult = prediction;
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBoxSelection(int index, String category) {
    if (category == 'Info') return;
    setState(() {
      _selectedCategory = category;
      _selectedBoxIndex = index;
    });
  }

  Widget buildInfoBox({
    required String backgroundImage,
    required String title,
    required String description,
    required int index,
    required String category,
  }) {
    final double slideDistance = (index % 2 == 0) ? -_screenWidth : _screenWidth;
    final bool isSelected = _selectedBoxIndex == index;

    const int baseDelay = 1300;
    const int stagger = 800;
    final Duration duration = Duration(milliseconds: baseDelay + index * stagger);

    return TweenAnimationBuilder<double>(
      key: ValueKey('initial_slide_$index'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        final double opacity = (value * 2).clamp(0.0, 1.0);
        final double slideX = slideDistance * (1 - value);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(slideX, 0), child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _handleBoxSelection(index, category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          height: 150,
          transform: Matrix4.identity()
            ..translate(0.0, isSelected ? -6.0 : 0.0)
            ..scale(isSelected ? 1.02 : 1.0),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(backgroundImage), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DRAGGABLE RESULT SHEET – VANISH ON DRAG DOWN
  Widget _buildResultSheet() {
    if (!_showResult || _uploadedImage == null || _predictionResult == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.2,   // Starts small (your design)
      minChildSize: 0.0,       // Can go to 0 → vanish
      maxChildSize: 0.7,       // Expands up to 70%
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // VANISH WHEN DRAGGED DOWN
              if (notification.extent < 0.1) {
                setState(() => _showResult = false);
              }
              return true;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Small preview (visible at start)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Prediction: $_predictionResult',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Full result (revealed when dragged up)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _uploadedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Model: $_selectedCategory Luffa',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7DABF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.green, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  buildInfoBox(
                    backgroundImage: 'assets/images/widget1.png',
                    title: 'Luffa Leaf Diagnosis',
                    description: 'Tap to upload a leaf image.\nGet instant feedback on plant health and disease risk.',
                    index: 0,
                    category: 'Info',
                  ),
                  buildInfoBox(
                    backgroundImage: 'assets/images/widget2.png',
                    title: 'Smooth Luffa',
                    description: 'Healthy or mildly affected leaf with even surface and minimal distortion.',
                    index: 1,
                    category: 'Smooth',
                  ),
                  buildInfoBox(
                    backgroundImage: 'assets/images/widget3.png',
                    title: 'Spoonge Luffa',
                    description: 'Leaf appears porous, uneven, or swollen-often a sign of fungal or bacterial infection.',
                    index: 2,
                    category: 'Spoonge',
                  ),

                  const SizedBox(height: 40),

                  if (_selectedCategory == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Tap on Smooth or Spoonge to select model',
                        style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_isLoading) ...[
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing $_selectedCategory Luffa...',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    SlideTransition(
                      position: _offsetAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTapDown: (_) => _tapController.reverse(),
                          onTapUp: (_) {
                            _tapController.forward();
                            _pickImage(context);
                          },
                          onTapCancel: () => _tapController.forward(),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset('assets/images/camera.png', width: 80, height: 80),
                                  if (_selectedCategory != null)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                                        ),
                                        child: Text(
                                          _selectedCategory == 'Smooth' ? 'SM' : 'SP',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeIn,
                                builder: (context, double opacity, child) {
                                  return Opacity(opacity: opacity, child: child!);
                                },
                                child: Text(
                                  _selectedCategory != null ? 'Tap to analyze $_selectedCategory' : 'Tap the camera',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for sheet
                  ],
                ],
              ),
            ),

            // Draggable result sheet (from bottom)
            if (_showResult) _buildResultSheet(),
          ],
        ),
      ),
    );
  }
}