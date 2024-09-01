import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nebx/src/shared/helpers/file_helper.dart';

abstract interface class IFormDataBuilder {
  FormDataBuilder addRecords(Map<String, dynamic> keyValues);

  FormDataBuilder addFileStream({required PlatformFile file});

  FormDataBuilder addFileBytes({
    required List<int> bytes,
    required String filename,
    MediaType? contentType,
  });

  FormDataBuilder addFile({required PlatformFile file});

  FormData build();
}

class FormDataBuilder implements IFormDataBuilder {
  final Map<String, dynamic> _records = {};
  final Set<MultipartFile> _attachments = {};
  late final String _attachmentsKey;

  FormDataBuilder({String attachmentsKey = "attachments"}) {
    _attachmentsKey = attachmentsKey;
  }

  @override
  FormDataBuilder addRecords(Map<String, dynamic> keyValues) {
    _records.addAll(keyValues);
    return this;
  }

  @override
  FormDataBuilder addFileBytes({
    required List<int> bytes,
    required String filename,
    MediaType? contentType,
  }) {
    final multipart = MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: contentType,
    );

    _attachments.add(multipart);
    return this;
  }

  @override
  FormDataBuilder addFile({required PlatformFile file}) {
    if (!FileHelper.isFilePicked(file)) return this;
    final contentType = FileHelper.parseMediaType(file);

    final multipart = MultipartFile.fromFileSync(
      file.path!,
      filename: file.name,
      contentType: contentType,
    );

    _attachments.add(multipart);
    return this;
  }

  @override
  FormDataBuilder addFileStream({required PlatformFile file}) {
    if (!FileHelper.isFilePicked(file)) return this;
    final contentType = FileHelper.parseMediaType(file);

    final multipart = MultipartFile.fromStream(
      () => file.readStream!,
      file.size,
      filename: file.name,
      contentType: contentType,
    );

    _attachments.add(multipart);
    return this;
  }

  @override
  FormData build() {
    _records.addAll({_attachmentsKey: _attachments.toList()});

    // https://github.com/cfug/dio/issues/1155
    return FormData.fromMap(_records, ListFormat.multiCompatible);
  }
}
