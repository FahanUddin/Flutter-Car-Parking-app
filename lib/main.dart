import 'dart:io';
import 'package:carparkapp_new/login_page.dart';
import 'package:carparkapp_new/model/car_class.dart';
import 'package:carparkapp_new/model/parking_class.dart';
import 'package:carparkapp_new/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:uuid/uuid.dart';
import 'circle_transition.dart';
import 'firebase_options.dart';
import 'login_controller.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'model/navigation_drawer.dart';
import 'model/order_class.dart';
import 'model/user_class.dart';
import 'widgets/car_detail_popup.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'id', 'name',
    importance: Importance.high, playSound: true);

late String deviceToken;

var locations = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((event) {
    (RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              color: Colors.amber,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            )));
      }
    };
  });

  runApp(const MyApp());
}

Future<void> getToken() async {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final token = await _fcm.getToken();
  deviceToken = token.toString();
  print("this is the token: $deviceToken ");

  User? user = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance
      .collection("users")
      .doc(user!.uid)
      .update({'token': deviceToken});
}

Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message ${message.data}");
  //await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      title: 'Car Parking',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
        ),
        primarySwatch: Colors.blueGrey,
      ),
      home: const Splash(), //MyHomePage(title: 'Car Parking'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(LoginController());
  late SharedPreferences sharedPreferences;

  void initState() {
    getLocations() async {
      setState(() {
        locations = [];
      });
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("locations").get();

      final allData = querySnapshot.docs
          .map((doc) =>
              ((doc.get('name')) + ("-") + (doc.get('address'))) as String)
          .toList();
      setState(() {
        locations = locations + allData;
      });

      print(locations);
    }

    getLocations();
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic("CarPark");
  }

  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> _marker = <MarkerId, Marker>{};

  Map<MarkerId, Marker> _origins = <MarkerId, Marker>{};
  Map<MarkerId, Marker> _destinations = <MarkerId, Marker>{};

  //Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // ignore: non_constant_identifier_names
  static final CameraPosition _UOL = CameraPosition(
    target: LatLng(52.6211, -1.1246),
    zoom: 17.4746,
  );

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      drawer: Container(
        width: 260,
        child: const Drawer(
          child: NavigationDrawerWidget(),
        ),
      ),
      extendBodyBehindAppBar: true,
      //backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        bottomOpacity: 0,
        backgroundColor: Colors.transparent, // status bar color
        actions: const [
          //unimplemented search button
          //disabled as it was not implemented
          /* Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              height: 50,
              width: 50,
              //color: Colors.blueGrey,
              child: FloatingActionButton(
                focusColor: Colors.grey.shade700,
                backgroundColor: Colors.grey.shade200,
                onPressed: () {
                  getLocations();
                },
                child: Icon(
                  Icons.search_rounded,
                  size: 30,
                ),
              ),
            ),
          ),*/
          //search button was here
        ],
        toolbarHeight: 65,
        iconTheme: const IconThemeData(
          size: 45,
          color: Colors.black,
        ),
      ),
      body: FireMap(),
    );
  }

  var locations = [
    "Choose a location",
  ];

  getLocations() async {
    setState(() {
      locations = [
        "Choose a location",
      ];
    });
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("locations").get();

    final allData = querySnapshot.docs
        .map((doc) =>
            ((doc.get('name')) + ("-") + (doc.get('address'))) as String)
        .toList();
    setState(() {
      locations = locations + allData;
    });

    print(locations);
  }

  Route _routelogin() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionDuration: const Duration(milliseconds: 1300),
        reverseTransitionDuration: const Duration(milliseconds: 1300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var screenSize = MediaQuery.of(context).size;
          var centerCircular =
              Offset(screenSize.width / 2, screenSize.height / 2);

          double beginRadius = 0.0;
          double endRadius = screenSize.height * 1.2;

          var radiusTween = Tween(begin: beginRadius, end: endRadius);
          var radiusTweenAnimation = animation.drive(radiusTween);

          return ClipPath(
            child: child,
            clipper: CircleTransition(
              radius: radiusTweenAnimation.value,
              center: centerCircular,
            ),
          );
        });
  }
}

