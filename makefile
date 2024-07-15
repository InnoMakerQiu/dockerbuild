# Docker 用户名
DOCKER_USER = tempuser5
# Docker 密码
DOCKER_PASS = A3F79eB6F3E6
# Docker 镜像仓库地址
REGISTRY = harbor.lins.lab
# 镜像名称
IMAGE_NAME = zhiying_image1
# 库名称
LIBRARY_NAME = zhiying_base_image
# 镜像标签
IMAGE_TAG = v2.0
# 库标签
LIBRARY_TAG = v1.0

build:
	DOCKER_BUILDKIT=0 docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

build_inter:
	DOCKER_BUILDKIT=0 docker build -t $(IMAGE_NAME):$(IMAGE_TAG) --build-arg http_proxy=http://192.168.123.169:18889 --build-arg https_proxy=http://192.168.123.169:18889 .

login:
	docker login -u $(DOCKER_USER) -p $(DOCKER_PASS) $(REGISTRY)

tag:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/library/$(LIBRARY_NAME):$(LIBRARY_TAG)

push: login tag
	docker push $(REGISTRY)/library/$(LIBRARY_NAME):$(LIBRARY_TAG)
