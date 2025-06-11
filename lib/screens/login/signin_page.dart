import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lab_monitor/screens/pages/home_page.dart';
import 'package:lab_monitor/utils/responsive_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  // Add controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Add state variables
  bool _rememberMe = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _passwordVisible = false;

  // API URL
  final String _loginUrl = 'http://localhost:8080/api/v1/login';

  // Color constants - light theme
  final Color primaryColor = const Color(0xFF4169E1);
  final Color backgroundColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color errorColor = const Color(0xFFE53935);
  final Color dividerColor = Colors.grey.shade300;

  // Animation controllers for slide-up effect
  AnimationController? _animationController;
  Animation<double>? _containerAnimation;
  Animation<double>? _fadeAnimation;

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage();

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
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after a short delay
    Future.delayed(Duration(milliseconds: 100), () {
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

  Future<void> _signInWithEmailAndPassword() async {
    // Clear previous error messages
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Validate input fields
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save the token securely
        final token = responseData['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

        // Navigate to the landing page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['error'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to connect to the server. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                // Remove fixed height and let content determine the height
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
                          // Remove fixed height attribute and use content sizing
                          child: child!,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: ResponsiveUtils.getMediumSpace(context),
                          right: ResponsiveUtils.getMediumSpace(context),
                          top: ResponsiveUtils.getMediumSpace(context),
                          bottom: ResponsiveUtils.getSmallSpace(context),
                        ),
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveUtils.isDesktop(context) ? 450 : double.infinity,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, -2),
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
                                            checkColor: Colors.white, // Explicit white check mark
                                            // Add these properties for the outline
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
                                        minimumSize: Size(0, 0),
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

                                // Error message (if any)
                                if (_errorMessage.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ResponsiveUtils.getSmallSpace(context)),
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                          color: errorColor,
                                          fontSize: ResponsiveUtils.getSmallTextSize(context)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                // Sign In button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _signInWithEmailAndPassword,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity,
                                        ResponsiveUtils.getButtonHeight(context)),
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

                                // Replace with minimal padding at the bottom
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
        // Label above the field
        Padding(
          padding: EdgeInsets.only(
              left: 4,
              bottom: ResponsiveUtils.getSmallSpace(context) * 0.6
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
        // Text field with rounded styling
        Container(
          height: ResponsiveUtils.getInputHeight(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: Offset(0, 2),
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
              prefixIconConstraints: BoxConstraints(
                  minWidth: ResponsiveUtils.isSmallPhone(context) ? 35 : 45
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
              // Use fixed light theme styles
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: errorColor.withOpacity(0.5), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: errorColor, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: dividerColor.withOpacity(0.5), width: 1),
              ),
            ),
            cursorColor: primaryColor,
          ),
        ),
      ],
    );
  }
}