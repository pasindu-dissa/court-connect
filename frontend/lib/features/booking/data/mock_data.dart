enum SportType { badminton, basketball, tennis, football, swimming, cricket }

class CourtModel {
  final String id;
  final String name;
  final String address;
  final String image;
  final double rating;
  final int price;
  final String status;
  final double top;
  final double left;
  final SportType sportType; // Added to identify icon

  CourtModel({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.rating,
    required this.price,
    required this.status,
    required this.top,
    required this.left,
    required this.sportType,
  });
}

final List<CourtModel> mockCourts = [
  CourtModel(
    id: "c1",
    name: "Royal Badminton Arena",
    address: "Colombo 07, Cinnamon Gardens",
    image: "https://images.unsplash.com/photo-1626224583764-847890e058f5?q=80&w=800&auto=format&fit=crop", 
    rating: 4.9,
    price: 2500,
    status: "Available",
    top: 0.3, left: 0.2,
    sportType: SportType.badminton,
  ),
  CourtModel(
    id: "c2",
    name: "Urban Hoops Center",
    address: "Colombo 03, Kollupitiya",
    image: "https://images.unsplash.com/photo-1546519638-68e109498ee2?q=80&w=800&auto=format&fit=crop",
    rating: 4.5,
    price: 1200,
    status: "Busy",
    top: 0.5, left: 0.6,
    sportType: SportType.basketball,
  ),
  CourtModel(
    id: "c3",
    name: "City Futsal Club",
    address: "Colombo 04, Bambalapitiya",
    image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800&auto=format&fit=crop",
    rating: 4.7,
    price: 3000,
    status: "Closing Soon",
    top: 0.7, left: 0.3,
    sportType: SportType.football,
  ),
  CourtModel(
    id: "c4",
    name: "Blue Water Swimming",
    address: "Colombo 05, Havelock Town",
    image: "https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?q=80&w=800&auto=format&fit=crop",
    rating: 4.8,
    price: 800,
    status: "Available",
    top: 0.2, left: 0.7,
    sportType: SportType.swimming,
  ),
];