import 'package:flutter/material.dart';
import 'package:lab_monitor/screens/pages/dummy_dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lab_monitor/utils/responsive_utils.dart';

class DummySignInPage extends StatefulWidget {
  const DummySignInPage({super.key});

  @override
  _DummySignInPageState createState() => _DummySignInPageState();
}

class _DummySignInPageState extends State<DummySignInPage> with TickerProviderStateMixin {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Color constants - light theme
  final Color primaryColor = const Color(0xFF4169E1);
  final Color backgroundColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color errorColor = const Color(0xFFE53935);
  final Color dividerColor = Colors.grey.shade300;

  // State variables
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage();

  // Animation controllers for slide-up effect
  AnimationController? _animationController;
  Animation<double>? _containerAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animation for the bottom container
    _containerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOut,
      ),
    );

    // Create fade-in animation for form elements
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController!.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _dummySignIn() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate storing the email ID
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      await _secureStorage.write(key: 'email', value: email);

      // Navigate to the Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DummyDashboard()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Opacity overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Bottom container
                    AnimatedBuilder(
                      animation: _animationController ?? const AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        return Positioned(
                          bottom: -constraints.maxHeight * 0.7 * (_containerAnimation?.value ?? 0.0),
                          left: 0,
                          right: 0,
                          child: child!,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getMediumSpace(context),
                          vertical: ResponsiveUtils.getSmallSpace(context),
                        ),
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveUtils.isDesktop(context) ? 450 : double.infinity,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: AnimatedBuilder(
                            animation: _fadeAnimation ?? const AlwaysStoppedAnimation(0),
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation?.value ?? 1.0,
                                child: child,
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: ResponsiveUtils.getSmallSpace(context)),
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getHeadingSize(context),
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getMediumSpace(context)),
                                _buildTextField(
                                  label: 'Email',
                                  controller: _emailController,
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: ResponsiveUtils.getSmallSpace(context)),
                                _buildTextField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  icon: Icons.lock,
                                  isPassword: true,
                                ),
                                SizedBox(height: ResponsiveUtils.getSmallSpace(context)),

                                // Remember me & Forgot password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: ResponsiveUtils.isSmallPhone(context) ? 0.9 : 1.0,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor: primaryColor,
                                            checkColor: Colors.white,
                                            side: BorderSide(
                                              color: dividerColor.withOpacity(0.8),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Remember me',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getSmallTextSize(context),
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: ResponsiveUtils.getSmallSpace(context) * 0.8),
                                        minimumSize: Size.zero,
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: ResponsiveUtils.getSmallTextSize(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: ResponsiveUtils.getMediumSpace(context)),

                                // Sign In button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _dummySignIn,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, ResponsiveUtils.getButtonHeight(context)),
                                    backgroundColor: primaryColor,
                                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: ResponsiveUtils.isSmallPhone(context) ? 18 : 22,
                                          width: ResponsiveUtils.isSmallPhone(context) ? 18 : 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: ResponsiveUtils.isSmallPhone(context) ? 1.5 : 2,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getBodySize(context),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),

                                SizedBox(height: ResponsiveUtils.getSmallSpace(context) * 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 4,
            bottom: ResponsiveUtils.getSmallSpace(context) * 0.6,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: ResponsiveUtils.getSmallTextSize(context) + 1,
            ),
          ),
        ),
        Container(
          height: ResponsiveUtils.getInputHeight(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_passwordVisible,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodySize(context) * 0.9,
              color: textColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.isSmallPhone(context) ? 14 : 17,
                horizontal: ResponsiveUtils.isSmallPhone(context) ? 16 : 20,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter your $label',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: ResponsiveUtils.getSmallTextSize(context) + 1,
              ),
              prefixIcon: Icon(
                icon,
                color: primaryColor,
                size: ResponsiveUtils.getIconSize(context) * 0.9,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: primaryColor,
                        size: ResponsiveUtils.getIconSize(context) * 0.9,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: dividerColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: dividerColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            cursorColor: primaryColor,
          ),
        ),
      ],
    );
  }
}