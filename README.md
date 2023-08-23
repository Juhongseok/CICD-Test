# CICD-Test

## 시나리오
1. branch는 main -> dev -> feat으로 checkout
2. feat branch pr 경우 test 실시
3. main으로 push시 test/build/deploy 실시
4. (추가) git submodule 환경에서 동작 과정 실습

## TODO
1. AWS 계정 새로 생성(Free tier 기간 만료)
2. CodeDeploy 관련 학습
3. CD 과정 진행
   - EC2, S3, CodeDeploy 설정
   - Github Action Workflow File 생성
   - appspec.yml, deploy.sh 파일 생성

## 진행 과정
1. github action을 통해 특정 branch로 pull request 요청 시 gradle 사용하여 java build 및 test 진행

## Trouble Shooting
### 진행과정 1
1. github action Gradle build failed: see console output for details
    - `gradlew`에 대한 권한이 없어서 생기는 문제
    - 아래 설정을 test 실행 전에 추가
    ```yml
       - name: Permission for gradlew
            run: chmod +x ./gradlew
            shell: bash
    ```
   
2. SpringCicdApplicationTests > contextLoads() FAILED
    - JPA 의존성을 받아두고 Database 관련 설정 및 의존성을 추가 하지 않아서 `datasource` 생성 실패로 인한 test 실패
    - 프로젝트 초기 세팅 시 사용하지 않는 test 삭제 혹은 설정 파일 같이 생성 후 pr에 반영하는 것이 좋을 듯
