import 'package:flutter/foundation.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/models/category_model.dart';
import '../widgets/filter_cat_widget.dart';
import '../../brands/domain/models/brands_model.dart';
import '../../home/widgets/views/most_popular_item_view.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<BrandModel> brandsList = [];
  // ignore: non_constant_identifier_names
  int index_category = -1;
  // ignore: non_constant_identifier_names
  int index_brand = -1;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    getBrandByCategoryList(widget.categoryID);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    Get.find<CategoryController>().getCategoryStoreList(
      widget.categoryID,
      1,
      Get.find<CategoryController>().type,
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryItemList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
              Get.find<CategoryController>().subCategoryIndex == -1
                  ? widget.categoryID
                  : Get.find<CategoryController>()
                      .subCategoryList![
                          Get.find<CategoryController>().subCategoryIndex]
                      .id
                      .toString(),
              Get.find<CategoryController>().offset + 1,
              Get.find<CategoryController>().type,
              false,
              '${brandsList.isEmpty || index_brand == -1 ? "" : brandsList[index_brand].id}');
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels ==
              storeScrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryStoreList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize =
            (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == -1
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
  }

  getBrandByCategoryList(String? categoryID) async {
    final ApiClient api = Get.find<ApiClient>();
    final response =
        await api.getData("${AppConstants.brandCategoryUri}/$categoryID");
    if (response.statusCode == 200) {
      if (response.body['brands'] == 0) {
        brandsList = [];
      } else {
        setState(() {
          brandsList = [];
          response.body['brands']
              .forEach((brand) => brandsList.add(BrandModel.fromJson(brand)));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;
      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) => backMethod(catController),
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  backgroundColor: Theme.of(context).cardColor,
                  surfaceTintColor: Theme.of(context).cardColor,
                  shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
                  elevation: 2,
                  title: catController.isSearching
                      ? SizedBox(
                          height: 45,
                          child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'search_'.tr,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                prefixIcon: catController.isSearching
                                    ? IconButton(
                                        onPressed: () {
                                          List<double?> prices = [];
                                          if (!catController.isStore) {
                                            for (var product in catController
                                                .categoryItemList!) {
                                              prices.add(product.price);
                                            }
                                            prices.sort();
                                          }
                                          double? maxValue = prices.isNotEmpty
                                              ? prices[prices.length - 1]
                                              : 1000;
                                          Get.dialog(FilterCatWidget(
                                              maxValue: maxValue,
                                              isStore: catController.isStore));
                                        },
                                        icon: const Icon(Icons.filter_list),
                                      )
                                    : null,
                                suffixIcon: IconButton(
                                  onPressed: () => catController.toggleSearch(),
                                  icon: Icon(
                                    catController.isSearching
                                        ? Icons.close_sharp
                                        : Icons.search,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ),
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge),
                              onSubmitted: (String query) {
                                catController.searchData(
                                  query,
                                  catController.subCategoryIndex == -1
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  catController.type,
                                );
                              }),
                        )
                      : Text(widget.categoryName,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () => backMethod(catController),
                  ),
                  actions: [
                    !catController.isSearching
                        ? IconButton(
                            onPressed: () => catController.toggleSearch(),
                            icon: Icon(
                              catController.isSearching
                                  ? Icons.close_sharp
                                  : Icons.search,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          )
                        : const SizedBox(),
                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      icon: CartWidget(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 25),
                    ),
                    VegFilterWidget(
                        type: catController.type,
                        fromAppBar: true,
                        onSelected: (String type) {
                          if (catController.isSearching) {
                            catController.searchData(
                              catController.subCategoryIndex == -1
                                  ? widget.categoryID
                                  : catController
                                      .subCategoryList![
                                          catController.subCategoryIndex]
                                      .id
                                      .toString(),
                              '1',
                              type,
                            );
                          } else {
                            if (catController.isStore) {
                              catController.getCategoryStoreList(
                                catController.subCategoryIndex == -1
                                    ? widget.categoryID
                                    : catController
                                        .subCategoryList![
                                            catController.subCategoryIndex]
                                        .id
                                        .toString(),
                                1,
                                type,
                                true,
                              );
                            } else {
                              catController.getCategoryItemList(
                                  catController.subCategoryIndex == -1
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  1,
                                  type,
                                  true,
                                  "");
                            }
                          }
                        }),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                )),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: ResponsiveHelper.isDesktop(context)
              ? SingleChildScrollView(
                  child: FooterView(
                    child: Center(
                        child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(children: [
                        (catController.subCategoryList != null &&
                                !catController.isSearching)
                            ? Center(
                                child: Container(
                                height: 40,
                                width: Dimensions.webMaxWidth,
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: ListView.builder(
                                  key: scaffoldKey,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      catController.subCategoryList!.length,
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () =>
                                          catController.setSubCategoryIndex(
                                              index, widget.categoryID, ""),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: index ==
                                                  catController.subCategoryIndex
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                catController
                                                    .subCategoryList![index]
                                                    .name!,
                                                style: index ==
                                                        catController
                                                            .subCategoryIndex
                                                    ? robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .primaryColor)
                                                    : robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                ),
                              ))
                            : const SizedBox(),
                        if (!AppConstants.removeStores)
                          Center(
                              child: Container(
                            width: Dimensions.webMaxWidth,
                            color: Theme.of(context).cardColor,
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: Theme.of(context).primaryColor,
                              indicatorWeight: 3,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor:
                                  Theme.of(context).disabledColor,
                              unselectedLabelStyle: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall),
                              labelStyle: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor),
                              tabs: [
                                Tab(text: 'item'.tr),
                                Tab(
                                    text: Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .showRestaurantText!
                                        ? 'restaurants'.tr
                                        : 'stores'.tr),
                              ],
                            ),
                          )),
                        SizedBox(
                          height: 600,
                          child: NotificationListener(
                            onNotification: (dynamic scrollNotification) {
                              if (scrollNotification is ScrollEndNotification) {
                                if ((_tabController!.index == 1 &&
                                        !catController.isStore) ||
                                    _tabController!.index == 0 &&
                                        catController.isStore) {
                                  catController.setRestaurant(
                                      _tabController!.index == 1);
                                  if (catController.isSearching) {
                                    catController.searchData(
                                      catController.searchText,
                                      catController.subCategoryIndex == -1
                                          ? widget.categoryID
                                          : catController
                                              .subCategoryList![catController
                                                  .subCategoryIndex]
                                              .id
                                              .toString(),
                                      catController.type,
                                    );
                                  } else {
                                    if (_tabController!.index == 1) {
                                      catController.getCategoryStoreList(
                                        catController.subCategoryIndex == -1
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        1,
                                        catController.type,
                                        false,
                                      );
                                    } else {
                                      catController.getCategoryItemList(
                                          catController.subCategoryIndex == -1
                                              ? widget.categoryID
                                              : catController
                                                  .subCategoryList![
                                                      catController
                                                          .subCategoryIndex]
                                                  .id
                                                  .toString(),
                                          1,
                                          catController.type,
                                          false,
                                          '${index_brand == -1 ? "" : brandsList[index_brand].id}');
                                    }
                                  }
                                }
                              }
                              return false;
                            },
                            child: AppConstants.removeStores
                                ? SingleChildScrollView(
                                    controller: scrollController,
                                    child: ItemsView(
                                      isStore: false,
                                      items: catController.isLoading? null: item,
                                      stores: null,
                                      noDataText: 'no_category_item_found'.tr,
                                    ),
                                  )
                                : TabBarView(
                                    controller: _tabController,
                                    children: [
                                      SingleChildScrollView(
                                        controller: scrollController,
                                        child: ItemsView(
                                          isStore: false,
                                          items: catController.isLoading? null: item,
                                          stores: null,
                                          noDataText:
                                              'no_category_item_found'.tr,
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        controller: storeScrollController,
                                        child: ItemsView(
                                          isStore: true,
                                          items: null,
                                          stores: stores,
                                          noDataText: Get.find<
                                                      SplashController>()
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .showRestaurantText!
                                              ? 'no_category_restaurant_found'
                                                  .tr
                                              : 'no_category_store_found'.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        catController.isLoading && catController.offset > 1
                            ? Center(
                                child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor)),
                              ))
                            : const SizedBox(),
                      ]),
                    )),
                  ),
                )
              : SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Visibility(
                      visible: (!AppConstants.makeSubCatInGrid &&
                          catController.subCategoryList != null &&
                          catController.subCategoryList!.length > 1 &&
                          !catController.isSearching &&
                          AppConstants.makeSubCatImgAndBrands &&
                          pageIndex == 0),
                      maintainState: true,
                      child: Center(
                          child: Container(
                              height: 120,
                              margin: const EdgeInsets.only(bottom: 10),
                              width: Dimensions.webMaxWidth,
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  const SizedBox(width: 15),
                                  Align(
                                    child: InkWell(
                                      onTap: index_category == -1
                                          ? null
                                          : () {
                                              index_category = -1;
                                              catController.setSubCategoryIndex(
                                                  index_category,
                                                  widget.categoryID,
                                                  "");
                                            },
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(
                                              index_category == -1
                                                  ? Dimensions
                                                      .paddingSizeExtraSmall
                                                  : Dimensions
                                                      .paddingSizeSmall),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: index_category == -1
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : context.textTheme
                                                          .bodyLarge!.color!),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(50))),
                                          width: 80,
                                          height: 80,
                                          child: Text(
                                            "all".tr,
                                            textAlign: TextAlign.center,
                                            style: index_category == -1
                                                ? TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 12)
                                                : const TextStyle(fontSize: 10),
                                          )),
                                    ),
                                  ),
                                  ...List.generate(
                                    catController.subCategoryList?.length ?? 0,
                                    (int index) {
                                      return InkWell(
                                          onTap: () {
                                            setState(() {
                                              index_category = index;
                                              index_brand = -1;
                                              pageIndex = 1;
                                            });
                                            String? subcat = catController
                                                .GetsetSubCategoryIndex(index);

                                            catController.setSubCategoryIndex(
                                                index, widget.categoryID, "");
                                            getBrandByCategoryList(subcat);
                                          },
                                          child: Container(
                                            // width: 150,
                                            //height: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.paddingSizeSmall,
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            margin: const EdgeInsets.only(
                                                left: Dimensions
                                                    .paddingSizeSmall),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              color: index ==
                                                      catController
                                                          .subCategoryIndex
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.1)
                                                  : Colors.transparent,
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // image
                                                  catController
                                                              .subCategoryList![
                                                                  index]
                                                              .name !=
                                                          "all".tr
                                                      ? Expanded(
                                                          flex: 3,
                                                          child: CustomImage(
                                                            image:
                                                                '${catController.subCategoryList![index].imageFullUrl}',
                                                            placeHolderSize: 50,
                                                            //height: 90,
                                                            //width: 75,
                                                          ),
                                                        )
                                                      : Container(

                                                          //child: Image.asset('assets/image/all_products.png'),
                                                          ),

                                                  catController
                                                              .subCategoryList![
                                                                  index]
                                                              .name !=
                                                          "all".tr
                                                      ? Flexible(
                                                          flex: 1,
                                                          child: Text(
                                                            catController
                                                                .subCategoryList![
                                                                    index]
                                                                .name!,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: index ==
                                                                    catController
                                                                        .subCategoryIndex
                                                                ? robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .paddingSizeSmall,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor)
                                                                : robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ]),
                                          ));
                                    },
                                  ),
                                ],
                              ))),
                    ),
                    if(brandsList.isNotEmpty &&
                            (pageIndex == 1 ||
                                (catController.subCategoryList?? []).length <= 1) && catController.categoryItemList?.isNotEmpty == true)
                         Center(
                            child: Container(
                            height: 100,
                            width: Dimensions.webMaxWidth,
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: ListView(
                              key: scaffoldKey,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                const SizedBox(width: 15),
                                Align(
                                  child: InkWell(
                                    onTap: index_brand == -1
                                        ? null
                                        : () {
                                            catController.setSubCategoryIndex(
                                                index_category,
                                                widget.categoryID,
                                                "");
                                            index_brand = -1;
                                          },
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(index_brand ==
                                                -1
                                            ? Dimensions.paddingSizeExtraSmall
                                            : Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: index_brand == -1
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : context.textTheme
                                                        .bodyLarge!.color!),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50))),
                                        width: 80,
                                        height: 80,
                                        child: Text(
                                          "allCompanies".tr,
                                          textAlign: TextAlign.center,
                                          style: index_brand == -1
                                              ? TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 12)
                                              : const TextStyle(fontSize: 10),
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ...List.generate(
                                  brandsList.length,
                                  (index) {
                                    return InkWell(
                                      onTap: index_brand == index
                                          ? null
                                          : () {
                                              catController.setSubCategoryIndex(
                                                  index_category,
                                                  widget.categoryID,
                                                  '${brandsList[index].id}');
                                              index_brand = index;
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: index == index_brand
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault),
                                                child: CustomImage(
                                                  image:
                                                      '${brandsList[index].imageFullUrl}',
                                                  placeHolderSize: 60,
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  '${brandsList[index].name}',
                                                  style: index == index_brand
                                                      ? robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(context)
                                                              .primaryColor)
                                                      : robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )),
                          
                    (catController.subCategoryList != null &&
                            !catController.isSearching &&
                            AppConstants.makeSubCatImgAndBrands == false &&
                            catController.subCategoryList!.length > 1)
                        ? Center(
                            child: Container(
                            height: 40,
                            width: Dimensions.webMaxWidth,
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: ListView.builder(
                              key: scaffoldKey,
                              scrollDirection: Axis.horizontal,
                              itemCount: catController.subCategoryList!.length,
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeSmall),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () =>
                                      catController.setSubCategoryIndex(
                                          index, widget.categoryID, ""),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall),
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                      color: index ==
                                              catController.subCategoryIndex
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            catController
                                                .subCategoryList![index].name!,
                                            style: index ==
                                                    catController
                                                        .subCategoryIndex
                                                ? robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .primaryColor)
                                                : robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                          ),
                                        ]),
                                  ),
                                );
                              },
                            ),
                          ))
                        : const SizedBox(),
                    if (!AppConstants.removeStores &&
                        (!AppConstants.makeSubCatInGrid || pageIndex != 0))
                      Center(
                          child: Container(
                        width: Dimensions.webMaxWidth,
                        color: Theme.of(context).cardColor,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).disabledColor,
                          unselectedLabelStyle: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall),
                          labelStyle: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor),
                          tabs: [
                            Tab(text: 'item'.tr),
                            Tab(
                                text: Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'restaurants'.tr
                                    : 'stores'.tr),
                          ],
                        ),
                      )),
                    Expanded(
                        child: NotificationListener(
                      onNotification: (dynamic scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          if ((_tabController!.index == 1 &&
                                  !catController.isStore) ||
                              _tabController!.index == 0 &&
                                  catController.isStore) {
                            catController
                                .setRestaurant(_tabController!.index == 1);
                            if (catController.isSearching) {
                              catController.searchData(
                                catController.searchText,
                                catController.subCategoryIndex == -1
                                    ? widget.categoryID
                                    : catController
                                        .subCategoryList![
                                            catController.subCategoryIndex]
                                        .id
                                        .toString(),
                                catController.type,
                              );
                            } else {
                              if (_tabController!.index == 1) {
                                catController.getCategoryStoreList(
                                  catController.subCategoryIndex == -1
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  1,
                                  catController.type,
                                  false,
                                );
                              } else {
                                catController.getCategoryItemList(
                                    catController.subCategoryIndex == -1
                                        ? widget.categoryID
                                        : catController
                                            .subCategoryList![
                                                catController.subCategoryIndex]
                                            .id
                                            .toString(),
                                    1,
                                    catController.type,
                                    false,
                                    '${index_brand == -1 ? "" : brandsList[index_brand].id}');
                              }
                            }
                          }
                        }
                        return false;
                      },
                      child: AppConstants.removeStores ||
                              (AppConstants.makeSubCatInGrid && pageIndex == 0)
                          ? SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  _subCategoryGridView(catController),
                                  if (_showPopularItems(catController))
                                    MostPopularItemView(
                                        isFood: false,
                                        isShop: true,
                                        categoryId: catId(catController)),
                                  if (((AppConstants.makeSubCatInGrid &&
                                          pageIndex != 0 )|| AppConstants.showItemUnderGridSubCat || (catController.categoryItemList?.isNotEmpty == true && catController.subCategoryList?.isNotEmpty != true) ) ||
                                      !AppConstants.makeSubCatInGrid)
                                    ItemsView(
                                      isStore: false,
                                      items: catController.isLoading? null: item,
                                      stores: null,
                                      noDataText: 'no_category_item_found'.tr,
                                    ),
                                ],
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      if (_showPopularItems(catController))
                                        MostPopularItemView(
                                            isFood: false,
                                            isShop: true,
                                            categoryId: catId(catController)),
                                      ItemsView(
                                        isStore: false,
                                        items: catController.isLoading? null: item,
                                        stores: null,
                                        noDataText: Get.find<SplashController>()
                                                .configModel!
                                                .moduleConfig!
                                                .module!
                                                .showRestaurantText!
                                            ? 'no_category_restaurant_found'.tr
                                            : 'no_category_store_found'.tr,
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  controller: storeScrollController,
                                  child: ItemsView(
                                    isStore: true,
                                    items: null,
                                    stores: stores,
                                    noDataText: Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .showRestaurantText!
                                        ? 'no_category_restaurant_found'.tr
                                        : 'no_category_store_found'.tr,
                                  ),
                                ),
                              ],
                            ),
                    )),
                    catController.isLoading &&
                            (!AppConstants.makeSubCatInGrid || pageIndex != 0)  && catController.offset > 1
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)),
                          ))
                        : const SizedBox(),
                  ]),
                ),
        ),
      );
    });
  }

  Widget _subCategoryGridView(CategoryController catController) {
    List<CategoryModel> sub = List.from(catController.subCategoryList ?? []);
    sub.removeWhere((e) => e.name == "all".tr);
    if ((AppConstants.makeSubCatInGrid &&
        sub.isNotEmpty &&
        !catController.isSearching &&
        AppConstants.makeSubCatImgAndBrands &&
        pageIndex == 0)) {
      return Builder(builder: (context) {
        return SizedBox(
            width: Dimensions.webMaxWidth,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.paddingSizeLarge
                    : Dimensions.paddingSizeDefault,
                childAspectRatio:
                    ResponsiveHelper.isDesktop(context) ? 1.1 : 0.65,
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 3 : ResponsiveHelper.isTab(context)? 5 : 8,
              ),
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: Dimensions.paddingSizeSmall),
              // scrollDirection: Axis.horizontal,
              itemCount: sub.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                if(sub[index].name == "all".tr) return const SizedBox();
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        index_category = index;
                        index_brand = -1;
                        pageIndex = 1;
                      });
                      String? subcat =
                          catController.GetsetSubCategoryIndex(index);
                      catController.setSubCategoryIndex(
                          index, widget.categoryID, "");
                      getBrandByCategoryList(subcat);
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: Text(
                                sub[index].name!,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.paddingSizeDefault),
                              ),
                            ),
                            Flexible(
                              child: CustomImage(
                                image: '${sub[index].imageFullUrl}',
                              ),
                            ),
                          ]),
                    ));
              },
            ));
      });
    } else if (((catController.subCategoryList == null ||
            catController.subCategoryList?.isEmpty == true) &&
        (!catController.isSearching &&
            pageIndex == 0 && catController.categoryItemList?.isNotEmpty != true &&
            AppConstants.makeSubCatInGrid && !AppConstants.showPopularItemsInCategories)) && !AppConstants.showItemUnderGridSubCat) {
      return NoDataScreen(text: 'no_category_available'.tr);
    }
    return const SizedBox();
  }

  String? catId(CategoryController catController) =>
      catController.subCategoryIndex == -1 ||
              !AppConstants.showPopularItemsInSubCategories
          ? widget.categoryID
          : catController.subCategoryList![catController.subCategoryIndex].id
              .toString();
  bool _showPopularItems(CategoryController catController) =>
      ((AppConstants.showPopularItemsInCategories &&
              catController.subCategoryIndex == -1 &&
              pageIndex == 0) ||
          (AppConstants.showPopularItemsInSubCategories &&
              index_brand == -1 &&
              catController.subCategoryIndex != -1)) &&
      !catController.isSearching;
  void backMethod(CategoryController catController) {
    if (catController.isSearching) {
      catController.toggleSearch();
    } else if (pageIndex == 1) {
      catController.setSubCategoryIndex(index_category, widget.categoryID, "");
      if(AppConstants.showItemUnderGridSubCat && AppConstants.makeSubCatInGrid){
        catController.setSubCategoryIndex(-1, widget.categoryID, "");
      }
      setState(() {
        pageIndex = 0;
        brandsList = [];
      });
    } else {
      Get.back();
    }
  }
}