class FireMap extends StatefulWidget {
  @override
  State createState() => FireMapState();
}

class FireMapState extends State<FireMap> {
  late String _mapStyle;
  final Location _location = Location();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //those bellow are temporary variables
  late String tmp_markerId = 'null';
  late String tmp_parking_spaceId = 'null';
  late String tmp_parking_spaceBay = 'null';
  late String tmp_markerLocation = 'null';
  late String tmp_markerLocationAddress = 'null';
  late double tmp_carParkPrice = 0.0;
  late double carParkPrice = 0.0;

  late double display_carParkPrice = 0.0;
/////
  late TimeOfDay _startbookingHour = TimeOfDay.now();
  bool startTimeSelected = false;

  late TimeOfDay _endbookingHour = TimeOfDay.now();
  bool endTimeSelected = false;

  var nowDate = DateFormat('yyyy').format(DateTime.now());

  late DateTime startDate;
  late DateTime endDate;

  var _startDate = DateTime.now();
  String formattedDate = "Pick Date";

  late DateTime startDate_TTD;
  bool dateSelected = false;
  late DateTime endDate_TTD;

  var bookinghour = 0;
  var bookinghour_inMinute = 0.0;

  var minute_to_hour = 0.0;
  /////

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _marker = <MarkerId, Marker>{};
  double bottombarPositionDefault = -230;
  double bottombarPositionVisible = 0;
  double bottombarPositionNotVisible = -230;

  static final CameraPosition _UOL = CameraPosition(
    target: LatLng(52.6211, -1.1246),
    zoom: 17.4746,
  );
  Location location = new Location();
  DateTime dateTime = DateTime.now();
  var uuid = Uuid();

  var bookingHour = 2;
  User? user = FirebaseAuth.instance.currentUser;

  var cars = [
    "Choose a car",
  ];

  var selectedCar = "Choose a car";

  final CollectionReference carsCollection =
      FirebaseFirestore.instance.collection('users');

  var locations = [
    "Choose a location",
  ];

  getLocations() async {
    setState(() {
      locations = [
        "Choose a location",
      ];
    });
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("locations").get();

    final allData = querySnapshot.docs
        .map((doc) =>
            ((doc.get('name')) + ("-") + (doc.get('address'))) as String)
        .toList();
    setState(() {
      locations = locations + allData;
    });

    print(locations);
  }

  getCar() async {
    setState(() {
      cars = [
        "Choose a car",
      ];
    });
    QuerySnapshot querySnapshot =
        await carsCollection.doc(user!.uid).collection("cars").get();

    final allData = querySnapshot.docs
        .map((doc) =>
            ((doc.get('carModel')) + ("-") + (doc.get('plateNo'))) as String)
        .toList();
    setState(() {
      cars = cars + allData;
    });

    print(cars);
  }

