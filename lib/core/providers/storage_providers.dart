import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threadly/core/common/failure.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';

final storageRepositoryProvider = Provider((ref) => StorageRepository(
  supabase: ref.watch(supabaseClientProvider),
));

class StorageRepository {
  final SupabaseClient _supabase;

  StorageRepository({required SupabaseClient supabase}) : _supabase = supabase;

  /// Uploads a file to Supabase Storage and returns the public URL
  /// 
  /// [bucket] - The storage bucket name (e.g., 'community-images', 'avatars')
  /// [path] - The folder path within the bucket
  /// [id] - Unique identifier for the file
  /// [file] - The file to upload
  FutureEither<String> storeFile({
    required String bucket,
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      if (file == null) {
        return left(Failure('No file provided'));
      }

      // Extract file extension from the original file
      final fileExtension = file.path.split('.').last.toLowerCase();
      final fileName = '$path/$id.$fileExtension';
      final fileBytes = await file.readAsBytes();

      // Determine MIME type based on extension
      final mimeType = _getMimeType(fileExtension);

      // Upload file to Supabase Storage
      await _supabase.storage.from(bucket).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: FileOptions(
          upsert: true, // Replace if exists
          contentType: mimeType,
        ),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);

      return right(publicUrl);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Get MIME type based on file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}