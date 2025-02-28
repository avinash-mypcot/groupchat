import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      // "type": "service_account",
      // "project_id": "groupchat-436c7",
      // "private_key_id": "53e03ccb88625a5d267112c079bc9e3d425fd86b",
      // "private_key":
      //     "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC9t1G426/rgDvn\nSXEOJMpp9nVhP/LN0bsfXx6Su680xyPLz3EtyPRvoZQACpM8pQcTXPfN3lGkfuKX\nXDDCS5Cu+fyiGdFh8s3sv84WK9tzd9LwMnrpT0gYkXVAqUKeEXgaL2YEoo4q5jb/\nH2dbjztGV6gcEA+uLUmHtnGdOaIdoX8EvfUrMCehaoz/qZ+TmsLG4qBnqWZ9Y+L/\nSKUqxQsx7lYxcEb5PMz4hpwZ//XQZxEo7gXBeJBaEszP7EWdBxyW98EtrlncFT21\nzhpsgBt51f3QdMz0SXWbw1gBYyNNjai0xjxrePLjttfgZBmvYKJgnsCKPBua0sxv\nnv7b5bKbAgMBAAECggEAOLyLyKSOunfZsmRA1tGC5WirFv/obcw00X+BZbGShs6t\ncmTh/KbWD1J7r/15pg/Wi2BozZ0YvoCh5FFSVbECnomtl47wEwJpuk1sZS4Njb0+\njM4T+xVWQt6xebqE7T/dMruNH4K70LGTrf2my/eMaw+I+4eEIPtzO46A8NvNE132\nUDsFS0GpX5gIeILHb30kp1MP20XZqY/r8CaATGqqj3Z3Mj5kNQSX+riSmlEJLu0C\nTAviE7R3tQvuu7GaWXsY/gm8WcwXpX6tXSyi6e7+ImFQkT/fb4Ou6SEp01vcoyhc\nxz+ob2JDyBcpdBfIq2mwMgYDP5TY/C4Hj954sWZtlQKBgQDqC+Y/s5g2b77AYPsM\nuCECqFy4nueJ9/0taKS59S20wUpiGjIq+lwC3UM7dabuHFkWCKn3wahAc8dt/Fy5\nD52ct8idu6iDZUxW9yp6CYQykX01nNOm8Y5VhG2JtxVZhm7/7TGPUsBp2eSSSdvZ\nUAL81GbC4BTGXHhGsGPu01+bDwKBgQDPguzPOjscqoSRbJ7Ibq2mEYEhCQEej70D\neTumJ2nOLHIaGo11fp2+mggN4P2jbHmKO/k8iVTtYEZEJy7XN7qeYBRCXJbrc+nd\nMS0LxyJ+JONGQFvXaF4v04TDQMDfpi2zVPdn9GTftdETfLGAwcRUJTS91OPKcc82\nFFAyBxXftQKBgQCv18bjP3TyGVzwvyx/ruumSoZ3c3Q0taxzbHau/GWds8fGEzZ0\nEewFfuYfi1Ki/Yt1QYcqDUbzPcmtefjUVcYuU+qXj8GZDwefI063p+S59ZNkL3LZ\nsA0ndTqzSGny/EzzXetpalwEa2APBQz3peTIvnCCo8cYDauUOLysWAUxwwKBgQCb\nEH3/WMdFY5LOzPlWU4aFm3z//6eLe+PFjblqLvecro/RO9hLXYNpI9cy79b5YRzt\nlGVpvEHvZEr9sL4K60UUBj39XQ0WAzdWJ+I+c98tnkkLfRpkPERtvsTt1xyJw7dQ\n1ARQ9UrP9SC4TCykR6d7LZZc6JIT/LnX8pP+3laVJQKBgCF57BSEbei+4E5ANEOV\nrw99TfxA9h6uFgI75PlrGO4io3ARqA0tgCb3v28d7ryHxDNUY4BZ8/bsHXGohH5B\nwlXxbZwBYyG5AfsNrQXw7u9AM6TB0rOhY2LQ1Nx5bF0WLiLpUcR3OT9yvf0ks1tS\nckVIvI0Uh5WZR6wqw0Hc1fnc\n-----END PRIVATE KEY-----\n",
      // "client_email":
      //     "firebase-adminsdk-fbsvc@groupchat-436c7.iam.gserviceaccount.com",
      // "client_id": "104393461038775224964",
      // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      // "token_uri": "https://oauth2.googleapis.com/token",
      // "auth_provider_x509_cert_url":
      //     "https://www.googleapis.com/oauth2/v1/certs",
      // "client_x509_cert_url":
      //     "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40groupchat-436c7.iam.gserviceaccount.com",
      // "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken, String tripID,
      {required String channelId,
      required String senderId,
      required String reciverId,
      required String reciverName}) async {
    log("IN SENT SMS");
    final String serviceKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/groupchat-436c7/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        // 'notification': {'title': 'New Message', 'body': tripID},
        'data': {
          'tripID': tripID,
          'title': 'New Message',
          'body': tripID,
          'senderId': senderId,
          'channelId': channelId,
          'reciverId': reciverId,
          'reciverName': reciverName,
          "action": "reply"
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent Success");
    } else {
      print('Notification not sent ${response.statusCode}');
    }
  }
}
