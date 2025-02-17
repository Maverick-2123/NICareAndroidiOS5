import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nicare/pages/language_constants.dart';
import 'global.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestimonialCarousel extends StatefulWidget {

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {

  List<dynamic> allTestimonials = [];

  Future<void> fetchTestimonial() async {
    String apiUrl = global.url+'api/fetch-testimonial/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          allTestimonials = jsonResponse['data'];
        });
      } else {
        print("Error fetching testimonials");
        };
      } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  // final List<Map<String, String>> testimonials = [
  //   {
  //     'image': 'assets/sample_profile/profile1.jpg',
  //     'name': 'John Doe',
  //     'designation': 'Software Engineer',
  //     'message': 'This app has transformed the way I work. Highly recommend it!',
  //   },
  //   {
  //     'image': 'assets/sample_profile/profile2.jpg',
  //     'name': 'Jane Smith',
  //     'designation': 'Product Manager',
  //     'message': 'An amazing app with a user-friendly interface. Love it!',
  //   },
  //   {
  //     'image': 'assets/sample_profile/profile3.jpg',
  //     'name': 'Mike Johnson',
  //     'designation': 'Team Lead',
  //     'message': 'A game changer for our team’s productivity!',
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    fetchTestimonial();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      color: Color(0xffF0F8FF), // Background color for the testimonial section
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                translation(context).homepagetestimonial,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CarouselSlider(
            options: CarouselOptions(
              height: 300.0,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              aspectRatio: 2.0,
            ),
            items: allTestimonials.map((testimonial) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: testimonial['image_url'] != null
                    ? NetworkImage(testimonial['image_url'])
                          : const AssetImage('assets/default_profile.jpg')
                  as ImageProvider,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          testimonial['name']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          testimonial['designation']!,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            testimonial['message']!,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black87,
                              fontStyle: FontStyle.normal,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
