import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  final String? categoryId;
  const MostPopularItemView({super.key, required this.isFood, required this.isShop, this.categoryId});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    if(categoryId != null) Get.find<ItemController>().getPopularItemListInCategory('all', categoryId!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? itemList = categoryId != null ? itemController.popularItemListInCategory: itemController.popularItemList;

          return (itemList != null) ? itemList.isNotEmpty ? Container(
            color: categoryId != null? null : Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(children: [

              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                child: TitleWidget(
                  title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                  image: Images.mostPopularIcon,
                  onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(true, false)),
                ),
              ),

              SizedBox(
                height: 285, width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                      child: ItemCard(
                        isPopularItem: isShop ? false : true,
                        isPopularItemCart: true,
                        index: index,
                        item: itemList[index],
                        isShop: isShop,
                        isFood: isFood,
                      ),
                    );
                  },
                ),
              ),

            ]),
          ) : const SizedBox() : const ItemShimmerView(isPopularItem: true);
        }
      ),
    );
  }
}
