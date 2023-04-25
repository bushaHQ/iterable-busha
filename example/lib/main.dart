import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:iterable/common.dart';
import 'package:iterable/inapp/inapp_common.dart';
import 'package:iterable/iterable.dart';
import 'package:iterable_example/deeplink_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'env.dart';
import 'iterable_button.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final config = IterableConfig(
    inAppDisplayInterval: 1.0,
    logLevel: IterableLogLevel.info,
  );
  late TabController _tabController;
  bool inAppMsgAutoDisplayPaused = false;
  String autoDisplayButtonText = "Pause";

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);

    config.inAppHandler = inAppHandler;
    config.urlHandler = urlHandler;
    config.customActionHandler = customActionHandler;
    config.authHandler = authHandler;

    // Initialize Iterable
    Iterable.initialize(IterableEnv.apiKey, config).then((success) => {
          if (success)
            {
              debugPrint('Iterable Initialized'),
              Iterable.inAppManager.setAutoDisplayPaused(false)
            }
        });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Set up custom handling for in-app messages
  IterableInAppShowResponse inAppHandler(IterableInAppMessage message) {
    if (message.customPayload?["shouldSkip"] == true) {
      return IterableInAppShowResponse.skip;
    } else {
      return IterableInAppShowResponse.show;
    }
  }

  // Set up custom action handling for the action:// url scheme
  bool customActionHandler(
      IterableAction action, IterableActionContext actionContext) {
    if (action.type.contains("discount?promo=")) {
      String promoCode = action.type.split("?promo=")[1];
      _showAlert(promoCode);
      return true;
    }
    return false;
  }

  // Set up custom routing for deeplinks
  bool urlHandler(String url, IterableActionContext context) {
    int tabIndex = DeeplinkHandler.handle(url).toInt();
    _tabController.animateTo(tabIndex);
    return true;
  }

  // Set up an auth handler that will pass along a JWT token retrieved from your service
  // Not needed if JWT is not enabled for your api key
  Future<String> authHandler() async {
    // This is simulating async retrieval of a JWT token from your server.
    // An actual implementation would take an email or userId and
    // return the token. For even more security, require a username/password
    // for your JWT retrieval endpoint.
    //
    // For testing, simply replace IterableEnv.jwtToken
    // with an actual JWT Token that was created manually
    // and make sure to use the JWT api key in Iterable.initialize
    return await Future.delayed(
      const Duration(milliseconds: 100),
      () => IterableEnv.jwtToken,
    ).catchError((err) {
      debugPrint("Error retrieving JWT from server: $err");
    });
  }

  /// Call it to register device for current user if calling setEmail or
  /// setUserId after the app has already launched
  /// (for example, when a new user logs in)
  Future<void> registerForPush() async {
    await Iterable.registerForPush();
  }

  ListView _identityListView() {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        const Padding(padding: EdgeInsets.all(3.5)),
        IterableButton(
          title: 'Set Email',
          onPressed: () {
            Iterable.setEmail(IterableEnv.email);
            registerForPush();
          },
        ),
        IterableButton(
            title: 'Set User Id',
            onPressed: () => Iterable.setUserId("flutterUserId")),
        IterableButton(
            title: 'Get Email',
            onPressed: () => Iterable.getEmail()
                .then((email) => debugPrint('Current Email: $email'))),
        IterableButton(
            title: 'Get User Id',
            onPressed: () => Iterable.getUserId()
                .then((userId) => debugPrint('Current User Id: $userId'))),
        IterableButton(
            title: 'Update Email',
            onPressed: () => Iterable.updateEmail(IterableEnv.email)
                .then((response) => debugPrint(jsonEncode(response)))),
        IterableButton(
            title: 'Update User Data',
            onPressed: () =>
                Iterable.updateUser({'newFlutterKey': 'def123'}, false)
                    .then((response) => debugPrint(jsonEncode(response)))),
        IterableButton(
            title: 'Update User Subscriptions',
            onPressed: () => Iterable.updateSubscriptions(
                emailListIds: [1234],
                campaignId: 5233049,
                subscribedMessageTypeIds: [12345],
                unsubscribedChannelIds: [67890],
                unsubscribedMessageTypeIds: [78901])),
        IterableButton(
            title: 'Set Email and User Id',
            onPressed: () => {
                  Iterable.setEmailAndUserId(
                          IterableEnv.email, "flutterUserId10")
                      .then((response) => debugPrint(jsonEncode(response)))
                }),
        IterableButton(
            title: 'Logout User',
            onPressed: () => {
                  Iterable.setEmail(null),
                  Iterable.setUserId(null),
                }),
      ],
    );
  }

  ListView _commerceListView() {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      const Padding(padding: EdgeInsets.all(3.5)),
      IterableButton(
          title: 'Add To Cart',
          onPressed: () => Iterable.updateCart(_addToCartItems())),
      IterableButton(
          title: 'Remove From Cart',
          onPressed: () => Iterable.updateCart(_removeFromCartItems())),
      IterableButton(
          title: 'Update Quantity',
          onPressed: () => Iterable.updateCart(_updateQtyItems())),
      IterableButton(
          title: 'Track Purchase',
          onPressed: () => Iterable.trackPurchase(
              19.98, _purchaseItems(), {'rewards': 100})),
      IterableButton(
          title: 'Get Attribution Info',
          onPressed: () => Iterable.getAttributionInfo()
              .then((attrInfo) => debugPrint(jsonEncode(attrInfo?.toJson())))),
      IterableButton(
          title: 'Set Attribution Info',
          onPressed: () => Iterable.setAttributionInfo(IterableAttributionInfo(
              5233049, 456, "0fc6657517c64014868ea2d15f23082b")))
    ]);
  }

  ListView _settingsListView() {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      const Padding(padding: EdgeInsets.all(3.5)),
      IterableButton(
          title: 'Track Event',
          onPressed: () => Iterable.trackEvent(
              'Test Event From Flutter', {'eventDataField': 'abc123'})),
      IterableButton(
          title: 'Get Last Push Payload',
          onPressed: () => {
                Iterable.getLastPushPayload().then(
                    (payload) => debugPrint('Last Push Payload: $payload'))
              }),
      IterableButton(
          title: 'Get In App Messages',
          onPressed: () => {
                Iterable.inAppManager
                    .getMessages()
                    .then((messages) => _logInAppMessages(messages))
              }),
      IterableButton(
          title: 'Show In App Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Show Message")}
                      else
                        {
                          Iterable.inAppManager
                              .showMessage(messages.first, true)
                        }
                    })
              }),
      IterableButton(
          title: 'Remove In App Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Remove Message")}
                      else
                        {
                          Iterable.inAppManager.removeMessage(
                              messages.first,
                              IterableInAppLocation.inApp,
                              IterableInAppDeleteSource.deleteButton)
                        }
                    })
              }),
      IterableButton(
          title: 'Set Read For Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Set Read For Message")}
                      else
                        {
                          Iterable.inAppManager
                              .setReadForMessage(messages.first, true)
                        }
                    })
              }),
      IterableButton(
          title: 'Get HTML Content For Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Get HTML Content For Message")}
                      else
                        {
                          Iterable.inAppManager
                              .getHtmlContentForMessage(messages.first)
                              .then((content) =>
                                  debugPrint(jsonEncode((content.toJson()))))
                        }
                    })
              }),
      IterableButton(
          title: "$autoDisplayButtonText Auto Display of InApps",
          onPressed: () => {
                inAppMsgAutoDisplayPaused = !inAppMsgAutoDisplayPaused,
                setState(() {
                  inAppMsgAutoDisplayPaused == true
                      ? autoDisplayButtonText = 'Unpause'
                      : autoDisplayButtonText = 'Pause';
                }),
                Iterable.inAppManager
                    .setAutoDisplayPaused(inAppMsgAutoDisplayPaused)
              }),
      IterableButton(
          title: 'Track Push Open',
          onPressed: () => Iterable.trackPushOpenWithCampaignId(
              5233049, 456, "abc123", false, {'hello': 'world'})),
      IterableButton(
          title: 'Track InApp Open',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Track InApp Open")}
                      else
                        {
                          Iterable.trackInAppOpen(
                              messages.first, IterableInAppLocation.inApp)
                        }
                    })
              }),
      IterableButton(
          title: 'Track InApp Click',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Track InApp Click")}
                      else
                        {
                          Iterable.trackInAppClick(
                              messages.first,
                              IterableInAppLocation.inApp,
                              "https://schellyapps.com/deeplinkurl")
                        }
                    })
              }),
      IterableButton(
          title: 'Track InApp Close',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Track InApp Close")}
                      else
                        {
                          Iterable.trackInAppClose(
                              messages.first,
                              IterableInAppLocation.inApp,
                              IterableInAppCloseSource.link,
                              "https:/schellyapps.com/deeplink-close")
                        }
                    })
              }),
      IterableButton(
          title: 'InApp Consume',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("InApp Consume")}
                      else
                        {
                          Iterable.inAppConsume(
                              messages.first,
                              IterableInAppLocation.inbox,
                              IterableInAppDeleteSource.inboxSwipe)
                        }
                    })
              })
    ]);
  }

  // Helper Methods
  List<IterableCommerceItem> _addToCartItems() {
    debugPrint("adding to cart");
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"}),
      IterableCommerceItem("def456", "ABC", 19.99, 2,
          sku: "defsku456",
          categories: ["category3", "category4"],
          dataFields: {"someItemKey2": "someItemValue2"})
    ];
  }

  List<IterableCommerceItem> _removeFromCartItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"})
    ];
  }

  List<IterableCommerceItem> _updateQtyItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"}),
    ];
  }

  List<IterableCommerceItem> _purchaseItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"})
    ];
  }

  void _logInAppError(String message) {
    debugPrint("$message Failed. There are no in-app messages in the queue.");
  }

  void _logInAppMessages(List<IterableInAppMessage> messages) {
    debugPrint('========= In-App Messages =========');
    messages.asMap().forEach(
        (index, message) => {developer.log(jsonEncode((message.toJson())))});
  }

  void _showAlert(String promoCode) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: const TextStyle(fontWeight: FontWeight.bold),
      descTextAlign: TextAlign.start,
      animationDuration: const Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: Colors.red,
      ),
      alertAlignment: Alignment.center,
    );

    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Discount Activated!",
      desc: "Apply promo code $promoCode at checkout.",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
          child: const Text(
            "COOL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.format_list_bulleted)),
              ],
            ),
            title: const Text('Iterable Flutter Example'),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _identityListView(),
              _commerceListView(),
              _settingsListView(),
            ],
          ),
        ),
      ),
    );
  }
}
