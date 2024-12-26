import 'package:flutter/material.dart';

class _TaskInputField extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
   return const TextField( 
      decoration: InputDecoration(
         labelText: 'New Task', 
         border: OutlineInputBorder(),
       ), 
     );
  }

}
