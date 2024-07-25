import 'package:flutter/material.dart';

class MenuLateral extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  MenuLateral({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo-sigesproc.png',
                    height: 135,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: List.generate(6, (index) => _crearItem(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearItem(int index) {
    IconData icon;
    String text;
    switch (index) {
      case 0:
        icon = Icons.home;
        text = 'Inicio';
        break;
      case 1:
        icon = Icons.construction;
        text = 'Proyectos';
        break;
      case 2:
        icon = Icons.local_shipping;
        text = 'Fletes';
        break;
      case 3:
        icon = Icons.request_quote;
        text = 'Cotización';
        break;
      case 4:
        icon = Icons.business;
        text = 'Bienes';
        break;
      case 5:
        icon = Icons.attach_money;
        text = 'Viáticos';
        break;
      default:
        icon = Icons.error;
        text = 'Error';
    }
    bool selected = index == selectedIndex;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFFFF0C6) : Colors.black,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.black : Color(0xFFFFF0C6)),
        title: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Color(0xFFFFF0C6),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
