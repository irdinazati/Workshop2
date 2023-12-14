import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Constants/Constants.dart';
import '../../Services/DatabaseService.dart';
import '../../Widget/FeedContainer.dart';
import '../models/Feed.dart';
import '../models/UserModel.dart';
import 'CreateFeedScreen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _followingFeeds = [];
  bool _loading = false;

  get usersRef => null;

  buildTweets(Feed feed, UserModel author) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: FeedContainer(
        feed: feed,
        author: author,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  List<Widget> showFollowingFeeds(String currentUserId) {
    List<Widget> followingFeedsList = [];
    for (Feed feed in _followingFeeds) {
      followingFeedsList.add(FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(feed.authorId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            UserModel author = UserModel.fromDoc(snapshot.data!.data() as DocumentSnapshot<Object?>);
            return buildTweets(feed, author);
          } else {
            return SizedBox.shrink();
          }
        },
      ));
    }
    return followingFeedsList;
  }

  setupFollowingFeeds() async {
    setState(() {
      _loading = true;
    });
    List followingFeeds =
    await DatabaseServices.getHomeFeeds(widget.currentUserId);
    if (mounted) {
      setState(() {
        _followingFeeds = followingFeeds;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupFollowingFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Image.asset('https://blogger.googleusercontent.com/'
              'img/b/R29vZ2xl/AVvXsEgOadLGSaFjcyk35kQRILjs3dlfbe8Ssz'
              'IK9AIq33I8nyyw894pLxgzrf9EmLaWYtYFyV43zJBpipeVZX1DOfI'
              '7nlH742EKnd95En3aMFM8o_-Z04p5zv93LmikXj20rNnwMskq81pu'
              'cRJn449edtjugauXmy2CBi93CPc2gaJE6Bju'
              'qWD40XqUlGduJ5w/s320/11zon_cropped.png'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateFeedScreen(
                      currentUserId: widget.currentUserId,
                    )));
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          leading: Container(
            height: 40,
            child: Image.asset('assets/logo.png'),
          ),
          title: Text(
            'Home Screen',
            style: TextStyle(
              color: KTweeterColor,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => setupFollowingFeeds(),
          child: ListView(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              _loading ? LinearProgressIndicator() : SizedBox.shrink(),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 5),
                  Column(
                    children: _followingFeeds.isEmpty && _loading == false
                        ? [
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'There is No New Posts',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    ]
                        : showFollowingFeeds(widget.currentUserId),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}