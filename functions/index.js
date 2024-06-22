// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// const { google } = require("googleapis");
// const fetch = require("node-fetch");

// admin.initializeApp({
//   credential: admin.credential.applicationDefault(),
// });

// const SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];

// function getAccessToken() {
//   return new Promise(function (resolve, reject) {
//     const key = require('./credentials/cybersafeguard-34bb3-07634e134740.json');
//     const jwtClient = new google.auth.JWT(
//       key.client_email,
//       null,
//       key.private_key,
//       SCOPES,
//       null
//     );
//     jwtClient.authorize(function (err, tokens) {
//       if (err) {
//         reject(err);
//         return;
//       }
//       resolve(tokens.access_token);
//     });
//   });
// }

// exports.sendTaskNotification = functions.firestore
//   .document("Tasks/{taskId}")
//   .onCreate(async (snap, context) => {
//     const taskData = snap.data();
//     const assignedToName = taskData.assignedTo;
//     console.log("Assigned To Name:", assignedToName);

//     // Query the Users collection to find the document with the matching firstName
//     const userQuerySnapshot = await admin.firestore().collection("Users")
//       .where("firstName", "==", assignedToName)
//       .get();

//     if (!userQuerySnapshot.empty) {
//       const userDoc = userQuerySnapshot.docs[0];
//       const fcmToken = userDoc.data().fcmToken;

//       if (fcmToken) {
//         const payload = {
//           message: {
//             token: fcmToken,
//             notification: {
//               title: "New Task Assigned",
//               body: `You have a new task: ${taskData.description}`,
//             },
//           },
//         };

//         try {
//           const accessToken = await getAccessToken();

//           const response = await fetch('https://fcm.googleapis.com/v1/projects/cybersafeguard-34bb3/messages:send', {
//             method: 'POST',
//             headers: {
//               'Authorization': `Bearer ${accessToken}`,
//               'Content-Type': 'application/json',
//             },
//             body: JSON.stringify(payload),
//           });

//           if (!response.ok) {
//             console.error("Error sending notification:", response.statusText);
//           } else {
//             console.log("Notification sent successfully!");
//           }
//         } catch (error) {
//           console.error("Error getting access token or sending notification:", error);
//         }
//       } else {
//         console.log("No FCM token for user.");
//       }
//     } else {
//       console.log("No user found with the given first name.");
//     }
//   });
