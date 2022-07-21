import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/UpdateLocation.dart';
import 'package:hookup4u/Screens/auth/login.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/models/user_model.dart' as userD;
import 'package:hookup4u/util/color.dart';
import 'package:share/share.dart';
import 'UpdateNumber.dart';
import 'package:easy_localization/easy_localization.dart';

class Settings extends StatefulWidget {
  final userD.User currentUser;
  final bool isPurchased;
  final Map items;
  Settings(this.currentUser, this.isPurchased, this.items);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> changeValues = {};

  late RangeValues ageRange;
  var _showMe;
  late int distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Ads _ads = new Ads();
  // late BannerAd _ad;
  final BannerAd myBanner = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  late AdWidget adWidget;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final AdSize adSize = AdSize(height: 300, width: 50);
  @override
  void dispose() {
    // _ads.disable(_ad);
    myBanner.dispose();
    // _ad?.dispose();
    super.dispose();

    if (changeValues.length > 0) {
      updateData();
    }
  }

  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );
  Future updateData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set(changeValues, SetOptions(merge: true));
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  late int freeR;
  late int paidR;

  @override
  void initState() {
    // _ad = _ads.myBanner();
    adWidget = AdWidget(ad: myBanner);

    super.initState();
    myBanner.load();
    //  _ad
    // ..load()
    // ..show();
    freeR = widget.items['free_radius'] != null
        ? int.parse(widget.items['free_radius'])
        : 400;
    paidR = widget.items['paid_radius'] != null
        ? int.parse(widget.items['paid_radius'])
        : 400;
    setState(() {
      if (!widget.isPurchased && widget.currentUser.maxDistance! > freeR) {
        widget.currentUser.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (widget.isPurchased &&
          widget.currentUser.maxDistance! >= paidR) {
        widget.currentUser.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser.showGender;
      distance = widget.currentUser.maxDistance!.round();
      ageRange = RangeValues(double.parse(widget.currentUser.ageRange!['min']),
          (double.parse(widget.currentUser.ageRange!['max'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
          title: Text(
            "Settings".tr().toString(),
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: primaryColor),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Account settings".tr().toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                ),
                ListTile(
                  title: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Phone Number".tr().toString()),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              widget.currentUser.phoneNumber != null
                                  ? "${widget.currentUser.phoneNumber}"
                                  : "Verify Now".tr().toString(),
                              style: TextStyle(color: secondryColor),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: secondryColor,
                            size: 15,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    UpdateNumber(widget.currentUser)));
                        //      _ads.disable(_ad);
                      },
                    ),
                  )),
                  subtitle: Text("Verify a phone number to secure your account"
                      .tr()
                      .toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Discovery settings".tr().toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: ExpansionTile(
                      key: UniqueKey(),
                      leading: Text(
                        "Current location : ".tr().toString(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      title: Text(
                        widget.currentUser.address!,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 25,
                              ),
                              InkWell(
                                child: Text(
                                  "Change location".tr().toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  var address = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateLocation()));
                                  print(address);
                                  if (address != null) {
                                    _updateAddress(address);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                  ),
                  child: Text(
                    "Change your location to see members in other city"
                        .tr()
                        .toString(),
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Show me".tr().toString(),
                            style: TextStyle(
                                fontSize: 18,
                                color: primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          ListTile(
                            title: DropdownButton(
                              iconEnabledColor: primaryColor,
                              iconDisabledColor: secondryColor,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  child: Text("Man".tr().toString()),
                                  value: "man",
                                ),
                                DropdownMenuItem(
                                    child: Text("Woman".tr().toString()),
                                    value: "woman"),
                                DropdownMenuItem(
                                    child: Text("Everyone".tr().toString()),
                                    value: "everyone"),
                              ],
                              onChanged: (val) {
                                changeValues.addAll({
                                  'showGender': val,
                                });
                                setState(() {
                                  _showMe = val;
                                });
                              },
                              value: _showMe,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Maximum distance".tr().toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "$distance Km.",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Slider(
                            value: distance.toDouble(),
                            inactiveColor: secondryColor,
                            min: 1.0,
                            max: widget.isPurchased
                                ? paidR.toDouble()
                                : freeR.toDouble(),
                            activeColor: primaryColor,
                            onChanged: (val) {
                              changeValues
                                  .addAll({'maximum_distance': val.round()});
                              setState(() {
                                distance = val.round();
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Age range".tr().toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${ageRange.start.round()}-${ageRange.end.round()}",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: RangeSlider(
                            inactiveColor: secondryColor,
                            values: ageRange,
                            min: 18.0,
                            max: 100.0,
                            divisions: 25,
                            activeColor: primaryColor,
                            labels: RangeLabels('${ageRange.start.round()}',
                                '${ageRange.end.round()}'),
                            onChanged: (val) {
                              changeValues.addAll({
                                'age_range': {
                                  'min': '${val.start.truncate()}',
                                  'max': '${val.end.truncate()}'
                                }
                              });
                              setState(() {
                                ageRange = val;
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "App settings".tr().toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notifications".tr().toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Push notifications".tr().toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Language')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            // child: Text('Lanuage not Found'),
                            );
                      }
                      return Column(
                        children: snapshot.data!.docs.map((document) {
                          if (document['spanish'] == true &&
                              document['english'] == true) {
                            return ListTile(
                              subtitle: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          "Change Language".tr().toString(),
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: primaryColor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            FlatButton(
                                              child: Text(
                                                "English".tr().toString(),
                                                style: TextStyle(
                                                    color: Colors.pink),
                                              ),
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Change Language"
                                                              .tr()
                                                              .toString()),
                                                      content: Text(
                                                          'Do you want to change the language to English?'
                                                              .tr()
                                                              .toString()),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false),
                                                          child: Text('No'
                                                              .tr()
                                                              .toString()),
                                                        ),
                                                        FlatButton(
                                                          onPressed: () {
                                                            EasyLocalization.of(
                                                                    context)!
                                                                .setLocale(
                                                                    Locale('en',
                                                                        'US'));
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        Tabbar(
                                                                            null,
                                                                            false)));
                                                          },
                                                          child: Text('Yes'
                                                              .tr()
                                                              .toString()),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            FlatButton(
                                              child: Text(
                                                "Spanish".tr().toString(),
                                                style: TextStyle(
                                                    color: Colors.pink),
                                              ),
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Change Language"
                                                              .tr()
                                                              .toString()),
                                                      content: Text(
                                                          'Do you want to change the language to Spanish?'
                                                              .tr()
                                                              .toString()),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false),
                                                          child: Text('No'
                                                              .tr()
                                                              .toString()),
                                                        ),
                                                        FlatButton(
                                                          onPressed: () {
                                                            EasyLocalization.of(
                                                                    context)!
                                                                .setLocale(
                                                                    Locale('es',
                                                                        'ES'));
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        Tabbar(
                                                                            null,
                                                                            false)));
                                                            //                _ads.disable(_ad);
                                                          },
                                                          child: Text('Yes'
                                                              .tr()
                                                              .toString()),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Text('');
                          }
                        }).toList(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Invite your friends".tr().toString(),
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Share.share(
                          'check out my website https://deligence.com', //Replace with your dynamic link and msg for invite users
                          subject: 'Look what I made!'.tr().toString());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Logout".tr().toString(),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Logout'.tr().toString()),
                            content: Text('Do you want to logout your account?'
                                .tr()
                                .toString()),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No'.tr().toString()),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  await _auth.signOut().whenComplete(() {
                                    print(
                                        '---------------------delete--------------');
                                    try {
                                      _firebaseMessaging
                                          .deleteToken()
                                          .then((value) {
                                        print(
                                            '---------------------deletedfdf--------------');
                                      });
                                    } catch (e) {
                                      print('-----------------$e');
                                    }

                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  });
                                  //           _ads.disable(_ad);
                                },
                                child: Text('Yes'.tr().toString()),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Delete Account".tr().toString(),
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Account'.tr().toString()),
                            content: Text('Do you want to delete your account?'
                                .tr()
                                .toString()),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No'.tr().toString()),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  final User user = await _auth.currentUser!;
                                  //.then((FirebaseUser user) {
                                  //return user;
                                  //});
                                  await _deleteUser(user).then((_) async {
                                    await _auth.signOut().whenComplete(() {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => Login()),
                                      );
                                    });
                                    //         _ads.disable(_ad);
                                  });
                                },
                                child: Text('Yes'.tr().toString()),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Container(
                          height: 50,
                          width: 100,
                          child: Image.asset(
                            "asset/hookup4u-Logo-BP.png",
                            fit: BoxFit.contain,
                          )),
                    )),
                SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateAddress(Map _address) {
    showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .4,
            child: Column(
              children: <Widget>[
                Material(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'New address:'.tr().toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.black26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    subtitle: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _address['PlaceName'] ?? '',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.white,
                  child: Text(
                    "Confirm".tr().toString(),
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc('${widget.currentUser.id}')
                        .update({
                          'location': {
                            'latitude': _address['latitude'],
                            'longitude': _address['longitude'],
                            'address': _address['PlaceName']
                          },
                        })
                        .whenComplete(() => showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) {
                              Future.delayed(Duration(seconds: 3), () {
                                setState(() {
                                  widget.currentUser.address =
                                      _address['PlaceName'];
                                });

                                Navigator.pop(context);
                              });
                              return Center(
                                  child: Container(
                                      width: 160.0,
                                      height: 120.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            "asset/auth/verified.jpg",
                                            height: 60,
                                            color: primaryColor,
                                            colorBlendMode: BlendMode.color,
                                          ),
                                          Text(
                                            "location\nchanged".tr().toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        ],
                                      )));
                            }))
                        .catchError((e) {
                          print(e);
                        });

                    // .then((_) {
                    //   Navigator.pop(context);
                    // });
                  },
                )
              ],
            ),
          );
        });
  }

  Future _deleteUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).delete();
  }
}
