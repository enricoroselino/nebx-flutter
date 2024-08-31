import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nebx/shared/file_helper.dart';

abstract interface class IFormDataBuilder {
  FormDataBuilder addRecords(Map<String, dynamic> keyValues);

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
  FormDataBuilder addFile({required PlatformFile file}) {
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
    return FormData.fromMap(_records, ListFormat.multiCompatible);
  }
}
