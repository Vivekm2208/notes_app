import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/core/features/notes/data/models/note_model.dart';

class FireStoreNoteDataSources {
  FireStoreNoteDataSources({
    required String userId,
    FirebaseFirestore? fireStore,
  }) : _noteCollection = (fireStore ?? FirebaseFirestore.instance)
           .collection('users')
           .doc(userId)
           .collection('notes');

  final CollectionReference<Map<String, dynamic>> _noteCollection;

  Future<void> addNote(NoteModel note) async {
    await _noteCollection.doc(note.id).set(note.toMap());
  }

  Future<List<NoteModel>> getNote() async {
    final snapshot = await _noteCollection.get();

    return snapshot.docs.map((document) {
      final data = document.data();
      data['id'] = document.id;

      return NoteModel.fromMap(data);
    }).toList();
  }

  Future<void> updateNote(NoteModel note) async {
    await _noteCollection
        .doc(note.id)
        .set(note.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteNote(String id) async {
    await _noteCollection.doc(id).delete();
  }
}
