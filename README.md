![Iterable-Logo](https://user-images.githubusercontent.com/7387001/129065810-44b39e27-e319-408c-b87c-4d6b37e1f3b2.png)

# Iterable's Flutter SDK

[Iterable](https://www.iterable.com) is a growth marketing platform that helps you to create better experiences for—and deeper relationships with—your customers. Use it to send customized email, SMS, push notification, and in-app message campaigns to your customers.

This SDK helps you integrate your Flutter apps with Iterable.

# API

Below are the methods this SDK exposes. See [Iterable's API Docs](https://api.iterable.com/api/docs) for information on what data to pass and what payload to receive from the HTTP requests.

## Iterable
Static methods available within the `Iterable` class.


| Method Name           	| Description                                                                                                               	|
|-----------------------	|---------------------------------------------------------------------------------------------------------------------------	|
| [`initialize`](#initialize)        	| Initialize the Iterable SDK with an [`IterableConfig`](#iterableConfig) object and `apiKey`                                                                           	|
| [`setEmail`](#setEmail)        	| Identify a user with an email address as the primary identifier                                                                           	|
| [`setUserId`](#setUserId)        	| Identify a user with a userId as the primary identifier                                                                           	|
| [`setEmailAndUserId `](#setEmailAndUserId)        	| Identify a user with both an email and a userId	|
| [`getEmail`](#getEmail)        	| Get the current email address for the user                                                              	|
| [`getUserId`](#getUserId)        	| Get the current userId for the user                                                      	|
| [`updateEmail`](#updateEmail)     	| Change a user's email address                                                                                             	|
| [`updateUser`](#updateUser)          	| Change data on a user's profile or create a user if none exists                                                           	|
| [`updateSubscriptions`](#updateSubscriptions) 	| Updates user's subscriptions                                                                                              	|
| [`trackEvent `](#trackEvent)               	| Track custom events |
| [`updateCart`](#updateCart)          	| Update _shoppingCartItems_ field on user profile                                                                          	|
| [`trackPurchase`](#trackPurchase)       	| Track purchase events                                                                                                                                                                                                         	|
| [`trackPushOpenWithCampaignId`](#trackPushOpenWithCampaignId)       	| Iterable's SDK automatically tracks push notification opens. However, it's also possible to manually track these events by calling this method	|
| [`getLastPushPayload`](#getLastPushPayload)       	| Get the payload associated with the most recent push notification with which the user opened the app (by clicking an action button, etc.)	|
| [`disableDeviceForCurrentUser`](#disableDeviceForCurrentUser)       	| Manually disables push notifications for the device	|
| [`trackInAppOpen`](#trackInAppOpen)      	| Track when a message is opened and marks it as read                                                                       	|
| [`trackInAppClick`](#trackInAppClick)     	| Track when a user clicks on a button or link within a message                                                             	|
| [`trackInAppClose `](#trackInAppClose)  	| Track when an in-app message is closed                                                               	|
| [`inAppConsume `](#inAppConsume)   	| Track when a message has been consumed. Deletes the in-app message from the server so it won't be returned anymore        	|
| [`getAttributionInfo `](#getAttributionInfo)    	| To get the current attribution information (based on a recent deep link click) 	|
| [`setAttributionInfo `](#setAttributionInfo)    	| To manually set the current attribution information so that it can later be used when tracking events 	|

## IterableInAppManager
Static methods available on the `inAppManager` property within the `Iterable` class.


| Method Name           	| Description                                                                                                               	|
|-----------------------	|---------------------------------------------------------------------------------------------------------------------------	|
| [`getInAppMessages`](#getInAppMessages)    	| Returns all of the in-app messages for the user 	|
| [`showMessage`](#showMessage)     	| Shows an in-app message that had been skipped previously.                                                             	|
| [`removeMessage`](#removeMessage)     	| Removes the specified message from the user's message queue                                                                                    	|
| [`setReadForMessage`](#setReadForMessage)     	| Sets the `read` property for a given message. Used when maintaining a messaging inbox.	|
| [`getHtmlContentForMessage`](#getHtmlContentForMessage)     	| Gets the HTML content of an in-app message	|
| [`setAutoDisplayPaused`](#setAutoDisplayPaused)     	| Sets whether or not the in-apps should be displayed automatically	|


## IterableConfig
Optional configuration settings available pre-initialization.

| Name                      | Type                                                                                                                                                                                                                     | Description                                                           | Default   |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|-----------|
| pushIntegrationName           |  `String` | The name of the corresponding push integration that has been configured in Iterable                                                                                                                                                | The package name or bundle id of your native project     |
| autoPushRegistration | `bool` |When `true`, causes the SDK to automatically register and deregister for push tokens when you provide email or userId values to the SDK                                                                                                                                               | `true` |
| inAppDisplayInterval                                                                                  | `double`           | When displaying multiple in-app messages in sequence, the number of seconds to wait between each                                                     | `30.0` |
| expiringAuthTokenRefreshPeriod                                                                                      | `double`  | The number of seconds before the current JWT's expiration that the SDK should call the `authHandler` to get an updated JWT.                                                           | `60.0` |
| logLevel              |  [`IterableLogLevel`](#loglevel) | The level of logging                                                                                             |                                                           `IterableLogLevel.error` |
| allowedProtocols               | `List<String>`                                                          | Specific URL protocols that the SDK can expect to see on incoming links (and that it should handle as needed).                                                                    | `["https", "action", "itbl", "iterable"]` |
| inAppHandler         |  [`IterableInAppHandler`](#iterableinapphandler)      | Implement this property to override default in-app message behavior.                                                                                                                                                   |                                                          |
| customActionHandler               |  [`IterableCustomActionHandler`](#iterablecustomactionhandler) | Use this method to determine whether or not the app can handle the clicked custom action URL. If it can, it should handle the action and return `true`. Otherwise, it should return `false` ||
| urlHandler               |[`IterableUrlHandler`](#iterableurlhandler) |  Use this method to determine whether or not the app can handle the clicked URL. If it can, the method should navigate the user to the right content in the app and return `true`. Otherwise, it should return `false` to have the web browser open the URL. ||
| authHandler               |  [`IterableAuthHandler`](#iterableauthhandler) | Provides a JWT to Iterable's Flutter SDK, which can then append the JWT to subsequent API requests. The SDK automatically calls authHandler at various times. |  |

## IterableInAppHandler

When Iterable retrieves in-app messages, it passes them to the function stored in the `inAppHandler` property of the [`IterableConfig`](#iterableconfig) object that was passed to the SDK's `initialize`method.

Implement this property to override default in-app message behavior. For example, you might use the `customPayload` associated with an incoming message to choose whether or not to display it, or you might inspect the `priorityLevel` property to determine the message's priority.

```
IterableInAppShowResponse Function(IterableInAppMessage msg)
```

Example:

```
 final config = IterableConfig();
 
 IterableInAppShowResponse inAppHandler(IterableInAppMessage message) {
    if (message.customPayload?["shouldSkip"] == true) {
      return IterableInAppShowResponse.skip;
    } else {
      return IterableInAppShowResponse.show;
    }
  }
  
  config.inAppHandler = inAppHandler;
  
```


## IterableCustomActionHandler

To handle custom action URLs, provide a function to the `customActionHandler` property on the [`IterableConfig`](#iterableconfig) object passed to the SDK's `initialize` method. Iterable calls this method when a user clicks a URL, passing in the URL and other contextual information.

Use this method to determine whether or not the app can handle the clicked custom action URL. If it can, it should handle the action and return `true`. Otherwise, it should return `false`.

```
bool Function(IterableAction action, IterableActionContext context);
```

Example:

```
  final config = IterableConfig();

  bool customActionHandler(IterableAction action, IterableActionContext actionContext) {
    if (action.type.contains("discount?promo=")) {
      String promoCode = action.type.split("?promo=")[1];
      _showAlert(promoCode);
      return true;
    }
    return false;
  }
  
  config.customActionHandler = customActionHandler;
  
```

## IterableUrlHandler

To handle deep links (and other URLs), Iterable calls the function stored in the [`IterableConfig`](#iterableconfig) object's `urlHandler`. Set this property on the `IterableConfig` you provide to the SDK's initialize method.

Use this method to determine whether or not the app can handle the clicked URL. If it can, the method should navigate the user to the right content in the app and return `true`. Otherwise, it should return `false` to have the web browser open the URL.

```
bool Function(String url, IterableActionContext context);
```

Example:

```
  final config = IterableConfig();
  
  bool urlHandler(String url, IterableActionContext context) {
    int tabIndex = DeeplinkHandler.handle(url).toInt();
    _tabController.animateTo(tabIndex);
    return true;
  }
  
  config.urlHandler = urlHandler;
    
```  
# Usage

## initialize 

API:

```
Future<bool> initialize(String apiKey, IterableConfig config)
```

Example:

```
final config = IterableConfig(inAppDisplayInterval: 1.0, logLevel: IterableLogLevel.info);

IterableAPI.initialize('YOUR_API_KEY', config).then((success) => {
	if (success) {
		debugPrint('Iterable Initialized'),
		IterableAPI.setEmail("email@example.com")
   }
});
```

## setEmail

API:

```
setEmail(String? email)
```

Example:

```
IterableAPI.setEmail("email@example.com");
```

## setUserId 

API:

```
setUserId(String? userId)
```

Example:

```
IterableAPI.setUserId("user123123");
```

## setEmailAndUserId 

API:

```
Future<String> setEmailAndUserId(String email, String userId)
```

Example:

```
IterableAPI.setEmailAndUserId("email@example.com", "user123123")
           .then((response) => debugPrint(jsonEncode(response)));
``` 

## getEmail 

API:

```
Future<String> getEmail()
```

Example:

```
IterableAPI.getEmail()
           .then((email) => debugPrint('Current Email: $email'));
```

## getUserId 

API:

```
Future<String> getUserId()
```

Example:

```
IterableAPI.getUserId()
           .then((userId) => debugPrint('Current User Id: $userId'));
```

## updateEmail 

API:

```
Future<String> updateEmail(String email)
```

Example:

```
IterableAPI.updateEmail("email@example.com")
           .then((response) => debugPrint(jsonEncode(response));
```

## updateUser 


API:

```
Future<String> updateUser(Map<String, Object> dataFields, bool? mergeNestedObjects)
```

Example:

```
IterableAPI.updateUser({'favoriteColor': 'blue'}, false)
           .then((response) => debugPrint(jsonEncode(response)));
```

## updateSubscriptions 

API:

```
updateSubscriptions({
	List<int>? emailListIds,
	List<int>? unsubscribedChannelIds,
	List<int>? unsubscribedMessageTypeIds,
	List<int>? subscribedMessageTypeIds,
	int? campaignId,
	int? templateId
})
```

Example:

```
IterableAPI.updateSubscriptions(
	emailListIds: [1234],
	subscribedMessageTypeIds: [12345],
	unsubscribedChannelIds: [67890],
	unsubscribedMessageTypeIds: [78901]
);
```

## trackEvent 

API:

```
trackEvent(String name, Map<String, Object>? dataFields)
```

Example:

```
IterableAPI.trackEvent('Added Promo', {'promoCode': 'abc123'});
```

## updateCart 

API:

```
updateCart(List<IterableCommerceItem> items)
```

Example:

```
List<IterableCommerceItem> items = [
      IterableCommerceItem("abc123", "Shirt", 9.99, 1,
          sku: "abc123-xyz456",
          categories: ["sale", "blouses"],
          dataFields: {"eligible_rewards": 1000}),
      IterableCommerceItem("def456", "Shoes", 19.99, 2,
          sku: "def456-tuv789",
          categories: ["hot items", "women's"],
          dataFields: {"promo": "summer2022"})
];

IterableAPI.updateCart(items);
```

## trackPurchase 

API:

```
trackPurchase(double total, List<IterableCommerceItem> items, Map<String, Object>? dataFields)
```

Example:

```
List<IterableCommerceItem> items = [
      IterableCommerceItem("def456", "Shoes", 19.99, 2,
          sku: "def456-tuv789",
          categories: ["hot items", "women's"],
          dataFields: {"promo": "summer2022"})
];

IterableAPI.trackPurchase(19.98, items, {'rewards': 100});
```


## trackPushOpenWithCampaignId 

API:

```
trackPushOpenWithCampaignId(
	int campaignId,
	int templateId,
	String messageId,
	bool appAlreadyRunning,
	Map<String, Object>? dataFields
)
```

Example:

```
IterableAPI.trackPushOpenWithCampaignId(
	123456,
	789012,
	"gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ",
	false,
	{'promo': 'abc123'}
);
```

## getLastPushPayload 

API:

```
Future<dynamic> getLastPushPayload()
```

Example:

```
IterableAPI.getLastPushPayload().then((payload) => debugPrint('Last Push Payload: $payload');
```

## disableDeviceForCurrentUser 

API:

```
disableDeviceForCurrentUser()
```

Example:

```
IterableAPI.disableDeviceForCurrentUser();
```

## trackInAppOpen 

API:

```
trackInAppOpen(IterableInAppMessage message, IterableInAppLocation location)
```

Example:

```
IterableAPI.trackInAppOpen(message, IterableInAppLocation.inApp);
```

## trackInAppClick 

API:

```
trackInAppClick(IterableInAppMessage message, IterableInAppLocation location, String clickedUrl)
```

Example:

```
IterableAPI.trackInAppClick(
	message,
	IterableInAppLocation.inApp,
	"https://example.com/deeplinkurl"
);
```

## trackInAppClose 

API:

```
trackInAppClose(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppCloseSource source,
	String? clickedUrl
)
```

Example:

```
IterableAPI.trackInAppClose(
	message,
	IterableInAppLocation.inApp,
	IterableInAppCloseSource.link,
	"https:/example.com/deeplink-close"
);
``` 

## inAppConsume 


API:

```
inAppConsume(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppDeleteSource source
)
```

Example:

```
IterableAPI.inAppConsume(
	message, 
	IterableInAppLocation.inbox,
	IterableInAppDeleteSource.inboxSwipe
);
``` 

## getMessages 

API:

```
Future<List<IterableInAppMessage>> getMessages()
```

Example:

```
IterableAPI
	.inAppManager
   		.getMessages()
			.then((messages) => {
				messages
					.asMap()
					.forEach((index, message) => {
            			developer.log(jsonEncode((message.toJson())));
           		});
    		});
``` 

## getAttributionInfo 

API:

```
Future<IterableAttributionInfo?> getAttributionInfo()
```

Example:

```
IterableAPI.getAttributionInfo()
           .then((attrInfo) => debugPrint(jsonEncode(attrInfo?.toJson())))
``` 

## setAttributionInfo 

API:

```
setAttributionInfo(IterableAttributionInfo attributionInfo)
```

Example:

```
IterableAPI.setAttributionInfo(
		IterableAttributionInfo(
      		123456, 789012, "gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ")
      	)
``` 

## showMessage

API:

```
Future<String?> showMessage(IterableInAppMessage message, bool consume)
```

Example:

```
IterableAPI.inAppManager.showMessage(message, true)
``` 

## removeMessage

API:

```
removeMessage(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppDeleteSource source
)
```

Example:

```
IterableAPI.inAppManager.removeMessage(
	message,
	IterableInAppLocation.inApp,
	IterableInAppDeleteSource.deleteButton
)
``` 

## setReadForMessage

API:

```
setReadForMessage(IterableInAppMessage message, bool read)
```

Example:

```
IterableAPI.inAppManager.setReadForMessage(message, true)
``` 

## getHtmlContentForMessage

API:

```
Future<IterableHtmlInAppContent> getHtmlContentForMessage(IterableInAppMessage message)
```

Example:

```
IterableAPI
	.inAppManager
	.getHtmlContentForMessage(message)
	.then((content) =>
		debugPrint(jsonEncode((content.toJson()))))
```

## setAutoDisplayPaused


API:

```
setAutoDisplayPaused(bool paused)
```

Example:

```
IterableAPI.inAppManager.setAutoDisplayPaused(true)
``` 


# FAQ

 1. How do I logout a user?<br><br>
    **Answer:** There is no explicit `logout()` method in the API, but you can easily log out a user by setting `email` and/or `userId` to `null`.<br>

	Example:
	
	```
	LogoutButton(
	    title: 'Logout',
	    onPressed: () => {
	          IterableAPI.setEmail(null),
	          IterableAPI.setUserId(null),
	        })
	```
