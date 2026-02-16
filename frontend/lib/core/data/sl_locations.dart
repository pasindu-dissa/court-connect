class SLLocations {
  static const Map<String, List<String>> districtCities = {
    "Colombo": ["Colombo 1-15", "Dehiwala", "Moratuwa", "Kotte", "Battaramulla", "Nugegoda", "Maharagama", "Homagama", "Avissawella"],
    "Gampaha": ["Gampaha", "Negombo", "Wattala", "Ja-Ela", "Kelaniya", "Kiribathgoda", "Minuwangoda", "Divulapitiya"],
    "Kalutara": ["Kalutara", "Panadura", "Horana", "Beruwala", "Aluthgama", "Matugama"],
    "Kandy": ["Kandy", "Peradeniya", "Katugastota", "Gampola", "Nawalapitiya"],
    "Matale": ["Matale", "Dambulla", "Sigiriya"],
    "Nuwara Eliya": ["Nuwara Eliya", "Hatton", "Talawakele"],
    "Galle": ["Galle", "Ambalangoda", "Hikkaduwa", "Karapitiya"],
    "Matara": ["Matara", "Weligama", "Akuressa"],
    "Hambantota": ["Hambantota", "Tangalle", "Tissamaharama"],
    "Jaffna": ["Jaffna", "Chavakachcheri", "Point Pedro"],
    "Kilinochchi": ["Kilinochchi"],
    "Mannar": ["Mannar"],
    "Vavuniya": ["Vavuniya"],
    "Mullaitivu": ["Mullaitivu"],
    "Batticaloa": ["Batticaloa", "Kattankudy"],
    "Ampara": ["Ampara", "Kalmunai", "Sainthamaruthu"],
    "Trincomalee": ["Trincomalee", "Kinniya"],
    "Kurunegala": ["Kurunegala", "Kuliyapitiya", "Pannala"],
    "Puttalam": ["Puttalam", "Chilaw", "Wennappuwa"],
    "Anuradhapura": ["Anuradhapura", "Kekirawa"],
    "Polonnaruwa": ["Polonnaruwa", "Kaduruwela"],
    "Badulla": ["Badulla", "Bandarawela", "Haputale", "Mahiyanganaya"],
    "Monaragala": ["Monaragala", "Wellawaya", "Buttala"],
    "Ratnapura": ["Ratnapura", "Embilipitiya", "Balangoda"],
    "Kegalle": ["Kegalle", "Mawanella", "Warakapola"],
  };

  static List<String> get districts => districtCities.keys.toList();
}