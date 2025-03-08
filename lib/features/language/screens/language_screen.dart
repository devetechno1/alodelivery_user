import 'package:flutter/services.dart';
import 'package:sixam_mart/features/language/screens/web_language_screen.dart';
import 'package:sixam_mart/features/language/widgets/language_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBar(title: 'language'.tr, backButton: true) : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<LocalizationController>(builder: (localizationController) {
        return ResponsiveHelper.isDesktop(context) ? const WebLanguageScreen() : SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: Image.asset(Images.languageBackground,fit: BoxFit.cover,height: MediaQuery.sizeOf(context).height * 0.35,)),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    sliver: SliverToBoxAdapter(child: Text('choose_your_language'.tr,textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge,color: Colors.grey))),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                
                  SliverList.builder(
                    itemCount: localizationController.languages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: LanguageCardWidget(
                          languageModel: localizationController.languages[index],
                          localizationController: localizationController,
                          index: index,
                        ),
                      );
                    },
                  ),          
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 0)],
                ),
                child: CustomButton(
                  buttonText: 'next'.tr,
                  onPressed: () {
                    if(localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                      localizationController.setLanguage(Locale(
                        AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                        AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                      ));
                      if (widget.fromMenu) {
                        Navigator.pop(context);
                      } else {
                        Get.offNamed(RouteHelper.getOnBoardingRoute());
                      }
                    }else {
                      showCustomSnackBar('select_a_language'.tr);
                    }
                  },
                ),
              )
            ],
          ),
        );
      }),

    );
  }
}
