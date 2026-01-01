class data {
  final String name;
  final String date;
  String checkIn;
  String checkOut;

  data(
      this.name,
      this.date, {
        this.checkIn = "",
        this.checkOut = "",
      });
}
