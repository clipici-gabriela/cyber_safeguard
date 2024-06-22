import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationSender {
  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "cybersafeguard-34bb3",
      "private_key_id": "07634e134740bd8e92bacee78ca8bbc93d06c14c",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCaVDOgPDDNiK2D\nna+RZG5+qeqpuhz3755qDlwXwjEXJssB1iO+wKeNluxXbQDzfKL/8zmbRZv5dFui\ni2OYxKiKFxMVefovcDOZQgKviWIjYdyOh5BR43tcQHqciF3NKgFKupmYlCGErLf4\nIBLsD4JOYfhQSDyo1oyL5JacIVYdFWnVa/FG/yiVoicGG0kkSNF1JAQ2EFmYtXTC\nWJrksWIAoj93ri9Nrwww/4703H3cys+HLzftYd92QtuRnv/H+CtWhS8rpJTrrozN\n1VRUnx0GPd1XEtbb0sZfP8pVS75kJH5zVaXG6sS9VU9uydKltHw74vVIWXghSDDy\ncv7xMe4XAgMBAAECggEAPBwLt596CrPvkVH7rg+GEgOwiMcavV8xPnG1YPOcFz5e\n16pGZee32ygrianFMxEak8Jyb43fQHwXrOnJsxj15EM0harqzUtQbaMOVLyX4twd\nAc6/YYXO6JGcsBdVIbH4qtifNpSLsZdsWFJ1zEgGIu15wBtCtShLubkhCFLbrZus\nY/lbChZzwf02YFt+3Y6C3dgLMA6p4iKviTeax0CeTqzCHUOQk/hguY9RtZjza65m\naXfIHPyHRtQicBklRG3cZrn/xM5GibZrUwAiOqAo3AHuwMrUzZVgZRki8SC0tclx\ncsF2Zv93wedYj6XqhpgcKz3IR2sQ8xqGIOn56S+30QKBgQDT3Hl6MMsxTI0Cn4+4\nlKZY6sWm5awiDfAyK3khmNrvoJbU6DPJEaT5vETtM6bmnNdvb+rxIUOV03AvoSL5\npDukDmYxRVRntwQnBkOYZG81jyy2wFiaTa+Eg8UBW9LONDL0t7TqWY5d0+muH73o\nVBlSnc1U8jgMiHbiqm+Vu3yNQwKBgQC6e0Qw+DiuXsuvqt0rGOXNHxbjOFfsCSuU\nRDPbl4Cfg0F2756Gfg+FWUTrPOubVdXzCXcB4/X37R+kNvjub3Gp6nyEZoDYBQSw\nLjD7byZ2RrglVoGJZKfw5gjqXk6yn9hu35AIQ8MSO7oxS4gXr0+EKm4/TdAkROFW\n/fpv0TjEnQKBgCFyCtNZZJpxxUkGu3+eJ+ydk3pXg6cUoDirWEIPiXCO34DY72Ps\nnyi1qgPwRYbed7wl5OcQI0VBzdIXFBho7ullRIi+syZ0Y/ltKbqjEFNaOOrYzqP9\nY5n921ntjwfygaDUZ4EfhjQVwiw04pwMurqqIsIoQuTnni0GTvtKT81VAoGAcOYB\n8dfFkSPJEzBRuC7ZqabB14ycBkXDAX+NGcwOTgRMFPKbOfeF9AiIphZ62c9MuVgo\nmZdmqdQAjQ3PBaOo3+MbwZjBNodLQFKmywKO+Zp1D/3gbMrotfq+uQ2hfZkykmV9\nMNO9fQN2BTQiT5yOeoipuF+mvN6Kwnz/KsUzJi0CgYEAnJmo0JjZVpUuO5uRKMgT\neptCm2iau30r0tkCj6BQGccyXTKhgAQvPXOOAPOEsJ/V23Y47PCpHoYVC+KFOa8P\n7lEiPoIDK7PQYnjZu8V2fY5VhACUxJHRvI+JvE7zVitYs1HyZERqhFH667Ylycj4\nUUnaSW+lxt/0DbVSs6RZq8A=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-cyber-safe@cybersafeguard-34bb3.iam.gserviceaccount.com",
      "client_id": "102395708068576610638",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-cyber-safe%40cybersafeguard-34bb3.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scope = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scope,
    );

    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scope,
      client
    );

    client.close();

    return credentials.accessToken.data;
  }

  sendNotification(String deviceToken, BuildContext context, String tripId, String title, String body) async {

    final String serviceKey = await getAccessToken();

    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/cybersafeguard-34bb3/messages:send';

    final Map<String, dynamic> messages = 
    {
      'message':
      {
        'token': deviceToken,
        'notification':
        {
          'title':title,
          'body':body
        },
        'data':
        {
          'id':''
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
      {
        'Content-Type':'application/json',
        'Authorization': 'Bearer $serviceKey'
      },
      body: jsonEncode(messages),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed, notification not sent: ${response.statusCode}');
    }
  }
}
