/// 案例3 用：文章模型。
class ArticleModel {
  ArticleModel({this.id, this.title, this.content});

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
    );
  }

  final String? id;
  final String? title;
  final String? content;
}
