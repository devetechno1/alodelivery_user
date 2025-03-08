import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/menu_drawer.dart';
import '../../../helper/route_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../controllers/auth_controller.dart';
import 'sign_up_screen.dart';
import '../widgets/sign_in/sign_in_view.dart';

class AuthBottomSheetScreen extends StatelessWidget {
  const AuthBottomSheetScreen({
    super.key,
    required this.child, 
    required this.onPressBackButton, 
    required this.showAppBar, 
  });

  final Widget child;
  final bool showAppBar;
  final void Function() onPressBackButton;

  @override
  Widget build(BuildContext context) {
  final bool isLoginPage = child is SignInView;
    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: (showAppBar ? AppBar(leading: Align(
          child: Container(
            padding: const EdgeInsetsDirectional.only(end: 3),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
                onPressed: onPressBackButton,
                icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
          ),
        ),
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          elevation: 0, 
          actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        extendBodyBehindAppBar: true,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.bottomCenter,
        decoration: context.width > 700 ? BoxDecoration(
          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          image: backgroundImage
        ) : BoxDecoration(image: backgroundImage),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.sizeOf(context).height * 0.4,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
            child: Column(
              children: [
                Row(
                  children: [
                    SignInUpButtonWidget(
                      name: 'sign_in'.tr, 
                      isActive: isLoginPage, 
                      onTap: (){
                        if(Get.currentRoute == RouteHelper.signUp) {
                          Get.back();
                        } else {
                          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                        }
                      },
                    ),
                    SignInUpButtonWidget(
                      name:'sign_up'.tr, 
                      isActive: !isLoginPage, 
                      onTap: ()=> Get.to(()=> const SignUpScreen(), transition: Transition.noTransition, routeName: RouteHelper.getSignUpRoute()),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault).copyWith(bottom: 50),
                  color: Theme.of(context).cardColor, 
                  child:child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  DecorationImage get backgroundImage => const DecorationImage(image: AssetImage(Images.authImage),fit: BoxFit.cover,alignment: Alignment.topCenter);
}

class SignInUpButtonWidget extends StatelessWidget {
  const SignInUpButtonWidget({
    super.key, 
    required this.isActive, 
    required this.name, 
    this.onTap,
  });
  final bool isActive;
  final String name;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: isActive || Get.find<AuthController>().isLoading? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          ),
          child: Text(name,style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isActive ? Colors.white : null)),
        ),
      ),
    );
  }
}
