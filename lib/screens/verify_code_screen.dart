import 'package:admindash/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String resetToken;
  final String email;

  const VerifyCodeScreen({
    Key? key,
    required this.resetToken,
    required this.email,
  }) : super(key: key);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Code'),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verify Code',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit verification code sent to ${widget.email}',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_clock),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the verification code';
                        }
                        if (value!.length != 6) {
                          return 'Code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerifyCode,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Verify Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final verifiedToken = await ApiService().verifyResetCode(
          widget.resetToken,
          _codeController.text.trim(),
        );

        // Navigate to reset password screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              verifiedToken: verifiedToken,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Invalid or expired code. Please try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}