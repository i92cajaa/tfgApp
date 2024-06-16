class API {
  static const String hostConnect = "http://192.168.1.173/app";
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

  static String getBookingsScheduleIdUrl(String client) {
    return "$hostConnect/bookings-schedules-id-by-client/$client";
  }

  static String getBookingsUrl(String client) {
    return "$hostConnect/bookings-by-client/$client";
  }

  static String cancelBookingUrl(String client, String schedule) {
    return "$hostConnect/cancel-booking/$client/$schedule";
  }
}