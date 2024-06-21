import 'package:flutter/material.dart';
import 'package:music/screens/favorite.dart';
import 'package:music/screens/gallery.dart';
import 'package:music/widgets/verticalList.dart';

import '../screens/home.dart';
import '../screens/profile.dart';
import '../screens/search.dart';
class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Hom',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_add_check),
          label: 'Downloaded',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            manager.dataFavorite = manager.getFavoriteList();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerticalList(
                        name: "Favorites",
                        data: manager.dataFavorite,
                        location: "favorite")));
            break;
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Search()));
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Home()));
            break;
          case 3:
            manager.dataLocal = manager.getPlaylistFromFolder();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerticalList(
                        name: "Download",
                        data: manager.dataLocal,
                        location: "download")));
            break;
          case 4:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Profile()));
            break;
        }
      },
    );
  }
}
