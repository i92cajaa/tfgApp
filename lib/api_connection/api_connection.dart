class API {
  static const String hostConnect = "http://192.168.56.1/app";
  static const String loginUrl = "$hostConnect/login";
  static const String getCentersUrl = "$hostConnect/all-centers";
  
  static String getLessonsUrl(String center) {
    return "$hostConnect/lessons-by-center/$center";
  }

  static String getSchedulesUrl(String lesson) {
    return "$hostConnect/schedules-by-lesson/$lesson";
  }

  static String bookUrl(String client, String schedule) {
    return "$hostConnect/book/$client/$schedule";
  }

  static String getBookingsUrl(String client) {
    return "$hostConnect/bookings-by-client/$client";
  }
}