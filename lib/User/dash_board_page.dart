import 'package:flutter/material.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});

  @override
  State<UserDashBoard> createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/Recycling_Bin_Colours.png',
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Smart Recycling Bins: Revolutionizing Waste Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(
                    'Educating Users on the Importance of Recycling',
                    'assets/images/blogImag3.jpeg',
                    'Recycling is a critical aspect of environmental conservation, and with the advent of smart technologies, it has become more accessible and efficient than ever. By utilizing smart recycling bins, individuals can contribute significantly to reducing waste and preserving natural resources. These bins simplify the recycling process, making it easier for everyone to participate and make a positive environmental impact.',
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    'Smart Waste Collection Systems',
                    'assets/images/blogImag1.jpg',
                    'Smart recycling bins are transforming waste management through the use of advanced sensors and IoT technology. These systems detect the fill level of bins, allowing for optimized collection schedules and reducing unnecessary trips by waste collection vehicles. This not only saves time and resources but also minimizes carbon emissions.',
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    'Integrated IoT Platform for Waste Management',
                    'assets/images/blogImag2.png',
                    'The integration of IoT modules in waste bins and a centralized cloud platform enables real-time monitoring and data analysis. Users can access this information through dedicated mobile apps, providing insights into waste generation patterns and encouraging more efficient recycling practices. This connectivity enhances the overall efficiency of waste management systems.',
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    'Enhanced User Engagement and Rewards',
                    'assets/images/reward.png',
                    'Smart recycling bins not only facilitate waste disposal but also engage users through interactive features. By participating in this project, individuals can track their recycling activities, earn rewards, and stay informed about the environmental impact of their actions. This engagement fosters a culture of recycling and environmental stewardship within communities.',
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    'Scalability and Global Implementation',
                    'assets/images/blogImag4.jpeg',
                    'Cities around the world are adopting smart recycling solutions to enhance their sustainability efforts. These systems are scalable and can be customized to meet the specific needs of different urban environments. By implementing smart waste management, municipalities can improve resource efficiency, reduce landfill usage, and promote a greener future.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String title, String imagePath, String description,
      {BoxFit fit = BoxFit.cover}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: fit,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
