import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iterable/common.dart';
import 'package:iterable/events/event_handler.dart';
import 'package:iterable/inapp/inapp_common.dart';
import 'iterable_platform_interface.dart';

/// An implementation of [IterablePlatform] that uses method channels.
class MethodChannelIterable extends IterablePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const methodChannel = MethodChannel('iterable');
  static const String pluginVersion = '0.0.1';
  static var events = IterableEventHandler(channel: methodChannel);
  static OpenedNotificationHandler? _onOpenedNotification;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  /// Initializes Iterable with an [apiKey] and an Iterable [config] object
  ///
  /// [Future<bool>] upon success or failure
  @override
  Future<bool> initialize(String apiKey, IterableConfig config) async {
    bool inAppHandlerPresent = config.inAppHandler != null;
    bool urlHandlerPresent = config.urlHandler != null;
    bool customActionHandlerPresent = config.customActionHandler != null;
    bool authHandlerPresent = config.authHandler != null;

    var initialized = await methodChannel.invokeMethod('initialize', {
      'config': {
        'pushIntegrationName': config.pushIntegrationName,
        'urlHandlerPresent': urlHandlerPresent,
        'customActionHandlerPresent': customActionHandlerPresent,
        'inAppHandlerPresent': inAppHandlerPresent,
        'authHandlerPresent': authHandlerPresent,
        'autoPushRegistration': config.autoPushRegistration,
        'inAppDisplayInterval': config.inAppDisplayInterval,
        'expiringAuthTokenRefreshPeriod': config.expiringAuthTokenRefreshPeriod,
        'logLevel': config.logLevel
      },
      'version': pluginVersion,
      'apiKey': apiKey
    });
    if (inAppHandlerPresent) {
      events.setEventHandler(
        EventListenerNames.inAppHandler,
        config.inAppHandler!,
      );
    }
    if (urlHandlerPresent) {
      events.setEventHandler(
        EventListenerNames.urlHandler,
        config.urlHandler!,
      );
    }
    if (customActionHandlerPresent) {
      events.setEventHandler(
        EventListenerNames.customActionHandler,
        config.customActionHandler!,
      );
    }
    if (authHandlerPresent) {
      events.setEventHandler(
        EventListenerNames.authHandler,
        config.authHandler!,
      );
    }
    methodChannel.setMethodCallHandler(nativeMethodCallHandler);
    return initialized;
  }

  /// Sets [email] on the user profile
  @override
  void setEmail(String? email) {
    methodChannel.invokeMethod('setEmail', {'email': email});
  }

  /// Retrieves the current email for the user
  ///
  /// [Future<String>] user email
  @override
  Future<String> getEmail() async {
    return await methodChannel.invokeMethod('getEmail');
  }

  /// Updates the user [email]
  ///
  /// [Future<String>] upon success or failure
  @override
  Future<String> updateEmail(String email) async {
    return await methodChannel.invokeMethod('updateEmail', {'email': email});
  }

  /// Sets user [id] on the user profile
  @override
  void setUserId(String? id) {
    methodChannel.invokeMethod('setUserId', {'userId': id});
  }

  /// Retrieves the current user id for the user
  ///
  /// [Future<String>] user id
  @override
  Future<String> getUserId() async {
    return await methodChannel.invokeMethod('getUserId');
  }

  /// Updates the user [dataFields]
  ///
  /// [Future<String>] upon success or failure
  @override
  Future<String> updateUser(
    Map<String, Object> dataFields,
    bool? mergeNestedObjects,
  ) async {
    return await methodChannel.invokeMethod('updateUser', {
      'dataFields': dataFields,
      'mergeNestedObjects': mergeNestedObjects,
    });
  }

  /// Sets the user [email] and [userId] at the same time
  ///
  /// [Future<String>] upon success or failure
  @override
  Future<String> setEmailAndUserId(String email, String userId) async {
    return await methodChannel.invokeMethod(
      'setEmailAndUserId',
      {'email': email, 'userId': userId},
    );
  }

  /// Retrieves the current attribution information (based on a recent deep link click)
  ///
  /// [Future<IterableAttributionInfo>]
  @override
  Future<IterableAttributionInfo?> getAttributionInfo() async {
    var attrInfo = await methodChannel.invokeMethod('getAttributionInfo');
    if (attrInfo != null) {
      return IterableAttributionInfo(attrInfo["campaignId"] as int,
          attrInfo["templateId"] as int, attrInfo["messageId"] as String);
    } else {
      return null;
    }
  }

  /// Manually sets the current attribution information so that it can later be used when tracking events
  @override
  void setAttributionInfo(IterableAttributionInfo attributionInfo) {
    methodChannel.invokeMethod(
      'setAttributionInfo',
      {'attributionInfo': attributionInfo.toJson()},
    );
  }

  /// Tracks a custom event with [name] and optional [dataFields]
  @override
  void trackEvent(
    String name,
    Map<String, Object>? dataFields,
  ) {
    methodChannel.invokeMethod('trackEvent', {
      'eventName': name,
      'dataFields': dataFields,
    });
  }

  /// Tracks updates to the cart [items]
  @override
  void updateCart(List<IterableCommerceItem> items) {
    var itemsList = items.map((item) => item.toJson()).toList();
    methodChannel.invokeMethod(
      'updateCart',
      {'items': itemsList},
    );
  }

  /// Tracks a purchase with order [total] cart [items] and optional [dataFields]
  @override
  void trackPurchase(
    double total,
    List<IterableCommerceItem> items,
    Map<String, Object>? dataFields,
  ) {
    var itemsList = items.map((item) => item.toJson()).toList();
    methodChannel.invokeMethod('trackPurchase', {
      'total': total,
      'items': itemsList,
      'dataFields': dataFields,
    });
  }

  /// Disables the device for a current user
  @override
  void disableDeviceForCurrentUser() {
    methodChannel.invokeMethod('disableDeviceForCurrentUser');
  }

  /// Tracks a push open event manually
  @override
  void trackPushOpenWithCampaignId(
    int campaignId,
    int templateId,
    String messageId,
    bool appAlreadyRunning,
    Map<String, Object>? dataFields,
  ) {
    methodChannel.invokeMethod('trackPushOpen', {
      'campaignId': campaignId,
      'templateId': templateId,
      'messageId': messageId,
      'appAlreadyRunning': appAlreadyRunning,
      'dataFields': dataFields
    });
  }

  /// Get the last push payload
  ///
  /// [Future<dynamic>] the most recent push payload
  @override
  Future<dynamic> getLastPushPayload() async {
    return await methodChannel.invokeMethod('getLastPushPayload');
  }

  /// Updates subscription preferences for the user
  /// from a list of [emailListIds] or [unsubscribedChannelIds]
  /// or [unsubscribedMessageTypeIds] or [subscribedMessageTypeIds]
  /// can also optionally include [campaignId] and/or [templateId]
  @override
  void updateSubscriptions({
    List<int>? emailListIds,
    List<int>? unsubscribedChannelIds,
    List<int>? unsubscribedMessageTypeIds,
    List<int>? subscribedMessageTypeIds,
    int? campaignId,
    int? templateId,
  }) {
    methodChannel.invokeMethod('updateSubscriptions', {
      'emailListIds': emailListIds,
      'unsubscribedChannelIds': unsubscribedChannelIds,
      'unsubscribedMessageTypeIds': unsubscribedMessageTypeIds,
      'subscribedMessageTypeIds': subscribedMessageTypeIds,
      'campaignId': campaignId,
      'templateId': templateId
    });
  }

  /// Tracks an in-app [message] open event manually
  @override
  void trackInAppOpen(
    IterableInAppMessage message,
    IterableInAppLocation location,
  ) {
    methodChannel.invokeMethod('trackInAppOpen', {
      'messageId': message.messageId,
      'location': location.toInt(),
    });
  }

  /// Tracks an in-app [message] click event manually
  @override
  void trackInAppClick(
    IterableInAppMessage message,
    IterableInAppLocation location,
    String clickedUrl,
  ) {
    methodChannel.invokeMethod('trackInAppClick', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Tracks an in-app [message] close event manually
  @override
  void trackInAppClose(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppCloseSource source,
    String? clickedUrl,
  ) {
    methodChannel.invokeMethod('trackInAppClose', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'source': source.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Consumes an in-app [message] from the queue
  @override
  void inAppConsume(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppDeleteSource source,
  ) {
    methodChannel.invokeMethod('inAppConsume', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'source': source.toInt(),
    });
  }

  @override
  Future<void> checkRecentNotification() async {
    await methodChannel.invokeMethod('checkRecentNotification');
  }

  @override
  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }

  @override
  Future<void> registerForPush() async {
    await methodChannel.invokeMethod('registerForPush');
  }


  @override
  Future<String> nativeMethodCallHandler(MethodCall methodCall) async {
    final arguments = methodCall.arguments as Map<dynamic, dynamic>;
    final argumentsCleaned = sanitizeArguments(arguments);

    switch (methodCall.method) {
      case "openedNotificationHandler":
        _onOpenedNotification?.call(argumentsCleaned);
        return "This data from native.....";
      default:
        return "Nothing";
    }
  }

  Map<String, dynamic> sanitizeArguments(Map<dynamic, dynamic> arguments) {
    final result = arguments;

    final data = result['additionalData'];
    data.forEach((key, value) {
      if (value is String) {
        if (value[0] == '{' && value[value.length - 1] == '}') {
          data[key] = _stringJsonToMap(value);
        }
      }
    });
    result['additionalData'] = data;

    return Map<String, dynamic>.from(result);
  }

  static Map<dynamic, dynamic> _stringJsonToMap(String stringJson) {
    final stringClean = stringJson.replaceAll('&quot;', '"');

    return jsonDecode(stringClean) as Map<dynamic, dynamic>;
  }
}
