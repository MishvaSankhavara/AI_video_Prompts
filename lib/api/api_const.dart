/// Centralized API configuration: base URL, auth token and endpoint paths.
class ApiConst {
  ApiConst._();

  // Base
  static const String baseUrl = 'https://ai-prompt.aivibecode.in/api/v1/ngd';
  static const String authToken =
      r'x.NF#f25G),Ew55J8HnwsXGQ}2j%N4F5[.DHyJkG4R$HP@;2LOF5kz!Ovex,X.X6)dr6s3fniU}o@3)zFVyNN$2Akx)2=t+qlEbk';

  // Endpoints
  static const String getAiVideoCategories = '/getAiVideoCategories';
  static const String getAiVideoByCategoryId = '/getAiVideoByCategoryId';
}
