import 'package:flutter/material.dart';

/// 프로그램 정보 모달 - 개발 이력 및 프롬프트 기반 진화 과정 표시
class ProgramInfoModal extends StatelessWidget {
  const ProgramInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Galmuri Diary',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '프롬프트 기반 개발 이력',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceIntro(context),
                    const SizedBox(height: 32),
                    _buildVersionHistory(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIntro(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  '서비스 소개',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Galmuri Diary는 하이브리드 캡처 및 아카이빙 시스템입니다. '
              '웹 페이지, 스크린샷, 이미지를 캡처하고 OCR을 통해 텍스트를 자동 추출하여 '
              '검색 가능한 형태로 저장합니다.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('FastAPI 백엔드', Icons.api),
                _buildChip('Flutter Web/Android', Icons.phone_android),
                _buildChip('Chrome Extension', Icons.extension),
                _buildChip('OCR 자동 추출', Icons.text_fields),
                _buildChip('Local First', Icons.storage),
                _buildChip('Render 배포', Icons.cloud),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildVersionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              '개발 버전 이력',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...versionHistory.map((version) => _buildVersionCard(context, version)),
      ],
    );
  }

  Widget _buildVersionCard(BuildContext context, VersionInfo version) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: version.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            version.version,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          version.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          version.date,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 프롬프트
                if (version.prompts.isNotEmpty) ...[
                  _buildSectionTitle('사용자 프롬프트 질의'),
                  const SizedBox(height: 8),
                  ...version.prompts.map((prompt) => _buildPromptCard(prompt)),
                  const SizedBox(height: 16),
                ],

                // 추가된 기능
                if (version.features.isNotEmpty) ...[
                  _buildSectionTitle('추가된 기능'),
                  const SizedBox(height: 8),
                  ...version.features.map((feature) => _buildFeatureItem(feature)),
                  const SizedBox(height: 16),
                ],

                // 개선사항
                if (version.improvements.isNotEmpty) ...[
                  _buildSectionTitle('개선사항 및 기술 구현'),
                  const SizedBox(height: 8),
                  ...version.improvements.map((improvement) => _buildImprovementItem(improvement)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF667eea),
      ),
    );
  }

  Widget _buildPromptCard(String prompt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chat_bubble_outline, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              prompt,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementItem(String improvement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up, size: 18, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              improvement,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 버전 정보 데이터 모델
class VersionInfo {
  final String version;
  final String title;
  final String date;
  final Color color;
  final List<String> prompts;
  final List<String> features;
  final List<String> improvements;

  VersionInfo({
    required this.version,
    required this.title,
    required this.date,
    required this.color,
    required this.prompts,
    required this.features,
    required this.improvements,
  });
}

/// 개발 버전 이력 데이터
final List<VersionInfo> versionHistory = [
  VersionInfo(
    version: 'v1.0',
    title: '초기 프로젝트 구성',
    date: '2024년 초',
    color: Colors.blue,
    prompts: [
      '@prd.mdc 실행해주세요',
    ],
    features: [
      'FastAPI 백엔드 서버 구축 (Clean Architecture)',
      'Chrome Extension 개발 (Manifest V3)',
      'Flutter Android 앱 개발',
      'OCR 통합 (Tesseract)',
      'SQLite 로컬 데이터베이스',
      'Local First 전략 구현',
      'RESTful API 설계',
    ],
    improvements: [
      'Clean Architecture 적용: Domain, Application, Infrastructure, Presentation 계층 분리',
      '의존성 주입 패턴으로 테스트 가능한 구조 설계',
      'OCR 서비스 인터페이스화로 Mock/Real 구현 분리',
      'Repository 패턴으로 데이터 소스 추상화',
    ],
  ),
  VersionInfo(
    version: 'v1.1',
    title: 'Android APK 지원 및 실행 환경 구성',
    date: '2024년 초',
    color: Colors.green,
    prompts: [
      '안드로이드 apk로도 구성할 수 있나요',
      '실행해주세요',
    ],
    features: [
      'Flutter Android APK 빌드 설정',
      'Android Manifest 권한 설정',
      '로컬 데이터베이스 초기화 로직',
      '프로젝트 실행 가이드 문서화',
    ],
    improvements: [
      'Flutter 프로젝트 구조 정리',
      'Android 빌드 설정 최적화',
      '의존성 관리 개선',
    ],
  ),
  VersionInfo(
    version: 'v1.2',
    title: '클라우드 배포 및 데이터베이스 연동',
    date: '2024년 초',
    color: Colors.orange,
    prompts: [
      '해당 건은 웹 서비스인가요. vercel로 연결해서 쓸 수 있나요',
      'render는 어떤가요',
      '@RENDER_DEPLOY.md (69-71) 더 상세히 알려주세요',
      '@RENDER_DATABASE_SETUP.md (35-38) 이거 안나옴',
    ],
    features: [
      'Render 배포 설정 (render.yaml)',
      'PostgreSQL 데이터베이스 지원',
      '환경 변수 기반 데이터베이스 선택 로직',
      'Python 버전 설정 (runtime.txt)',
      '의존성 관리 (requirements-render.txt)',
      'CORS 미들웨어 설정',
      '데이터베이스 연결 가이드 문서화',
    ],
    improvements: [
      'PostgresGalmuriRepository 구현으로 프로덕션 DB 지원',
      '동적 Repository 선택 로직 (DATABASE_URL 기반)',
      'Pillow 버전 호환성 문제 해결',
      'Python 버전 형식 수정 (3.11.0)',
      'Render UI 변경사항 반영한 문서 업데이트',
    ],
  ),
  VersionInfo(
    version: 'v1.3',
    title: 'API 사용 가이드 및 캡처 기능 문서화',
    date: '2024년 초',
    color: Colors.purple,
    prompts: [
      'api를 어떻게 활용하나요',
      '캠쳐는 어떻게 쓰는 건가요',
    ],
    features: [
      'API 사용 가이드 문서 (API_USAGE.md)',
      '캡처 기능 사용법 문서 (HOW_TO_CAPTURE.md)',
      'Python/JavaScript API 예제 코드',
      '프로젝트 아키텍처 문서 (ARCHITECTURE.md)',
    ],
    improvements: [
      'API 엔드포인트 상세 설명',
      '실제 사용 예제 코드 제공',
      'Chrome Extension 사용법 시각화',
      '프로젝트 구조 및 데이터 흐름 설명',
    ],
  ),
  VersionInfo(
    version: 'v1.4',
    title: 'Flutter Web 프론트엔드 추가',
    date: '2024년 초',
    color: Colors.teal,
    prompts: [
      'Flutter로 서비스 하는 거 아니였냐요',
      '웹 프로트엔드 만들어 주세요 flutter로',
      '이미 구성된 https://galmuri.onrender.com/ Render의 백앤드와 연계 된 프론트엔드로 구성하는 거죠',
    ],
    features: [
      'Flutter Web 프론트엔드 구현',
      'WebHomeScreen: 웹 최적화 홈 화면 (사이드바, 그리드 레이아웃)',
      'WebAppBar: 웹 전용 앱바',
      '웹/모바일 통합 이미지 업로드 (image_picker)',
      'Render 백엔드 기본 URL 설정 (https://galmuri.onrender.com)',
      'Vercel/Netlify 배포 설정 파일',
      '반응형 디자인 (넓은 화면/작은 화면 대응)',
      '프로그램 정보 모달 (개발 이력 표시)',
    ],
    improvements: [
      '웹에서 dart:html 의존성 제거, image_picker로 통합',
      '플랫폼별 조건부 렌더링 (kIsWeb)',
      '웹 빌드 최적화 및 배포 가이드 작성',
      '프롬프트 기반 개발 이력 시각화',
      '버전별 기능 및 개선사항 추적',
    ],
  ),
];

