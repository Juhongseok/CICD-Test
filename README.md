# CICD-Test

## 시나리오
1. branch는 main -> dev -> feat으로 checkout
2. feat branch pr 경우 test 실시
3. main으로 push시 test/build/deploy 실시
4. (추가) git submodule 환경에서 동작 과정 실습

## TODO
1. ~~AWS 계정 새로 생성(Free tier 기간 만료)~~
2. ~~CodeDeploy 관련 학습~~
3. ~~CD 과정 진행~~
   - ~~EC2, S3, CodeDeploy 설정~~
   - ~~Github Action Workflow File 생성~~
      - ~~S3에 등록까지는 성공~~
      - ~~CodeDeploy에 배포 요청 보내기~~
   - ~~appspec.yml, deploy.sh 파일 생성~~
4. submodule 포함한 CD 과정 진행
  
## CodeDeploy 학습 내용
> **Amazon EC2 인스턴스, 온프레미스 인스턴스, 서버리스 Lambda 함수, Amazon ECS 서비스로 애플리케이션 배포를 자동화하는 배포 서비스**

CodeDeploy는 서버에서 실행되고 Amazon S3 버킷, GitHub 리포지토리 저장되는 애플리케이션 콘텐츠를 배포

### EC2 기반 배포

App + AppSpec(yml 형식) 파일로 구성해서 배포

> AppSpec: 배포 그룹의 Instance에 **App 배포 방식** 지정
> Instance에 파일을 복사할 위치 및 배포 스크립트를 실행할 시점 등과 같은 배포 명세가 포함
> [AppSpec 양식](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/application-revisions-appspec-file.html#add-appspec-file-server)
>
> 배포하는 동안 CodeDeploy Agent는 AppSpec 파일의 **hooks** section에서 현재 이벤트의 이름을 조회, 이벤트가 발견되면 실행할 스크립트 목록을 검색(나타나는 순서대로 순차 실행)
> 각 스크립트 상태는 CodeDeploy Agent의 log file에 기록
> Amazon Linux, Ubuntu Server Instance : `/var/log/aws/codedeploy-agent` 폴더에 `codedeploy-agent.YYYYMMDD.log`로 로그 파일 교체

### 필요 작업
1. EC2, S3, CodeDeploy 생성
    - EC2: CodeDeploy Agent 설치, S3접근 권한 추가
2. Github Action에서 AWS CLI 사용 시 사용 될 IAM USER 생성
    - S3, CodeDeploy 접근 권한 추가  
3. Application Root 위치에 AppSpec.yml 파일 생성
4. 실행을 위한 deploy.sh 파일 생성
5. S3에 zip 파일 전송 후 CodeDeploy에 배포 요청 보내기

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

### 진행과정 3
**Github Action을 통한 S3 bucket에 application zip file upload**
1. Unable to locate credentials
   - AWS CLI 사용 시 권한이 없어서 생기는 문제
   - S3에 접근 가능한 IAM USER 생성 후 Access key 할당
   - github repository -> settings -> secrets and variables -> Action 탭에 할당받은 access key & secret key 추가
   - S3 전송 전에 해당 step 추가
    ```yml
       - name: Configure AWS Credentials
         uses: aws-actions/configure-aws-credentials@v3
         with:
           aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
           aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
           aws-region: us-east-2
    ```
2. An error occurred (DeploymentGroupNameRequiredException) when calling the CreateDeployment operation: Deployment Group name is missing An error occurred (ApplicationDoesNotExistException) when calling the CreateDeployment operation: Applications not found for
    - EC2를 못찾는 경우
    - region 확인 잘하자.. 시드니에 만들고 서울에 없으니 당연히 안나오지..

3. The overall deployment failed because too many individual instances failed deployment, too few healthy instances are available for deployment, or some instances in your deployment group are experiencing problems.
    - 권한 설정한 부분이 인식이 안된 경우
    - codeDeploy agent restart
  
4. nohup: failed to run command 'java' 
    - java download

### 진행과정 4
**submodule 내부 파일 복사 안되는 문제**
1. actions/checkout@v3에서 submodule 에 대한 속성 값을 설정해주어야 서브 모듈까지 checkout 할 수 있음
2. submodule repo가 private일 경우 해당 repo에 접근 가능한 사람의 token을 필요로 함
```yml
- name: Check Repo code With Submodules
  uses: actions/checkout@v3
  with:
     submodules: 'true'
     token: ${{secrets.GH_ACCESS_TOKEN}}
```
