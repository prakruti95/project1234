import 'package:flutter/material.dart';
import 'package:project1/user/onboardingscreen/widgets/header.dart';
import 'package:project1/user/onboardingscreen/widgets/next_page_button.dart';
import 'package:project1/user/onboardingscreen/widgets/onboarding_page_indicator.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/community/community_dark_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/community/community_light_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/community/community_text_column.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/onboarding_page.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/relationships/relationships_dark_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/relationships/relationships_light_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/relationships/relationships_text_column.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/work/work_dark_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/work/work_light_card_content.dart';
import 'package:project1/user/onboardingscreen/widgets/pages/work/work_text_column.dart';
import '../../constants.dart';
import '../loginscreen/login.dart';

class OnboardingScreen  extends StatefulWidget
{
  const OnboardingScreen ({super.key});

  @override
  State<OnboardingScreen > createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen >
{
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
      backgroundColor: kBrown,
      body: SafeArea
        (
        child: Column
          (
            children: <Widget>
            [
              Header(onSkip: _goToLogin),

              Expanded(child: _getpage()),

              OnboardingPageIndicator(
                currentPage: _currentPage,
                child: NextPageButton(onPressed: _nextPage),
              ),
            ]
        ),

      ),
    );
  }

  _goToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
     // Navigator.pushReplacement(
     //     context, MaterialPageRoute(builder: (context) => AdminLoginScreen()));


  }

  void _setNextPage(int nextPageNumber) {
    setState(() {
      _currentPage = nextPageNumber;
    });
  }


  void _nextPage() {
    switch (_currentPage)
    {
      case 1:
        _setNextPage(2);
        break;
      case 2:
        _setNextPage(3);
        break;
      case 3:
        _goToLogin();
        break;
    }
  }

  Widget _getpage() {
    switch (_currentPage) {
      case 1:
        return const OnboardingPage(
          number: 1,
          lightCardChild: CommunityLightCardContent(),
          darkCardChild: CommunityDarkCardContent(),
          textColumn: CommunityTextColumn(),
        );
      case 2:
        return const OnboardingPage(
          number: 2,
          lightCardChild: EducationLightCardContent(),
          darkCardChild: EducationDarkCardContent(),
          textColumn: EducationTextColumn(),
        );
      case 3:
        return const OnboardingPage(
          number: 3,
          lightCardChild: WorkLightCardContent(),
          darkCardChild: WorkDarkCardContent(),
          textColumn: WorkTextColumn(),
        );
      default:
        throw Exception("Page with number '$_currentPage' does not exist.");
    }
  }
}
