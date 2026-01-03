class Data {
  final String name;
  final String date;
  final String checkIn;
  final String checkOut;
  final String id;

  Data(this.name, this.date,
      {this.checkIn = "", this.checkOut = "", required this.id});
}
