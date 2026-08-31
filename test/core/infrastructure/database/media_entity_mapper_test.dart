import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/infrastructure/database/entities/entities.dart';
import 'package:mochi_player/core/infrastructure/database/media_entity_mapper.dart';

void main() {
  test('preserves the media file storage source for playback resolution', () {
    final entity = MediaFileEntity()
      ..sourceId = 'local-library'
      ..path = '/Movies/Example.mkv'
      ..fileName = 'Example.mkv'
      ..parsedTitle = 'Example';

    final file = MediaEntityMapper.toMediaFile(entity);

    expect(file.sourceId, 'local-library');
  });
}
