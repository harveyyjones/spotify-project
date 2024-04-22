import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(direction: Axis.vertical, children: [
        const SizedBox(
          height: 6,
        ),
        Expanded(
          // Change the children to stream builder if neccesary
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(2),
                    elevation: 20,
                    child: GestureDetector(
                      onTap: () {
                        // ACTION HERE
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: NetworkImage("https://picsum.photos/200/300"),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ]),
    );
  }
}
