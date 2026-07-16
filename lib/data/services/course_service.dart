import '../models/course.dart';

abstract class CourseService {
  Future<List<Course>> getCourses();

  Future<Course?> getCourse(int id);

  Future<int> createCourse(Course course);

  Future<void> updateCourse(Course course);

  Future<void> deleteCourse(int id);
}
