import 'package:flutter_application_3/models/resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/interview.dart';
import '../models/user.dart' as local_user;
import '../models/questions.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<local_user.User> getUserData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return local_user.User.fromMap(data); 
  }

  Future<List<Interview>> getUpcomingInterviews() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    final data = await _supabase
        .from('interviews')
        .select()
        .eq('user_id', userId)
        .order('date');
    return data.map((item) => Interview.fromMap(item)).toList();
  }
  Future<List<Resource>> getFeaturedResources() async {
    final data = await _supabase
        .from('resources')
        .select()
        .eq('is_featured', true);
    return data.map((item) => Resource.fromMap(item)).toList();
  }
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  Future<void> insertInterview(Interview interview) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    final data = {
      'user_id': userId,
      'company': interview.company,
      'role': interview.role,
      'date': interview.date.toIso8601String(),
      // Add other fields if your Interview model/table has them
    };
    await _supabase.from('interviews').insert(data);
  }

  Future<void> deleteInterview(String interviewId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    await _supabase
        .from('interviews')
        .delete()
        .eq('id', interviewId)
        .eq('user_id', userId);
  }
  
  Future<void> insertResource(Resource resource) async {
    final data = {
      'title': resource.title,
      'type': resource.type,
      'content_url': resource.contentUrl,
      'duration': resource.duration,
      // Add other fields if your Resource model/table has them
    };
    await _supabase.from('resources').insert(data);
  }

  Future<void> deleteResource(String resourceId) async {
    await _supabase
        .from('resources')
        .delete()
        .eq('id', resourceId);
  }
  
  Future<List<Question>> getQuestions({int? questionId}) async {
    var query = _supabase.from('questions').select();
    if (questionId != null) {
      query = query.eq('id', questionId); // Use 'id' as the column name for question id
    }
    final data = await query;
    return data.map<Question>((item) => Question.fromMap(item)).toList();
  }

  Future<List<Question>> getQuestionsByCategory(String category) async {
    final data = await _supabase
        .from('questions')
        .select()
        .eq('Category', category);
    return data.map<Question>((item) => Question.fromMap(item)).toList();
  }

  Future<List<Question>> getQuestionsByDifficulty(String difficulty) async {
    final data = await _supabase
        .from('questions')
        .select()
        .eq('Difficulty', difficulty);
    return data.map<Question>((item) => Question.fromMap(item)).toList();
  }
  
  /// Returns the answer string for a given question id from the database.
Future<String?> getAnswerById(int questionId) async {
  final data = await _supabase
      .from('questions')
      .select('answer')
      .eq('id', questionId)
      .single();
  // Returns null if not found, or the answer string if found
  // ignore: unnecessary_null_comparison
  return data != null ? data['answer'] as String? : null;
}

  final supabase = Supabase.instance.client;

  Future<void> ensureProfileExists(String uid) async {
    // Check if profile exists
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (response == null) {
      // Insert new profile if not found
      await supabase.from('profiles').insert({'id': uid});
    }
  }
}
