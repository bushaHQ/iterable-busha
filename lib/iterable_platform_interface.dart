import 'package:iterable/common.dart';
import 'package:iterable/inapp/inapp_common.dart';
import 'package:iterable/inapp/inapp_manager.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'iterable_method_channel.dart';

abstract class IterablePlatform extends PlatformInterface {
  /// Constructs a IterablePlatform.
  IterablePlatform() : super(token: _token);

  static final _inAppManager = IterableInAppManager();
 


  static final Object _token = Object();

  static IterablePlatform _instance = MethodChannelIterable();

  static get inAppManager => _inAppManager; 
  /// The default instance of [IterablePlatform] to use.
  ///
  /// Defaults to [MethodChannelIterable].
  static IterablePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IterablePlatform] when
  /// they register themselves.
  static set instance(IterablePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initialize(String apiKey, IterableConfig config) {
    throw UnimplementedError("initialize() has not been implemented");
  }

  void setEmail(String? email);

  Future<String> getEmail() {
    throw UnimplementedError("getEmail() has not been implemented");
  }

  /// Updates the user [email]
  ///
  /// [Future<String>] upon success or failure
  Future<String> updateEmail(String email) async {
    throw UnimplementedError("getEmail() has not been implemented");
  }

  /// Sets user [id] on the user profile
  void setUserId(String? id);

  /// Retrieves the current user id for the user
  ///
  /// [Future<String>] user id
  Future<String> getUserId() async {
    throw UnimplementedError("getEmail() has not been implemented");
  }

  /// Updates the user [dataFields]
  ///
  /// [Future<String>] upon success or failure
  Future<String> updateUser(
    Map<String, Object> dataFields,
    bool? mergeNestedObjects,
  ) async {
    throw UnimplementedError("method has not been implemented");
  }

  /// Sets the user [email] and [userId] at the same time
  ///
  /// [Future<String>] upon success or failure
  Future<String> setEmailAndUserId(String email, String userId) async {
    throw UnimplementedError("method has not been implemented");
  }

  /// Retrieves the current attribution information (based on a recent deep link click)
  ///
  /// [Future<IterableAttributionInfo>]
  Future<IterableAttributionInfo?> getAttributionInfo() async {
    throw UnimplementedError("method has not been implemented");
  }

  /// Manually sets the current attribution information so that it can later be used when tracking events
  void setAttributionInfo(IterableAttributionInfo attributionInfo);

  /// Tracks a custom event with [name] and optional [dataFields]
  void trackEvent(String name, Map<String, Object>? dataFields);

  /// Tracks updates to the cart [items]
  void updateCart(List<IterableCommerceItem> items);

  // void updateSignUp

  /// Tracks a purchase with order [total] cart [items] and optional [dataFields]
  void trackPurchase(
    double total,
    List<IterableCommerceItem> items,
    Map<String, Object>? dataFields,
  );

  /// Disables the device for a current user
  void disableDeviceForCurrentUser();

  /// Tracks a push open event manually
  void trackPushOpenWithCampaignId(
    int campaignId,
    int templateId,
    String messageId,
    bool appAlreadyRunning,
    Map<String, Object>? dataFields,
  );

  /// Get the last push payload
  ///
  /// [Future<dynamic>] the most recent push payload
  Future<dynamic> getLastPushPayload() async {
    throw UnimplementedError("method has not been implemented");
  }

  /// Updates subscription preferences for the user
  /// from a list of [emailListIds] or [unsubscribedChannelIds]
  /// or [unsubscribedMessageTypeIds] or [subscribedMessageTypeIds]
  /// can also optionally include [campaignId] and/or [templateId]
  void updateSubscriptions({
    List<int>? emailListIds,
    List<int>? unsubscribedChannelIds,
    List<int>? unsubscribedMessageTypeIds,
    List<int>? subscribedMessageTypeIds,
    int? campaignId,
    int? templateId,
  });

  /// Tracks an in-app [message] open event manually
  void trackInAppOpen(
    IterableInAppMessage message,
    IterableInAppLocation location,
  );

  /// Tracks an in-app [message] click event manually
  void trackInAppClick(
    IterableInAppMessage message,
    IterableInAppLocation location,
    String clickedUrl,
  );

  /// Tracks an in-app [message] close event manually
  void trackInAppClose(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppCloseSource source,
    String? clickedUrl,
  );

  /// Consumes an in-app [message] from the queue
  void inAppConsume(
    IterableInAppMessage message,
    IterableInAppLocation location,
    IterableInAppDeleteSource source,
  );
}
