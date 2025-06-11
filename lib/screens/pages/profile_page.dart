import 'package:flutter/material.dart';
import 'package:lab_monitor/widgets/info_card.dart';
import 'package:lab_monitor/screens/login/dummy_signin_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLogoutPressed = false; // Track the pressed state of the logout button
  String _email = ''; // Variable to store the email ID
  String _name = '';
  String _adminId = '';
  String _phoneNumber = '';
  String _profileImage = 'assets/images/pfp.png';

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadEmail(); // Load the email when the page initializes
  }

  Future<void> _loadEmail() async {
    final email = await _secureStorage.read(key: 'email'); // Read the email from secure storage
    setState(() {
      _email = email ?? 'No email found'; // Set the email or a fallback message
      _updateProfileInfo(_email);
    });
  }

  void _updateProfileInfo(String email) {
    switch (email.toLowerCase()) {
      case 'ericrikku@gmail.com':
        _name = 'Eric Jose';
        _adminId = 'CSD-234';
        _phoneNumber = '+91 98765 43210';
        _profileImage = 'assets/images/eric.png';
        break;
      case 'jeejofarhan@gmail.com':
        _name = 'Farhan M Jeejo';
        _adminId = 'CSD-235';
        _phoneNumber = '+91 98765 43211';
        _profileImage = 'assets/images/farhan.jpg';
        break;
      case 'ashwinantonynelson@gmail.com':
        _name = 'Ashwin Antony Nelson';
        _adminId = 'CSD-236';
        _phoneNumber = '+91 98765 43212';
        _profileImage = 'assets/images/ashwin.jpg';
        break;
        case 'rittodavid@gmail.com':
        _name = 'David Ritto Robin';
        _adminId = 'CSD-237';
        _phoneNumber = '+91 98765 43252';
        _profileImage = 'assets/images/david.jpg';
        break;
      default:
        _name = 'Admin';
        _adminId = '-';
        _phoneNumber = '-';
        _profileImage = 'assets/images/pfp.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: false,
                floating: true,
                snap: false,
                leading: Container(),
                title: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05, // Dynamic font size
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile photo section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.35, // Dynamic width
                              height: screenWidth * 0.35, // Dynamic height
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 4,
                                  color: Colors.white,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(_profileImage),
                                radius: screenWidth * 0.17, // Dynamic radius
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03), // Dynamic spacing

                      // Name
                      Text(
                        _name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Dynamic font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01), // Dynamic spacing

                      // Department
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ), // Dynamic padding
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Computer Science',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035, // Dynamic font size
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04), // Dynamic spacing

                      // Information cards
                      InfoCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: _email, // Display the email retrieved from secure storage
                        onTap: () {
                          // Handle email tap
                        },
                      ),
                      InfoCard(
                        icon: Icons.badge_outlined,
                        title: 'Admin ID',
                        value: _adminId,
                        onTap: () {
                          // Handle admin ID tap
                        },
                      ),
                      InfoCard(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: _phoneNumber,
                        onTap: () {
                          // Handle phone tap
                        },
                      ),
                      InfoCard(
                        icon: Icons.work_outline,
                        title: 'Department',
                        value: 'Computer Science Department',
                        onTap: () {
                          // Handle department tap
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isLogoutPressed = true; // Change the button state to pressed
                            });

                            // Simulate a delay before navigating to the SignInPage
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => DummySignInPage()),
                                (route) => false,
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _isLogoutPressed ? Colors.grey : Colors.red),
                            backgroundColor: _isLogoutPressed ? Colors.red.withOpacity(0.1) : Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // Dynamic padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045, // Dynamic font size
                              fontWeight: FontWeight.bold,
                              color: _isLogoutPressed ? Colors.grey : Colors.red,
                            ),
                          ),
                        ),
                      ),

                      // Add bottom padding for better spacing
                      SizedBox(height: screenHeight * 0.03), // Dynamic spacing
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fixed back button that stays in position
          Positioned(
            top: screenHeight * 0.02, // Dynamic position
            left: screenWidth * 0.03, // Dynamic position
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.02), // Dynamic padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: screenWidth * 0.06, // Dynamic icon size
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}