  setToDefault() {
    setState(() {
      startTimeSelected = false;
      endTimeSelected = false;
      dateSelected = false;
      _startbookingHour = TimeOfDay.now();

      _endbookingHour = TimeOfDay.now();

      nowDate = DateFormat('yyyy').format(DateTime.now());

      _startDate = DateTime.now();
      formattedDate = "Pick Date";

      startDate_TTD = DateTime.now();

      bookinghour = 0;
      bookinghour_inMinute = 0.0;

      minute_to_hour = 0.0;

      carParkPrice = 0.0;
    });
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude!, pos.latitude!),
      zoom: 17.0,
    ));
  }

  void initMarker(specify, specifyId) async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/pin.png",
    );
    final _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      icon: markerbitmap,
      onTap: () async {
        await getCar();
        setState(() {
          tmp_markerId = markerIdVal;
          tmp_markerLocation = specify['name'].toString();
          tmp_markerLocationAddress = specify['address'].toString();

          bottombarPositionDefault = bottombarPositionVisible;
        });
      },
      position: LatLng(
          specify['coordinate'].latitude, specify['coordinate'].longitude),
      infoWindow: InfoWindow(
          title: specify['name'],
          snippet: '£ ' + specify['price'].toString() + '/h'),
    ); //add on tap
    setState(() {
      _marker[markerId] = marker;
    });
  }

  getMarkerData() async {
    return firestore.collection('locations').get().then((value) => {
          if (value.docs.isNotEmpty)
            {
              for (int i = 0; i < value.docs.length; i++)
                {initMarker(value.docs[i].data(), value.docs[i].id)}
            }
        });
  }

  @override
  void initState() {
    getMarkerData();
    getToken();

    super.initState();

    rootBundle
        .loadString('assets/light.json')
        .then((string) => {_mapStyle = string});
  }

  @override
  build(context) {
    final _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    double searchBarbottombarPositionDefault = -1030;
    double searchBarbottombarPositionVisible =
        MediaQuery.of(context).size.height - 800;
    double searchBarbottombarPositionNotVisible = -330;

    double widgetPositionDefault = -1040;
    double widgetPositionVisible = 0;
    double widgetPositionNotVisible = -1030;

    void _currentLocation() async {
      final GoogleMapController controller = await _controller.future;
      LocationData currentLocation;
      var location = Location();
      try {
        currentLocation = await location.getLocation();
      } on Exception {
        currentLocation = LatLng(52.6211, -1.1246) as LocationData;
      }

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude!.toDouble(),
              currentLocation.longitude!.toDouble()),
          zoom: 17.0,
        ),
      ));
    }

    //double smartpadding = MediaQuery.of(context).size.height - 725;
    return Stack(
      children: [
        GoogleMap(
          markers: Set<Marker>.of(_marker.values),

          onMapCreated: (GoogleMapController controller) async {
            String style = await DefaultAssetBundle.of(context)
                .loadString('assets/light.json');
            controller.setMapStyle(style);
            _controller.complete(controller);
          },
          myLocationEnabled:
              true, // Add little blue dot for device location, requires permission from user
          initialCameraPosition: _UOL,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          onTap: (LatLng loc) {
            setState(() {
              bottombarPositionDefault = bottombarPositionNotVisible;
              setToDefault();
            });
          },
        ),

        Positioned(
          bottom: 65,
          right: 5,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.blueGrey,
            heroTag: "myLocation",
            onPressed: _currentLocation,
            label: Icon(Icons.location_on),
          ),
        ),
        //This contains the bottom bar and the booking overlay
        AnimatedPositioned(
            left: 0,
            right: 0,
            bottom: bottombarPositionDefault,
            height: 270,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 242, 242, 242),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset.zero)
                  ]),
              child: Container(
                  color: Color.fromARGB(255, 242, 242, 242),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Stack(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('locations')
                                .doc(tmp_markerId)
                                .collection('parking_spaces')
                                .where('inUse', isEqualTo: false)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong',
                                    textScaleFactor: 0.2);
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading", textScaleFactor: 0.2);
                              }

                              if (snapshot.data!.size == 0) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No parking spaces available in: ' +
                                        tmp_markerLocation,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                );
                              }
                              final data = snapshot.requireData;
                              return Container(
                                  margin: EdgeInsets.only(top: 40),
                                  //fai una pagina separata per testare list view
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        const Text(
                                          'Parking Spaces \n',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 18.0),
                                          child: ListView.builder(
                                              shrinkWrap: false,
                                              // physics: NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: data.size,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  //padding: const EdgeInsets.all(25),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 48.0),
                                                          child: Row(
                                                            children: <Widget>[
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(
                                                                            3)),
                                                                    primary: Colors
                                                                        .blueGrey,
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            30)),
                                                                onLongPress:
                                                                    () {
                                                                  //freeParking();
                                                                },
                                                                onPressed:
                                                                    () async {
                                                                  getToken();
                                                                  //await getCar();
                                                                  setState(() {
                                                                    dateTime =
                                                                        DateTime
                                                                            .now();
                                                                    tmp_parking_spaceId =
                                                                        data.docs[index]
                                                                            [
                                                                            'uid'];
                                                                    tmp_parking_spaceBay = data.docs[index]
                                                                            [
                                                                            'parkingNumber'] +
                                                                        data.docs[index]
                                                                            [
                                                                            'parkingLevel'];

                                                                    print(
                                                                        tmp_parking_spaceId);
                                                                    widgetPositionDefault =
                                                                        0;
                                                                  });

                                                                  //showWidget();

                                                                  Future<void>
                                                                      showInfoDialog(
                                                                          BuildContext
                                                                              context) async {
                                                                    return await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return Material(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    height: MediaQuery.of(context).size.height,
                                                                                    color: Colors.white,
                                                                                    padding: EdgeInsets.all(12.5),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Row(
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(9.0),
                                                                                              child: IconButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context);
                                                                                                  setToDefault();
                                                                                                },
                                                                                                icon: Icon(
                                                                                                  Icons.keyboard_backspace_outlined,
                                                                                                  color: Colors.black,
                                                                                                  size: 36,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(9.0),
                                                                                              child: Text(
                                                                                                'Reserve bay: ' '${data.docs[index]['parkingNumber'] + data.docs[index]['parkingLevel']}',
                                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 25),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Container(
                                                                                            padding: EdgeInsets.all(6.5),
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            height: MediaQuery.of(context).size.height,
                                                                                            decoration: BoxDecoration(
                                                                                              color: Colors.grey.shade300,
                                                                                              borderRadius: BorderRadius.circular(12),
                                                                                            ),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  height: 13,
                                                                                                ),
                                                                                                Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.indigoAccent,
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                  ),
                                                                                                  width: MediaQuery.of(context).size.width,
                                                                                                  //height: 100,
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      //address
                                                                                                      StreamBuilder<QuerySnapshot>(
                                                                                                          stream: FirebaseFirestore.instance.collection("locations").doc(tmp_markerId).collection("address").snapshots(),
                                                                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                                            if (snapshot.hasError) {
                                                                                                              return Text('Something went wrong', textScaleFactor: 1);
                                                                                                            }

                                                                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                                              return Text("Loading", textScaleFactor: 1);
                                                                                                            }
                                                                                                            if (snapshot.data!.size == 0) {
                                                                                                              return Text('No Locations data found', textScaleFactor: 1);
                                                                                                            }
                                                                                                            final data = snapshot.requireData;

                                                                                                            return Container(
                                                                                                              padding: EdgeInsets.only(left: 8),
                                                                                                              constraints: BoxConstraints(
                                                                                                                maxHeight: double.infinity,
                                                                                                              ),
                                                                                                              height: 80,
                                                                                                              alignment: Alignment.center,
                                                                                                              child: Stack(
                                                                                                                children: [
                                                                                                                  Container(
                                                                                                                    constraints: BoxConstraints(
                                                                                                                      maxHeight: double.infinity,
                                                                                                                    ),
                                                                                                                    child: ListView.builder(
                                                                                                                        itemCount: data.size,
                                                                                                                        itemBuilder: (context, index) {
                                                                                                                          String address = data.docs[index]['address'];

                                                                                                                          return Container(
                                                                                                                            padding: EdgeInsets.only(top: 20),
                                                                                                                            child: Row(
                                                                                                                              children: <Widget>[
                                                                                                                                Flexible(
                                                                                                                                  child: Text(
                                                                                                                                    'Address: ' + address,
                                                                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          );
                                                                                                                        }),
                                                                                                                  )
                                                                                                                ],
                                                                                                              ),
                                                                                                            );
                                                                                                          }),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 10,
                                                                                                ),
                                                                                                Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.lightBlueAccent,
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                  ),
                                                                                                  width: MediaQuery.of(context).size.width,
                                                                                                  //height: 100,
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      //address

                                                                                                      StreamBuilder<QuerySnapshot>(
                                                                                                          stream: FirebaseFirestore.instance.collection("locations").doc(tmp_markerId).collection("address").snapshots(),
                                                                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                                            if (snapshot.hasError) {
                                                                                                              return Text('Something went wrong', textScaleFactor: 1);
                                                                                                            }

                                                                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                                              return Text("Loading", textScaleFactor: 1);
                                                                                                            }
                                                                                                            if (snapshot.data!.size == 0) {
                                                                                                              return Text('No Locations data found', textScaleFactor: 1);
                                                                                                            }
                                                                                                            final data = snapshot.requireData;

                                                                                                            return Container(
                                                                                                              padding: EdgeInsets.only(left: 8),
                                                                                                              constraints: BoxConstraints(
                                                                                                                maxHeight: double.infinity,
                                                                                                              ),
                                                                                                              height: 68,
                                                                                                              alignment: Alignment.center,
                                                                                                              child: Stack(
                                                                                                                children: [
                                                                                                                  Container(
                                                                                                                    constraints: const BoxConstraints(
                                                                                                                      maxHeight: double.infinity,
                                                                                                                    ),
                                                                                                                    child: ListView.builder(
                                                                                                                        itemCount: data.size,
                                                                                                                        itemBuilder: (context, index) {
                                                                                                                          // int price = data.docs[index]['price'];

                                                                                                                          return Column(
                                                                                                                            //padding: EdgeInsets.only(top: 5),
                                                                                                                            children: [
                                                                                                                              Container(
                                                                                                                                margin: EdgeInsets.all(2),
                                                                                                                                padding: EdgeInsets.only(top: 5),
                                                                                                                                child: Flexible(
                                                                                                                                  child: Row(
                                                                                                                                    children: [
                                                                                                                                      const Text(
                                                                                                                                        "Total Duration:   ",
                                                                                                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                                                                      ),
                                                                                                                                      Padding(
                                                                                                                                        padding: EdgeInsets.only(left: 0),
                                                                                                                                        child: Text(
                                                                                                                                          minute_to_hour.toStringAsFixed(2) + "H",
                                                                                                                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ],
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Container(
                                                                                                                                margin: EdgeInsets.all(2),
                                                                                                                                padding: EdgeInsets.only(top: 8),
                                                                                                                                child: Flexible(
                                                                                                                                  child: Row(
                                                                                                                                    children: [
                                                                                                                                      const Text(
                                                                                                                                        "Price per hour:   ",
                                                                                                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                                                                      ),
                                                                                                                                      Padding(
                                                                                                                                        padding: EdgeInsets.only(left: 0),
                                                                                                                                        child: Text(
                                                                                                                                          '£ ' + data.docs[index]['price'].toString(),
                                                                                                                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                    ],
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          );
                                                                                                                        }),
                                                                                                                  )
                                                                                                                ],
                                                                                                              ),
                                                                                                            );
                                                                                                          })
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  height: 15,
                                                                                                ),
                                                                                                Container(
                                                                                                  padding: const EdgeInsets.all(15),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.blueGrey.shade400,
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                  ),
                                                                                                  //height: 145,
                                                                                                  width: MediaQuery.of(context).size.width,
                                                                                                  child: Expanded(
                                                                                                    child: Column(
                                                                                                      children: [
                                                                                                        const Text(
                                                                                                          "Select Date and Time",
                                                                                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        ElevatedButton(
                                                                                                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)), primary: Colors.indigoAccent, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                                                                                          onPressed: () async {
                                                                                                            await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 360))).then((date) {
                                                                                                              if (date == null) return;
                                                                                                              setState(() {
                                                                                                                _startDate = ((date));
                                                                                                                formattedDate = DateFormat('yyyy-MM-dd').format(_startDate);
                                                                                                                dateSelected = true;
                                                                                                              });
                                                                                                            });
                                                                                                            Navigator.pop(context);
                                                                                                            await showInfoDialog(context);
                                                                                                          },
                                                                                                          child: Text(
                                                                                                            formattedDate == null ? 'No date picked' : formattedDate,
                                                                                                            style: TextStyle(fontSize: 14),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Row(
                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                          children: [
                                                                                                            ElevatedButton(
                                                                                                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)), primary: Colors.indigoAccent, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                                                                                              onPressed: () async {
                                                                                                                final newTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                                                                                                if (newTime == null) return;
                                                                                                                setState(() {
                                                                                                                  _startbookingHour = newTime;
                                                                                                                  startTimeSelected = true;

                                                                                                                  print(_startbookingHour);
                                                                                                                });
                                                                                                                Navigator.pop(context);
                                                                                                                await showInfoDialog(context);
                                                                                                              },
                                                                                                              child: Text(
                                                                                                                _startbookingHour == null ? 'Time:${_startbookingHour.format(context)}' : _startbookingHour.format(context).toString(),
                                                                                                                style: const TextStyle(fontSize: 14),
                                                                                                              ),
                                                                                                            ),
                                                                                                            const Icon(Icons.arrow_forward_rounded),
                                                                                                            ElevatedButton(
                                                                                                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)), primary: Colors.indigoAccent, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                                                                                              onPressed: () async {
                                                                                                                final newTime = await showTimePicker(context: context, initialTime: _startbookingHour);
                                                                                                                if (newTime == null) return;
                                                                                                                await getParkingLocationPrice();
                                                                                                                setState(() {
                                                                                                                  _endbookingHour = newTime;

                                                                                                                  endTimeSelected = true;

                                                                                                                  final TTD_startbookingHour = DateTime(
                                                                                                                    _startDate.year,
                                                                                                                    _startDate.month,
                                                                                                                    _startDate.day,
                                                                                                                    _startbookingHour.hour,
                                                                                                                    _startbookingHour.minute,
                                                                                                                  );
                                                                                                                  final TTD_endbookingHour = DateTime(
                                                                                                                    _startDate.year,
                                                                                                                    _startDate.month,
                                                                                                                    _startDate.day,
                                                                                                                    _endbookingHour.hour,
                                                                                                                    _endbookingHour.minute,
                                                                                                                  );
                                                                                                                  startDate_TTD = TTD_startbookingHour;
                                                                                                                  endDate_TTD = TTD_endbookingHour;
                                                                                                                  print("end time" + TTD_endbookingHour.toString());
                                                                                                                  print("start time" + TTD_startbookingHour.toString());

                                                                                                                  final diff_bookinghour = TTD_endbookingHour.difference(TTD_startbookingHour).inHours;
                                                                                                                  final diff_bookingminute = TTD_endbookingHour.difference(TTD_startbookingHour).inMinutes;
                                                                                                                  bookinghour = diff_bookinghour;
                                                                                                                  bookinghour_inMinute = diff_bookingminute.toDouble();
                                                                                                                  minute_to_hour = bookinghour_inMinute / 60;
                                                                                                                  carParkPrice = tmp_carParkPrice * minute_to_hour;
                                                                                                                  print("amount" + minute_to_hour.toString());
                                                                                                                  print("total price" + carParkPrice.toString());
                                                                                                                  print("car park price" + tmp_carParkPrice.toString());
                                                                                                                });

                                                                                                                Navigator.pop(context);
                                                                                                                await calculatedCarParkPrice();
                                                                                                                await showInfoDialog(context);
                                                                                                              },
                                                                                                              child: Text(
                                                                                                                _endbookingHour.format(context).toString(),
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 10,
                                                                                                ),
                                                                                                Container(
                                                                                                  //padding: EdgeInsets.all(15),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.green.shade400,
                                                                                                    borderRadius: BorderRadius.circular(19),
                                                                                                  ),
                                                                                                  height: 100,
                                                                                                  width: MediaQuery.of(context).size.width,
                                                                                                  child: SizedBox(
                                                                                                    width: 5,
                                                                                                    height: 5,
                                                                                                    child: Scaffold(
                                                                                                      backgroundColor: Colors.transparent,
                                                                                                      body: Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                          color: Colors.green.shade400,
                                                                                                          borderRadius: BorderRadius.circular(12),
                                                                                                        ),
                                                                                                        padding: EdgeInsets.all(13),
                                                                                                        height: 200,
                                                                                                        child: SizedBox(
                                                                                                          child: DropdownButtonFormField<String>(
                                                                                                            decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black, width: 2))),
                                                                                                            isExpanded: false,
                                                                                                            hint: Text(
                                                                                                              "Choose a car",
                                                                                                              style: TextStyle(fontSize: 13),
                                                                                                            ),
                                                                                                            items: cars.toSet().map((car) => DropdownMenuItem(value: car, child: Text(car, style: TextStyle(fontSize: 13)))).toList(),
                                                                                                            value: selectedCar == "Choose a car" ? 'Choose a car' : selectedCar,
                                                                                                            onChanged: (car) {
                                                                                                              setState(() {
                                                                                                                selectedCar = car.toString();
                                                                                                              });
                                                                                                            },
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(height: 10),
                                                                                                Container(
                                                                                                    padding: EdgeInsets.all(15),
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.blue.shade400,
                                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                                    ),
                                                                                                    height: 45,
                                                                                                    width: MediaQuery.of(context).size.width,
                                                                                                    child: Expanded(
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            carParkPrice <= -1 ? 'Invalid time selected' : "Total Price: £" + (carParkPrice).toStringAsFixed(2),
                                                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    )),
                                                                                                Expanded(
                                                                                                  child: Align(
                                                                                                    alignment: Alignment.bottomCenter,
                                                                                                    child: ElevatedButton(
                                                                                                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), primary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
                                                                                                        onPressed: () async {
                                                                                                          if (_endbookingHour.hour <= _startbookingHour.hour) {
                                                                                                            showAlertDialog(context, "Select End Time", "Selected end time is before start time, select after start time.");
                                                                                                          } else if (_startbookingHour.hour < TimeOfDay.now().hour) {
                                                                                                            showAlertDialog(context, "Start time before current time", "Select start time again please.");
                                                                                                          } else if (startTimeSelected == false) {
                                                                                                            showAlertDialog(context, "Select Start Time", "Select start time please.");
                                                                                                          } else if (endTimeSelected == false) {
                                                                                                            showAlertDialog(context, "Select End Time", "Select end time please.");
                                                                                                          } else if (dateSelected == false) {
                                                                                                            showAlertDialog(context, "Select Date", "Select date please.");
                                                                                                          } else if (selectedCar == "Choose a car") {
                                                                                                            showAlertDialog(context, "Car not choosen", "Select a car.");
                                                                                                          } else {
                                                                                                            Navigator.pop(context);
                                                                                                            await checkBalance();
                                                                                                          }
                                                                                                        },
                                                                                                        child: Text("Book", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                          //

                                                                          //
                                                                        }); //delete
                                                                  } //delete

                                                                  await showInfoDialog(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  ' ${data.docs[index]['parkingNumber'] + data.docs[index]['parkingLevel']}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      ],
                    ),
                  )),
            )),
      ],
    );
  }

  setdefaultValue() {
    setState(() {
      carParkPrice = 0.0;
    });
  }

  searchView() {
    return Container(
      color: Colors.amber,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
  }

  Future<String> getParkingLocationInfo() async {
    final document = await FirebaseFirestore.instance
        .collection('locations')
        .doc(tmp_markerId)
        .get() /*.then((value) => tmp_markerLocation = value["name"])*/;
    return tmp_markerLocation = document["name"];
  }

  getParkingLocationPrice() async {
    final document = await FirebaseFirestore.instance
        .collection('locations')
        .doc(tmp_markerId)
        .get();
    setState(() {
      tmp_carParkPrice = (document["price"] as num).toDouble();
    });

    return [
      print("fetched location price, now calculating car park price" +
          tmp_carParkPrice.toString() +
          " Car park price is: " +
          carParkPrice.toString()),
      //calculatedCarParkPrice()
    ];
  }

  testCalculation() {
    //getParkingLocationPrice();
    print("Minute to hour var: " + minute_to_hour.toString());
    print("Car park price: " + tmp_carParkPrice.toString());
    carParkPrice = tmp_carParkPrice * minute_to_hour;
    print("calculated car price: " + carParkPrice.toString());
  }

  calculatedCarParkPrice() {
    print("booking hours: " + bookingHour.toString());
    carParkPrice = tmp_carParkPrice * minute_to_hour;
    print("calculated car price: " + carParkPrice.toString());
    setState(() {
      if (minute_to_hour >= 0) {
        display_carParkPrice = tmp_carParkPrice * minute_to_hour;
      } else {
        display_carParkPrice = 0;
      }
    });
    return carParkPrice;
  }

  checkParkingState() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await firebaseFirestore
        .collection('locations')
        .doc(tmp_markerId)
        .collection('parking_spaces')
        .doc(tmp_parking_spaceId)
        .get()
        .then((document) {
      if (document.data()!['inUse'] == true) {
        showSnackBar(
            context, 'Parking is already reserved choose another space');
      } else {
        changeUseState();
        //getParkingLocationInfo();
        bookingReport();
      }
    });
  }

  bookingReport() async {
    getParkingLocationInfo();

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    OrderClass orderClass = OrderClass();
    ParkingSpace parkingSpace = ParkingSpace();

    orderClass.userUid = user!.uid;
    orderClass.uid = uuid.v4();
    orderClass.duration = bookingHour.toString();
    orderClass.parkingLocation = tmp_markerLocation;
    orderClass.parkingBay = tmp_parking_spaceBay;
    orderClass.parkingId = tmp_markerId;
    orderClass.spaceId = tmp_parking_spaceId;
    orderClass.startDate = startDate_TTD;
    orderClass.endDate = endDate_TTD;
    orderClass.carModel = selectedCar.toString();
    orderClass.parkPrice = carParkPrice;
    orderClass.completed = false;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .collection("orders")
        .doc()
        .set(orderClass.toMap());
    setdefaultValue();
    setToDefault();
  }

  changeUseState() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await firebaseFirestore
        .collection('locations')
        .doc(tmp_markerId)
        .collection('parking_spaces')
        .doc(tmp_parking_spaceId)
        .update({'inUse': true});
  }

  freeParking() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await firebaseFirestore
        .collection('locations')
        .doc(tmp_markerId)
        .collection('parking_spaces')
        .doc(tmp_parking_spaceId)
        .get()
        .then((document) {
      if (document.data()!['inUse'] == true) {
        firebaseFirestore
            .collection('locations')
            .doc(tmp_markerId)
            .collection('parking_spaces')
            .doc(tmp_parking_spaceId)
            .update({'inUse': false});
        showSnackBar(context, 'Parking has been cleared');
      } else {
        changeUseState();
        showSnackBar(context, 'Parking is already free');
      }
    });
    //showSnackBar(context, 'Parking has been cleared');
  }

  checkBalance() async {
    await getParkingLocationPrice();
    //carParkPrice = tmp_carParkPrice * bookingHour;
    print("location price " + tmp_carParkPrice.toString());
    final _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await firebaseFirestore
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((document) {
      if (document.data()!['money'] >= carParkPrice) {
        firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .update({'money': FieldValue.increment(-carParkPrice)});

        print("car price" + carParkPrice.toString()); // double to int error
        showSnackBar(context, 'Parking has been booked');
        //setToDefault();
        checkParkingState();
      } else {
        print("car park price" + carParkPrice.toString());
        showSnackBar(context, 'Not enough Balance, please top up');
      }
    });
  }

  void _mylocation() async {
    //final GoogleMapController controller = await _controller.future;
    // var pos = await location.getLocation();
    _location.onLocationChanged.listen((l) {
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(l.latitude!, l.longitude!),
        ),
      );
    });
  }

  showAlertDialog(BuildContext context, String errorType, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(errorType),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 1000,
      duration: Duration(milliseconds: 1250),
      backgroundColor: Colors.black,
      content: Text(
        msg,
        style: TextStyle(
            fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ));
  }
}
