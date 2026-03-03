import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

void main() {
  group('NetRequest', () {
    test('defaultClientKey is "default"', () {
      expect(NetRequest.defaultClientKey, equals('default'));
    });

    test('options getter returns value after set', () {
      const opts = NetOptions(baseUrl: 'https://example.com');
      NetRequest.options = opts;
      expect(NetRequest.options, same(opts));
    });
  });

  group('NetOptions', () {
    test('const constructor and default timeouts', () {
      const o = NetOptions(baseUrl: 'https://api.test');
      expect(o.baseUrl, 'https://api.test');
      expect(o.connectTimeout, const Duration(seconds: 60));
      expect(o.receiveTimeout, const Duration(seconds: 60));
      expect(o.sendTimeout, const Duration(seconds: 60));
      expect(o.interceptors, isNull);
    });

    test('custom timeouts and interceptors', () {
      final o = NetOptions(
        baseUrl: 'https://a.co',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 5),
        interceptors: [LogInterceptor()],
      );
      expect(o.connectTimeout, const Duration(seconds: 10));
      expect(o.receiveTimeout, const Duration(seconds: 20));
      expect(o.sendTimeout, const Duration(seconds: 5));
      expect(o.interceptors!.length, 1);
    });
  });

  group('Annotations', () {
    test('NetApi default and custom', () {
      const a = NetApi();
      expect(a.client, isNull);
      expect(a.responseType, 'BaseResponse');
      expect(a.unwrapSuccess, isTrue);

      const b = NetApi(client: 'upload', responseType: 'CustomResp', unwrapSuccess: false);
      expect(b.client, 'upload');
      expect(b.responseType, 'CustomResp');
      expect(b.unwrapSuccess, isFalse);
    });

    test('Http method annotations', () {
      expect(const Get('/x').path, '/x');
      expect(const Get('/y', contentType: ContentType.formData).contentType, ContentType.formData);
      expect(const Post('/p').path, '/p');
      expect(const Put('/u').path, '/u');
      expect(const Delete('/d').path, '/d');
    });

    test('Body, Query, QueryKey', () {
      expect(const Body(), isNotNull);
      expect(const Query(), isNotNull);
      expect(const QueryKey('id').name, 'id');
    });

    test('Header, Path', () {
      expect(const Header('Authorization').name, 'Authorization');
      expect(const Path('id').name, 'id');
    });

    test('DataPath, Part, StreamResponse', () {
      expect(const DataPath('result').path, 'result');
      expect(const Part('file').name, 'file');
      expect(const StreamResponse(), isNotNull);
    });
  });

  group('HttpMethod', () {
    test('enum values and string', () {
      expect(HttpMethod.get.string, 'GET');
      expect(HttpMethod.post.string, 'POST');
      expect(HttpMethod.put.string, 'PUT');
      expect(HttpMethod.delete.string, 'DELETE');
    });
  });

  group('ContentType', () {
    test('toStringType', () {
      expect(ContentType.json.toStringType(), 'application/json');
      expect(ContentType.formData.toStringType(), 'multipart/form-data');
      expect(ContentType.xWwwFormUrlencoded.toStringType(), 'application/x-www-form-urlencoded');
    });
  });

  group('ApiError', () {
    test('constructor and toString', () {
      final e = ApiError(
        kind: ApiErrorKind.networkFailure,
        code: 500,
        message: 'fail',
        data: {'k': 'v'},
        cause: Exception('inner'),
      );
      expect(e.kind, ApiErrorKind.networkFailure);
      expect(e.code, 500);
      expect(e.message, 'fail');
      expect(e.data, {'k': 'v'});
      expect(e.cause, isNotNull);
      expect(e.toString(), contains('ApiError'));
      expect(e.toString(), contains('networkFailure'));
    });

    test('fromDioException cancel', () {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.cancel,
      );
      final e = ApiError.fromDioException(dioEx);
      expect(e.kind, ApiErrorKind.cancelled);
      expect(e.cause, dioEx);
    });

    test('fromDioException non-cancel', () {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final e = ApiError.fromDioException(dioEx);
      expect(e.kind, ApiErrorKind.networkFailure);
    });

    test('businessReject', () {
      final e = ApiError.businessReject(code: 1001, message: 'denied', data: null);
      expect(e.kind, ApiErrorKind.businessReject);
      expect(e.code, 1001);
      expect(e.message, 'denied');
    });
  });

  group('BaseResponse', () {
    test('isSuccess when code == BusinessCode.success', () {
      final r = BaseResponse<int>(code: BusinessCode.success, msg: 'ok', data: 1);
      expect(r.isSuccess, isTrue);
      expect(r.data, 1);
    });

    test('isSuccess when code != success', () {
      final r = BaseResponse<int>(code: 1, msg: 'err', data: null);
      expect(r.isSuccess, isFalse);
    });

    test('fromJson with dataParser', () {
      final r = BaseResponse<String>.fromJson(
        {'code': 0, 'msg': 'ok', 'data': 'hello'},
        dataParser: (json) => json as String,
      );
      expect(r.code, 0);
      expect(r.msg, 'ok');
      expect(r.data, 'hello');
      expect(r.isSuccess, isTrue);
    });

    test('fromJson msg fallback to message', () {
      final r = BaseResponse<dynamic>.fromJson(
        {'code': 0, 'message': 'done', 'data': null},
      );
      expect(r.msg, 'done');
    });

    test('fromJson total default and numeric', () {
      final r = BaseResponse<dynamic>.fromJson(
        {'code': 0, 'msg': '', 'data': null, 'total': 10},
      );
      expect(r.total, 10);
    });
  });

  group('BaseResponseData', () {
    test('holds data and total', () {
      final r = BaseResponseData(data: 'x', total: 1);
      expect(r.data, 'x');
      expect(r.total, 1);
    });
  });

  group('BusinessCode / HttpConstant', () {
    test('BusinessCode.success is 0', () => expect(BusinessCode.success, 0));
    test('HttpConstant fields', () {
      expect(HttpConstant.code, 'code');
      expect(HttpConstant.data, 'data');
      expect(HttpConstant.message, 'msg');
      expect(HttpConstant.success, 'succ');
    });
    test('ExceptionHandle', () {
      expect(ExceptionHandle.success, 200);
      expect(ExceptionHandle.unauthorized, 401);
    });
  });
}
