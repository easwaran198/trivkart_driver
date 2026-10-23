import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

class StartTripResult {
  final String otp;
  final String odometerReading;
  final String? imagePath;

  StartTripResult({
    required this.otp,
    required this.odometerReading,
    this.imagePath,
  });
}

class OtpVerificationDialog extends StatefulWidget {
  final bool isStartTrip;
  const OtpVerificationDialog({super.key, required this.isStartTrip});

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _odometerController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late int _step; // 0: OTP, 1: Odometer Verification
  int _secondsLeft = 30;
  Timer? _timer;
  XFile? _odometerImage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _step = widget.isStartTrip ? 0 : 1;
    if (widget.isStartTrip) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        if (mounted) {
          setState(() {
            _secondsLeft--;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _odometerController.dispose();
    super.dispose();
  }

  void _onNextStep() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppTheme.offlineRed,
        ),
      );
      return;
    }

    // Move to Step 2: Odometer details for both Start and End trip
    setState(() {
      _step = 1;
    });
  }

  Future<void> _captureOdometerPhoto() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      // Strictly capture from CAMERA ONLY as requested
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null && mounted) {
        setState(() {
          _odometerImage = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: AppTheme.offlineRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _onFinalSubmit() {
    final otp = _controllers.map((c) => c.text).join();
    final odometerReading = _odometerController.text.trim();

    if (odometerReading.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the current odometer reading (km)'),
          backgroundColor: AppTheme.offlineRed,
        ),
      );
      return;
    }

    if (_odometerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture an odometer photo using the camera'),
          backgroundColor: AppTheme.offlineRed,
        ),
      );
      return;
    }

    // Return StartTripResult
    Navigator.pop(
      context,
      StartTripResult(
        otp: otp,
        odometerReading: odometerReading,
        imagePath: _odometerImage?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _step == 0 ? _buildOtpStep() : _buildOdometerStep(),
      ),
    );
  }

  Widget _buildOtpStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isStartTrip ? 'Step 1/2: OTP Verification' : 'OTP Verification',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Divider(height: 18),
        const SizedBox(height: 6),
        Text(
          widget.isStartTrip
              ? 'Ask customer for the 6-digit OTP to start the trip'
              : 'Ask customer for the 6-digit OTP to end the trip',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),

        // 6-Digit Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 38,
              height: 48,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Resend OTP Timer
        Text(
          _secondsLeft > 0
              ? 'Resend OTP (00:${_secondsLeft.toString().padLeft(2, '0')})'
              : "Didn't receive OTP? Resend",
          style: const TextStyle(fontSize: 13, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),

        // Next / Continue Button
        ElevatedButton(
          onPressed: _onNextStep,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.isStartTrip ? 'Next: Odometer Reading' : 'Verify & End Trip'),
              if (widget.isStartTrip) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOdometerStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isStartTrip ? 'Step 2/2: Odometer Details' : 'End Trip: Odometer Details',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Divider(height: 18),
        Text(
          widget.isStartTrip
              ? 'Enter current odometer reading and capture photo using camera before starting.'
              : 'Enter final odometer reading and capture photo using camera to complete the trip.',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),

        // Odometer Reading Input
        const Text(
          'Odometer Reading (KM)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _odometerController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 45280',
            prefixIcon: const Icon(Icons.speed, color: AppTheme.primaryBlue),
            suffixText: 'km',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Camera Photo Capture Section (Camera ONLY)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Odometer Photo',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt, size: 12, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Camera Only',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Photo Preview or Camera Button
        if (_odometerImage == null)
          GestureDetector(
            onTap: _isCapturing ? null : _captureOdometerPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isCapturing
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.add_a_photo_outlined, size: 38, color: AppTheme.primaryBlue),
                  const SizedBox(height: 10),
                  const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Click to open live camera and snap odometer',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.onlineGreen, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.file(
                        File(_odometerImage!.path),
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: AppTheme.onlineGreen),
                              SizedBox(width: 4),
                              Text(
                                'Attached',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _captureOdometerPhoto,
                          icon: const Icon(Icons.camera_alt, size: 16, color: AppTheme.primaryBlue),
                          label: const Text('Retake Camera Photo', style: TextStyle(fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.offlineRed),
                          onPressed: () {
                            setState(() {
                              _odometerImage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Action Buttons: Back & Start Ride
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (widget.isStartTrip) {
                    setState(() {
                      _step = 0;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.isStartTrip ? 'Back' : 'Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.onlineGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _onFinalSubmit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.isStartTrip ? 'Start Ride' : 'Complete Trip',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
