import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:flutter_build_manager/services/filename_template_service.dart';
import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';

void main() {
  group('FilenameTemplateService', () {
    late FilenameTemplateService service;
    
    setUp(() {
      service = FilenameTemplateService();
    });

    test('generates default template correctly', () {
      final variables = const TemplateVariables(
        project: 'DriveReplay',
        env: 'LIVE',
        counter: '001',
      );
      
      final template = '{project}_{date}_{env}_{counter}.apk';
      final result = service.generateFilename(template, variables);
      
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      expect(result, equals('DriveReplay_${today}_LIVE_001.apk'));
    });

    test('replaces all supported placeholders', () {
      final variables = const TemplateVariables(
        project: 'App',
        version: '1.2.3',
        flutterBuild: '42',
        counter: '005',
        env: 'PROD',
        platform: 'android',
        artifact: 'apk',
        branch: 'release',
        commit: 'abcdef1',
      );
      
      final template = '{project}-{version}+{flutter_build}-{counter}-{env}-{platform}-{artifact}-{branch}-{commit}';
      final result = service.generateFilename(template, variables);
      
      expect(result, equals('App-1.2.3+42-005-PROD-android-apk-release-abcdef1'));
    });

    test('replaces date and time placeholders correctly', () {
      final variables = const TemplateVariables();
      final template = '{year}-{month}-{day}_{time}_{datetime}';
      
      final result = service.generateFilename(template, variables);
      final now = DateTime.now();
      
      expect(result, contains(DateFormat('yyyy').format(now)));
      expect(result, contains(DateFormat('MM').format(now)));
      expect(result, contains(DateFormat('dd').format(now)));
      expect(result, contains(DateFormat('HHmmss').format(now)));
      expect(result, contains(DateFormat('yyyyMMdd_HHmmss').format(now)));
    });

    test('throws exception for unknown placeholders', () {
      final variables = const TemplateVariables(project: 'App');
      final template = '{project}_{unknown}_file';
      
      expect(
        () => service.generateFilename(template, variables),
        throwsA(isA<ReleaseManagerException>().having(
          (e) => e.details,
          'details',
          contains('unknown'),
        )),
      );
    });

    test('removes illegal filesystem characters automatically', () {
      final variables = const TemplateVariables(
        project: 'App/Name',
        branch: 'feature:test',
      );
      
      final template = '{project}_{branch}.apk';
      final result = service.generateFilename(template, variables);
      
      // Should replace '/' and ':' with '-'
      expect(result, equals('App-Name_feature-test.apk'));
    });
    
    test('cleans illegal characters in the template itself', () {
      final variables = const TemplateVariables(project: 'App');
      final template = 'my/dir/{project}.apk';
      
      final result = service.generateFilename(template, variables);
      expect(result, equals('my-dir-App.apk'));
    });
  });
}
