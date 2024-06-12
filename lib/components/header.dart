import 'package:flutter/material.dart';
import 'package:mairie_ipad/view/project_list.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  Header();

  @override
  Widget build(BuildContext context) {
    int nombreProjetsActifs = 10;

    return AppBar(
      title: Text(
        'Mairie Ales',
        style: TextStyle(color: Colors.white), // Titre en blanc
      ),
      backgroundColor: Colors.blueGrey,
      leading: IconButton(
        icon: Icon(Icons.home, color: Colors.black), // Utiliser l'icône Home
        onPressed: () {
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushNamed(context, '/');
          }
        },
      ),
      actions: [
        _appBarAction('Projets', () {
          // Vérifier si la route actuelle est déjà '/projects'
          if (ModalRoute.of(context)?.settings.name != '/projects') {
            Navigator.pushNamed(context, '/projects');
          }
        }, backgroundColor: Colors.orange, height: 35.0),
        _buildProjectsActiveButton(nombreProjetsActifs),
        _appBarAction('Sous projets', () {},
            backgroundColor: Colors.green, height: 35.0),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _appBarAction(String title, Function onPressed,
      {Color? backgroundColor, double? height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: TextButton(
          onPressed: () => onPressed(),
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsActiveButton(int count) {
    return Stack(
      children: [
        _appBarAction('Projets actifs', () {},
            backgroundColor: Colors.blue, height: 35.0),
        Positioned(
          left: 102, // Ajustement pour le centrage
          bottom: 18,
          child: Container(
            padding: EdgeInsets.all(2), // Réduction de la taille du padding
            decoration: BoxDecoration(
              color: Colors.blue[900],
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10), // Réduction de la taille de la police
            ),
          ),
        ),
      ],
    );
  }
}
