import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../view_model/auth/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        final vm = Provider.of<LoginViewModel>(context);
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: 1.sw,
              height: 1.sh,
              decoration: const BoxDecoration(color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 122.11.w,
                    height: 68.69.h,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/stalwrites-logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Enter your email and password',
                    style: TextStyle(
                      color: Colors.black.withAlpha(128),
                      fontSize: 14.sp,
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Login Form
                  SizedBox(
                    width: 330.w,
                    child: Column(
                      children: [
                        // Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.black.withAlpha(128),
                              fontSize: 14.sp,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 42.h,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            onChanged: vm.updateEmail,
                            decoration: const InputDecoration(
                              hintText: 'Enter email....',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.black.withAlpha(128),
                              fontSize: 14.sp,
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 42.h,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            onChanged: vm.updatePassword,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Enter password...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Login Button
                        GestureDetector(
                          onTap: () async {
                            final success = await vm.login();
                            if (success) {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            } else if (vm.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.errorMessage!)),
                              );
                            }
                          },
                          child: const SignInButton(),
                        ),
                        SizedBox(height: 20.h),

                        // Footer text
                        const Text(
                          'To create an account please contact the database manager.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 37.h,
      padding: EdgeInsets.all(10.h),
      decoration: const ShapeDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, strokeAlign: BorderSide.strokeAlignOutside),
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
      ),
      child: const Center(
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
