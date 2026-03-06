/// Article model for example 3.
class ArticleModel {
  ArticleModel({this.id, this.title, this.content});

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
      };

  final String? id;
  final String? title;
  final String? content;
}

/// Request body for @Body() class model (must implement toJson).
class CreateArticleRequest {
  CreateArticleRequest({this.title, this.content});
  final String? title;
  final String? content;
  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
      };
}

/// Update request body for @Body() class model (must implement toJson).
class UpdateArticleRequest {
  UpdateArticleRequest({this.id, this.title, this.content});
  final String? id;
  final String? title;
  final String? content;
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
      };
}
