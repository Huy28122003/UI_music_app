import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:music/services/firebase_tracker_service.dart';
class HTTPv1Service{
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
        "type": "service_account",
        "project_id": "music-6e9f9",
        "private_key_id": "9074c902bad8dc2de8e020186eb0694b6eb3505a",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCsrNxz6rg09emO\nslKM331sy8+sRE7VrWGRiXFvqHUUkBzCE/hHVcHbQm7Yp46hJYr/zwqlpP6T5LPD\nnSXyuh4NaRSsQ0AOtjtwikfps1hhopTvtiJvkrK9JvT0zvfZcBeFKw6vDa4b3u2I\nYyP+JKmRTA+jZ3YsVvSI8O4o6nFegh/E2tKM0dS+cz8DWvGCjpX9S7tiIjhJxY0d\nxkT8xas8FF8o3XOhoGYKIIO0OIh77+/NxZu93Ttmx3I4q5W3wART851ci2Dts14Y\nGclbHL/9Ji2NgoGE/AZsTuD/IqvNj0rfCUIHB0+f1ImmzqfQNy0f/rWG7DL7RPZ+\nRqXOzvjDAgMBAAECggEAGzNWaCgnAP4P3uZLnLID8aR1aqnj+phHpgO5oSDZ40sE\nTLTqnQoZnIQYLqbOZVIjAEL0EWiD9ctxXzTHv+Go+Zco+4Moeb4jxN7zjxEtBfb0\nxoIGu1P84KZcsJz9wVHSqAFCseP8yO/Ss8kHksbhsz1WZU4so7VwQIt7aL9C6+O0\nYEjZAyNCuuz3Wpid0kv/q96XtpFdhyVoKt7STCYITAt8uSNP1ZsdGz/RKgDd6a3K\n5qxRAT1AaiVS2owPvgYgDXZBQr59+I8PUV58OQ5oEJQhvISIIBrO732ETdmGAYfn\nx/zQr5L4Lv3S1HMHnwq8K5Rqjvzjl8sdgvQPEjt6CQKBgQDn70IBv8FVUkQr8TZY\nu0pAQtyrJvvmsgIDIBb+lpwtT6RAmZNoDtvgTnAXxZ1dQWP1QUp1WGhGRljzjMxH\nHy7z/A4T4h89ei3F46k+FHA45NcBvXYkulaAwtkz0Y8zdOBL0apkffI3rfxspq70\nKc1QZ9vDoAo897Hb1tF9oV2VXQKBgQC+l4gi2yBFrFFFfI68XWLzwczmGKeRkNBc\nGcOL/VO6MiP46xabm1tr8XGKrVBXNsjuztu4ETSbzg2LmBHNybXJcPnHUI3UI8GT\nANdUwgq4w7ZUKJF98kp9ad4xvnrRGmtmLdDIz84J2jyldkdThF27IsRsD3LHppVY\nSD8Og2TEnwKBgDY8J4Y7Ld1iwFg6LogvO5ytRear1gnLJFdQwK/Fzj12OyV0BBk4\nKEhabzHP3w14hgRKwTuRccjFGHXTPc1/yD37edtCbCW3FU8J/oBqzRcww+o/QIo0\nHJg9eAb7AO56bRytqZeYL/S/NaC+lXi48a7UqnojSWGaVjffEtu6ySRtAoGBALRC\nXV+aIEvFTpiJ1fYR3STuhvyZFON4M5joRSqBzk6sXZlvv1Is/ap6EQk4ImRaTHCQ\n9P6CR1+U4vrEORKJVIXRdGwuo/WgW9TNVtuzKrDVafzu4axdHFbBaoVhwodClZFu\ng6lp4VUwM2vLEmrLJlt35o7NjaGGzHlS21C+tO/BAoGBAOMpE7msegvvonSe/Dw6\nIW2cS3nxvG3TPamgp8sbKaAfysaTnlcmsWe9gyT88G5J12do4OMoTzwwxZOikyze\n+ylbxywn3Rvjt5L3EjVNES1qhgh9HgM3UYgANVR2Q+IXFuzahW9xSR/I70mOURvp\ni66Q1so0hFci9Uv+CKVfq9AV\n-----END PRIVATE KEY-----\n",
        "client_email": "music-6e9f9@appspot.gserviceaccount.com",
        "client_id": "109801189733527710192",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/music-6e9f9%40appspot.gserviceaccount.com",
        "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }
  Future<void> sendFCMMessage() async {
    List<String> fcmToken = await FirebaseTracker().getFcmToken();
    final String serverKey = await getAccessToken() ; // Your FCM server key
    final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/music-6e9f9/messages:send';
    final  currentFCMToken = await FirebaseMessaging.instance.getToken();
    print("currently device FCM token   : $currentFCMToken");
    List<String> setFcmToken = fcmToken.toSet().toList();
    for (var token in setFcmToken) {
      final Map<String, dynamic> message = {
        'message': {
          'token': token,
          'notification': {
            'body': 'This is an FCM notification message!',
            'title': 'FCM Message'
          },
          'data': {
            'current_user_fcm_token': currentFCMToken,
          },
        }
      };

      final http.Response response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
      } else {
        print('Failed to send FCM message: ${response.body}');
      }
    }
  }
}