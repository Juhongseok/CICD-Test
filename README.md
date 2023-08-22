# CICD-Test

## 시나리오
1. branch는 main -> dev -> feat으로 checkout
2. feat branch pr 경우 test 실시
3. main으로 push시 test/build/deploy 실시

## Trouble Shooting
1. github action Gradle build failed: see console output for details
    - `gradlew`에 대한 권한이 없어서 생기는 문제
    - 아래 설정을 test 실행 전에 추가
    ```yml
       - name: Permission for gradlew
            run: chmod +x ./gradlew
            shell: bash
    ```
   
2. SpringCicdApplicationTests > contextLoads() FAILED
    - Database 관련 설정 및 의존성을 추가 하지 않아서 `datasource` 생성 실패로 인한 test 실패
    - 프로젝트 초기 세팅 시 사용하지 않는 test 삭제 혹은 설정 파일 같이 생성 후 pr에 반영하는 것이 좋을 듯
