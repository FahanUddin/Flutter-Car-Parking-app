const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().functions);
const database = admin.firestore();


exports.clearParking = functions.pubsub.schedule("* * * * *")
    .onRun((snap, context) =>{
      return database.collection("users")
          .get().then(
              (query) =>{
                query.forEach((doc) =>{
                  const uid = doc.data().uid;
                  console.log("userID: "+uid);
                  return database.collection("users").doc(uid)
                      .collection("orders").where("completed", "==", false)
                      .get().then(
                          (orderquery) => {
                            orderquery.forEach((doc) =>{
                              const parkingUid = doc.data().parkingId;
                              console.log("ParkingUid: "+parkingUid);
                              const spaceId = doc.data().spaceId;
                              console.log("SpaceId: "+spaceId);
                              const startDate = doc.data().startDate
                                  .toDate().toJSON();
                              const endDate = doc.data().endDate.
                                  toDate().toJSON();
                              //
                              console.log("start time: "+startDate);
                              console.log("end time: "+endDate);
                              //
                              const currentTime = new Date().toJSON();
                              console.log("current time:"+ currentTime);
                              const utc1 = new Date(endDate);
                              const utc2 = new Date(currentTime);
                              console.log("end time in UTC: "+ utc1);
                              console.log("current time in UTC: "+utc2);
                              if (utc1 <= utc2) {
                                console.log("endTime exceeds current time");
                                const itemDocRef = admin.firestore()
                                    .collection("locations")
                                    .doc(parkingUid)
                                    .collection("parking_spaces").doc(spaceId);
                                const orderdocRef = admin.firestore()
                                    .collection("users")
                                    .doc(uid)
                                    .collection("orders")
                                    .doc(doc.id);
                                return itemDocRef.update({"inUse": false}),
                                orderdocRef.update({"completed": true});
                              }
                            });
                          }
                      );
                });
              }
          );
    });


exports.sendNotification = functions.pubsub.schedule("* * * * *")
    .onRun( (snap, context) =>{
      return database.collection("users")
          .where("money", "<=", 10).get().then((query) =>{
            query.forEach((snap) =>{
              if (snap.empty) {
                console.log("Snapshot empty");
                return;
              }
              const token = snap.data().token;
              const uid = snap.data().uid;
              const username = snap.data().firstName;
              console.log(token);
              console.log(uid);

              const payload= {
                notification: {title: "Low Balance",
                  body: "Hey "+ username+", \n"+
                  "your balance is low please top up", sound: "default"},
                data: {click_action: "FLUTTER_NOTIFICATION_CLICK",
                  message: " Push Message"},
              };
              try {
                admin.messaging().sendToDevice(token, payload);
                console.log("Successful Notification sent");
              } catch (err) {
                console.log("There was an error");
              }
            }
            );
          });
    });
