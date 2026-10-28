import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/models/collaboration_models.dart';
import '../../../core/models/ticket_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/media_utils.dart';

class TicketRepository {
  final Dio _dio;

  TicketRepository(this._dio);

  Future<List<TicketDto>> getMine() async {
    try {
      final response = await _dio.get('/api/tickets/mine');
      final list = (response.data as List<dynamic>)
          .map((e) => TicketDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<TicketDto>> getBacklog(String projectId) async {
    try {
      final response = await _dio.get('/api/projects/$projectId/tickets/backlog');
      final list = (response.data as List<dynamic>)
          .map((e) => TicketDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<TicketDto>> getBySprint(String sprintId) async {
    try {
      final response = await _dio.get('/api/sprints/$sprintId/tickets');
      final list = (response.data as List<dynamic>)
          .map((e) => TicketDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> getById(String ticketId) async {
    try {
      final response = await _dio.get('/api/tickets/$ticketId');
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> getByRef(String projectKey, int ticketNumber) async {
    try {
      final response = await _dio.get('/api/tickets/by-ref/$projectKey/$ticketNumber');
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> createTicket(String projectId, CreateTicketRequest request) async {
    try {
      final response = await _dio.post(
        '/api/projects/$projectId/tickets',
        data: request.toJson(),
      );
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> updateTicket(String ticketId, UpdateTicketRequest request) async {
    try {
      final response = await _dio.put(
        '/api/tickets/$ticketId',
        data: request.toJson(),
      );
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> changeStatus(String ticketId, String statusId) async {
    try {
      final response = await _dio.put(
        '/api/tickets/$ticketId/status',
        data: ChangeTicketStatusRequest(statusId: statusId).toJson(),
      );
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<TicketDto> moveToSprint(String ticketId, String? sprintId) async {
    try {
      final response = await _dio.put(
        '/api/tickets/$ticketId/sprint',
        data: MoveTicketToSprintRequest(sprintId: sprintId).toJson(),
      );
      return TicketDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await _dio.delete('/api/tickets/$ticketId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Comments
  Future<List<CommentDto>> getComments(String ticketId) async {
    try {
      final response = await _dio.get('/api/tickets/$ticketId/comments');
      return (response.data as List<dynamic>)
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<CommentDto> addComment(String ticketId, String content) async {
    try {
      final response = await _dio.post(
        '/api/tickets/$ticketId/comments',
        data: {'content': content},
      );
      return CommentDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<CommentDto> updateComment(String commentId, String content) async {
    try {
      final response = await _dio.put(
        '/api/comments/$commentId',
        data: {'content': content},
      );
      return CommentDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete('/api/comments/$commentId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Attachments
  Future<List<AttachmentDto>> getAttachments(String ticketId) async {
    try {
      final response = await _dio.get('/api/tickets/$ticketId/attachments');
      return (response.data as List<dynamic>)
          .map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<AttachmentDto> uploadTicketAttachment(
    String ticketId,
    PickedMediaFile file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: DioMediaType.parse(file.contentType),
        ),
      });
      final response = await _dio.post(
        '/api/tickets/$ticketId/attachments',
        data: formData,
      );
      return AttachmentDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<AttachmentDto>> getCommentAttachments(String commentId) async {
    try {
      final response = await _dio.get('/api/comments/$commentId/attachments');
      return (response.data as List<dynamic>)
          .map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<AttachmentDto> uploadCommentAttachment(
    String commentId,
    PickedMediaFile file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: DioMediaType.parse(file.contentType),
        ),
      });
      final response = await _dio.post(
        '/api/comments/$commentId/attachments',
        data: formData,
      );
      return AttachmentDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<AttachmentDto>> getBoardAttachments(String boardId) async {
    try {
      final response = await _dio.get('/api/boards/$boardId/attachments');
      return (response.data as List<dynamic>)
          .map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<AttachmentDto> uploadBoardAttachment(
    String boardId,
    PickedMediaFile file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: DioMediaType.parse(file.contentType),
        ),
      });
      final response = await _dio.post(
        '/api/boards/$boardId/attachments',
        data: formData,
      );
      return AttachmentDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<(Uint8List bytes, String contentType)> downloadAttachment(
    String attachmentId,
  ) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/attachments/$attachmentId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data ?? const <int>[];
      final bytes = data is Uint8List ? data : Uint8List.fromList(data);
      final headerType = response.headers.value(Headers.contentTypeHeader);
      final contentType = (headerType != null && headerType.isNotEmpty)
          ? headerType.split(';').first.trim()
          : 'application/octet-stream';
      return (bytes, contentType);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteAttachment(String attachmentId) async {
    try {
      await _dio.delete('/api/attachments/$attachmentId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // History / Audit entries
  Future<List<TicketHistoryEntryDto>> getHistory(String ticketId) async {
    try {
      final response = await _dio.get('/api/tickets/$ticketId/history');
      return (response.data as List<dynamic>)
          .map((e) => TicketHistoryEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Labels (attachment gérée via /api/labels/{labelId}/tickets/{ticketId})
  Future<void> addLabel(String ticketId, String labelId) async {
    try {
      await _dio.post('/api/labels/$labelId/tickets/$ticketId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> removeLabel(String ticketId, String labelId) async {
    try {
      await _dio.delete('/api/labels/$labelId/tickets/$ticketId');
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
