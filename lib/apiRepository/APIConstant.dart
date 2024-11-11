class URLS {
  //BASE URL FOR APP
  static String BASE_URL = "https://hr.nativeway.lk";
  // static String BASE_URL = "https://nspl-odoo-team-emp-leave.odoo.com/";
  // static String BASE_URL12 = "https://nspl-odoo-team-employee-leave-staging-15490194.dev.odoo.com";

  static String LOGIN_USER = "$BASE_URL/api/auth/login";
  static String APPROVE_LEAVE = "$BASE_URL/api/approve_leave";
  static String LOGOUT_USER = "$BASE_URL/api/auth/logout";
  static String SIGNUP_USER = "$BASE_URL/api/auth/signup";
  static String DASHBOARD_FLAG = "$BASE_URL/api/mobile/dashboard";
  static String CHECK_IN = "$BASE_URL/api/mobile/check_in";
  static String CHECK_OUT = "$BASE_URL/api/mobile/check_out";
  static String TODAYS_ATTENDANCE_HISTORY = "$BASE_URL/api/today/attendance_history";
  static String ATTENDANCE_HISTORY = "$BASE_URL/api/attendance_history";
  static String GET_PROFILE_DATA = "$BASE_URL/api/get_profile_data";
  static String UPDATE_PROFILE = "$BASE_URL/api/update_profile";
  static String LEAVE_TYPE_LIST = "$BASE_URL/api/leave_type_list";
  static String LEAVE_HISTORY = "$BASE_URL/api/leave_history";
  static String SUBMIT_LEAVE = "$BASE_URL/api/submit_leave";
  static String VALIDATE_LEAVE = "$BASE_URL/api/validate_leave";
  static String REJECT_LEAVE = "$BASE_URL/api/reject_leave";
  static String CHANGE_LEAVE_TYPE = "$BASE_URL/api/change_leave_type";
}

class Params {
  static String PASSWORD = "password";
}

class ResponseKey {
  static String BODY = "body";
  static String result = "result";
  static String STATUS = "status";
  static String ISREGISTER = "isRegister";
  static String MESSAGE = "message";
  static String DATA = "data";
  static String TERMS = "terms";
}
