import 'package:iterable/common.dart';
import 'package:iterable/inapp/inapp_common.dart';

import 'iterable_platform_interface.dart';

class Iterable {
  static var inAppManager = IterablePlatform.inAppManager;

  Future<String?> getPlatformVersion() {
    return IterablePlatform.instance.getPlatformVersion();
  }

  static Future<bool> initialize(String apiKey, IterableConfig config) {
    return IterablePlatform.instance.initialize(apiKey, config);
  }

  static setEmail(String? email) {
    return IterablePlatform.instance.setEmail(email);
  }

  static Future<String> getEmail() async {
    return await IterablePlatform.instance.getEmail();
  }

  static Future<String> updateEmail(String email) async {
    return await IterablePlatform.instance.updateEmail(email);
  }

  static setUserId(String? id) {
    IterablePlatform.instance.setUserId(id);
  }

  static Future<String> getUserId() async {
    return await IterablePlatform.instance.getUserId();
  }

  static Future<String> updateUser(
    Map<String, Object> dataFields,
    bool? mergeNestedObjects,
  ) async {
    return await IterablePlatform.instance.updateUser(
      dataFields,
      mergeNestedObjects,
    );
  }

  static Future<String> setEmailAndUserId(String email, String userId) async {
    return await IterablePlatform.instance.setEmailAndUserId(
      email,
      userId,
    );
  }

  static Future<IterableAttributionInfo?> getAttributionInfo() async {
    return await IterablePlatform.instance.getAttributionInfo();
  }

  static setAttributionInfo(IterableAttributionInfo attributionInfo) {
    IterablePlatform.instance.setAttributionInfo(attributionInfo);
  }

  static trackEvent(
    String name,
    Map<String, Object>? dataFields,
  ) {
    IterablePlatform.instance.trackEvent(name, dataFields);
  }

  static updateCart(List<IterableCommerceItem> items) {
    IterablePlatform.instance.updateCart(items);
  }

  static trackPurchase(
    double total,
    List<IterableCommerceItem> items,
    Map<String, Object>? dataFields,
  ) {
    IterablePlatform.instance.trackPurchase(
      total,
      items,
      dataFields,
    );
  }

  static disableDeviceForCurrentUser() {
    IterablePlatform.instance.disableDeviceForCurrentUser();
  }

  static trackPushOpenWithCampaignId(
    int campaignId,
    int templateId,
    String messageId,
    bool appAlreadyRunning,
    Map<String, Object>? dataFields,
  ) {
    IterablePlatform.instance.trackPushOpenWithCampaignId(
      campaignId,
      templateId,
      messageId,
      appAlreadyRunning,
      dataFields,
    );
  }

  static Future<dynamic> getLastPushPayload() async {
    return await IterablePlatform.instance.getLastPushPayload();
  }

  static updateSubscriptions({
    List<int>? emailListIds,
    List<int>? unsubscribedChannelIds,
    List<int>? unsubscribedMessageTypeIds,
    List<int>? subscribedMessageTypeIds,
    int? campaignId,
    int? templateId,
  }) {
    IterablePlatform.instance.updateSubscriptions(
      emailListIds: emailListIds,
      campaignId: campaignId,
      subscribedMessageTypeIds: subscribedMessageTypeIds,
      templateId: templateId,
      unsubscribedChannelIds: unsubscribedChannelIds,
      unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
    );
  }

  static trackInAppOpen(
    IterableInAppMessage message,
    IterableInAppLocation location,
  ) {
    IterablePlatform.instance.trackInAppOpen(message, location);
  }

  static trackInAppClick(
    IterableInAppMessage message,
    IterableInAppLocation location,
    String clickedUrl,
  ) {
    IterablePlatform.instance.trackInAppClick(
      message,
      location,
      clickedUrl,
    );
  }

  static trackInAppClose(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppCloseSource source,
    String? clickedUrl,
  ) {
    IterablePlatform.instance.trackInAppClose(
      message,
      location,
      source,
      clickedUrl,
    );
  }

  static inAppConsume(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppDeleteSource source,
  ) {
    IterablePlatform.instance.inAppConsume(
      message,
      location,
      source,
    );
  }
}
